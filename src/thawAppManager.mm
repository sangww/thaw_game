#include "thawAppManager.h"


thawAppManager *thawAppManager::singleton= 0;

void thawAppManager::setup(){
    
    //bonjour
    bonjourServer.startService( "_ecs._tcp.", "ecs", PORT_BONJOUR );
    
    //udb connectors
	receiver.setup(PORT_R);
    isConnected = false;
    
    //app manager
    cur_app = -1;
    
    //set calibration module
	ls.setup(2, 1);
    isCalibrating = false;
    isRecalibrated = true;
    //axr = 5.4; axg = -0.6;
    //byr = -0.6; byg = 3.0;
    axr = 3.8; axg = 0.9;
    byr = -0.2; byg = 2.4;
    
    float czx, czb;
    czx = 0.12;
    czb = 0.3;
    t_calib_stay = 700;
    t_calib_stay_offset = 500;
    t_calib_trans = 500;
    
    //phone tracking initialization
    phoneH = 280;
    phoneW = 580;
    phoneX_offset = 0; phoneY_offset = 0;
    pattern_size = 100.f;
    
    //phone status
    onScreenMode = false;
    onTrackPattern = false;
    
    //debug
    debug = false;
    pause = false;
    fullscreenpattern = true;
    
    //calibration pnts
    ref_pnt.push_back(ofPoint(0, 0));
    ref_pnt.push_back(ofPoint(ofGetScreenWidth()/2, 0));
    ref_pnt.push_back(ofPoint(ofGetScreenWidth()-300, 0));
    ref_pnt.push_back(ofPoint(ofGetScreenWidth()-300, ofGetScreenHeight()/2));
    ref_pnt.push_back(ofPoint(ofGetScreenWidth()/2, ofGetScreenHeight()/2));
    ref_pnt.push_back(ofPoint(80, ofGetScreenHeight()/2));
    ref_pnt.push_back(ofPoint(80, ofGetScreenHeight()-300));
    ref_pnt.push_back(ofPoint(ofGetScreenWidth()/2, ofGetScreenHeight()-300));
    ref_pnt.push_back(ofPoint(ofGetScreenWidth()-300, ofGetScreenHeight()-300));
}

void thawAppManager::addApp(thawAppInterface* app){
    list_app.push_back(app);
}

void thawAppManager::setApp(int i){
    cur_app = i;
    if(cur_app<0) cur_app = 0;
    if(cur_app>=list_app.size()) cur_app = list_app.size() - 1;
    
    if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->reset();
    }
}

void thawAppManager::toggleApp(){
    cur_app++;
    if(cur_app>=list_app.size()) cur_app = 0;
    if(list_app.size() < 1) cur_app = -1;
    
    if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->reset();
    }
}

void thawAppManager::update(){
	// check for waiting messages
	while(receiver.hasWaitingMessages()){
		// get the next message
		ofxOscMessage m;
		receiver.getNextMessage(&m);
        
        if(!isConnected){
            cout<<m.getRemoteIp()<<endl;
            sender.setup(m.getRemoteIp(), PORT_S);
            isConnected = true;
        }
        
        if(m.getAddress() == "/client/rgb"){
            r = m.getArgAsInt32(0);
            g = m.getArgAsInt32(1);
            b = m.getArgAsInt32(2);
            out_index[0] = m.getArgAsInt32(3);
            out_index[1] = m.getArgAsInt32(4);
            out_index[2] = m.getArgAsInt32(5);
            out_index[3] = m.getArgAsInt32(6);
        }
        else if(m.getAddress() == "/client/track"){
            if(!onTrackPattern) t_lost = ofGetSystemTime();
            onScreenMode = m.getArgAsInt32(5);
            onTrackPattern = m.getArgAsInt32(6);
            
            if(!pause){
                float smooth = 0.6;
                if(onTrackPattern){
                    phoneVX = (m.getArgAsInt32(0) + phoneX_offset) - phoneX;
                    phoneVY = (m.getArgAsInt32(1) + phoneY_offset) - phoneY;
                    phoneX = phoneX*smooth + (1-smooth)*(m.getArgAsInt32(0) + phoneX_offset);
                    phoneY = phoneY*smooth + (1-smooth)*(m.getArgAsInt32(1) + phoneY_offset);
                }
                accelX = accelX*smooth + (1-smooth)*m.getArgAsFloat(2);
                accelY = accelY*smooth + (1-smooth)*m.getArgAsFloat(3);
                accelZ = accelZ*smooth + (1-smooth)*m.getArgAsFloat(4);
                angle = -180*atan2(accelX, accelY)/PI-90;
            }
            distance = m.getArgAsFloat(7);
        }
        else if(m.getAddress() == "/client/touch"){
            screenTouch = (m.getArgAsInt32(0));
            if(screenTouch){
                touchX = m.getArgAsInt32(1);
                touchY = m.getArgAsInt32(2);
            }
        }

        if(cur_app>=0 && cur_app < list_app.size()){
            list_app[cur_app]->gotOSCMessage(m);
        }
	}
    
    //adjusting the phone's position
    if(out_index[0]){
        phoneX_offset -= 5;
        phoneY_offset -= 5;
    }
    if(out_index[1]){
        phoneX_offset += 5;
        phoneY_offset -= 5;
    }
    if(out_index[2]){
        phoneX_offset += 5;
        phoneY_offset += 5;
    }
    if(out_index[3]){
        phoneX_offset -= 5;
        phoneY_offset += 5;
    }
    if( (!onTrackPattern || !onScreenMode) && ofGetSystemTime() - t_lost > 100){
        phoneX_offset = 0;
        phoneY_offset = 0;
    }
    if(fullscreenpattern){
        phoneX_offset = 0;
        phoneY_offset = 0;
    }
    
    if(isCalibrating){
        long long t = ofGetSystemTime();
        
        if(t - t_calib_begin < refIndex*(t_calib_stay+t_calib_trans) + t_calib_stay
           && t - t_calib_begin > refIndex*(t_calib_stay+t_calib_trans) + t_calib_stay_offset){
            if(refIndex < ref_pnt.size()){
                measure_refs.push_back(ref_pnt[refIndex]);
                measured_color.push_back(ofPoint(r,g));
            }
        }
        else if(t - t_calib_begin >= refIndex*(t_calib_stay+t_calib_trans) + t_calib_stay + t_calib_trans){
            refIndex ++;
        }
        
        if(refIndex>=ref_pnt.size()){
            
            ls.clear();
            for(int i =0; i<measure_refs.size(); i++){
                vector<float> input;
                input.resize(2);
                input[0] = measured_color[i].x;
                input[1] = measured_color[i].y;
                
                vector<float> output;
                output.resize(1);
                output[0] = measure_refs[i].x;
                
                ls.add(input, output);
            }
            ls.update();
            
            axr = 0.94*ls.mapMat->data.fl[0];
            axg = ls.mapMat->data.fl[1];
            
            ls.clear();
            for(int i =0; i<measure_refs.size(); i++){
                vector<float> input;
                input.resize(2);
                input[0] = measured_color[i].x;
                input[1] = measured_color[i].y;
                
                vector<float> output;
                output.resize(1);
                output[0] = measure_refs[i].y;
                
                ls.add(input, output);
            }
            ls.update();
            
            byr = ls.mapMat->data.fl[0];
            byg = 0.92*ls.mapMat->data.fl[1];
            
            isCalibrating = false;
            isRecalibrated = true;
        }
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->update();
    }
    
    if(isRecalibrated && isConnected){
        ofxOscMessage m;
        m.setAddress( "/host/calibration" );
        m.addFloatArg(axr);
        m.addFloatArg(axg);
        m.addFloatArg(byr);
        m.addFloatArg(byg);
        send( m );
        isRecalibrated = false;
        
        cout<<"calibration sent: "<<axr<<" "<<axg<<" "<<byr<<" "<<byg<<endl;
    }
}

void thawAppManager::draw(){
    if(isCalibrating){
        if(refIndex < ref_pnt.size()){
            long long t = ofGetSystemTime();
            
            if(t - t_calib_begin < refIndex*(t_calib_stay+t_calib_trans) + t_calib_stay){
                float cr = 255.f * ref_pnt[refIndex].x / (float)ofGetScreenWidth();
                float cg = 255.f * ref_pnt[refIndex].y / (float)ofGetScreenHeight();
                ofSetColor(cr, cg, 51);
                ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
            }
            else if(refIndex < ref_pnt.size()-1){
                float a = (t - t_calib_begin - refIndex*(t_calib_stay+t_calib_trans) - t_calib_stay)/(float)(t_calib_trans);
                
                float cx = ref_pnt[refIndex].x*(1-a) + ref_pnt[refIndex+1].x*a;
                float cy = ref_pnt[refIndex].y*(1-a) + ref_pnt[refIndex+1].y*a;
                float cr = 255.f * cx / (float)ofGetScreenWidth();
                float cg = 255.f * cy / (float)ofGetScreenHeight();
                ofSetColor(cr, cg, 51);
                ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
            }
        }
        ofSetColor(255);
        ofDrawBitmapString("fps: " + ofToString(ofGetFrameRate()), 10, 20);
        ofDrawBitmapString("calibration: " + ofToString(refIndex) + " th point, " + ofToString(r)+ " "+ofToString(g), 10, 40);
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        
        if(fullscreenpattern){
            drawFullScreenPattern();
        }
        else if(onScreenMode && !onTrackPattern){
            if(pattern_size > ofGetScreenWidth()) drawFullScreenPattern();
            else drawPartScreenPattern(phoneX+90, phoneY+70, pattern_size *1.4);
        }
        else if(onScreenMode){
            float size = 20*sqrt(phoneVX*phoneVX + phoneVY*phoneVY);
            if(size > 300.f) size = 300.f;
            if(size< 100.f) size = 100.f;
            drawPartScreenPattern(phoneX+90, phoneY+70, size);
        }
        list_app[cur_app]->draw();
        
        if(debug){
            ofSetColor(255, 0, 0);
            ofCircle(phoneX, phoneY, 20);
            ofSetColor(255);
            ofDrawBitmapString("id: " + ofToString(cur_app), 1000, 20);
        }
    }
}

void thawAppManager::drawFullScreenPattern(){
    
    glBegin(GL_POLYGON);
    glColor3f(0.f,0.f,0.2f);
    glVertex3f(0, 0, 0);
    glColor3f(0.f,1.f,0.2f);
    glVertex3f(0, ofGetScreenHeight(), 0);
    glColor3f(1.f,1.f,0.2f);
    glVertex3f(ofGetScreenWidth(), ofGetScreenHeight(), 0);
    glColor3f(1.f,0.f,0.2f);
    glVertex3f(ofGetScreenWidth(), 0, 0);
    glEnd();
}

void thawAppManager::drawPartScreenPattern(int x, int y, int size){
    
    ofSetCircleResolution(64);
    
    float smooth = 0.7f;
    pattern_size = pattern_size*smooth + (1-smooth)*size;
    
    glEnable(GL_BLEND);
    glColorMask(0, 0, 0, 1);
    glBlendFunc(GL_SRC_ALPHA, GL_ZERO);
    glColor4f(0.5,0.5,0.5,0.0f);
    ofCircle (x, y, pattern_size/2);
    glColorMask(1, 1, 1, 1);
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);
    
    glBegin(GL_POLYGON);
    glColor3f(0.f,0.f,0.2f);
    glVertex3f(0, 0, 0);
    glColor3f(0.f,1.f,0.2f);
    glVertex3f(0, ofGetScreenHeight(), 0);
    glColor3f(1.f,1.f,0.2f);
    glVertex3f(ofGetScreenWidth(), ofGetScreenHeight(), 0);
    glColor3f(1.f,0.f,0.2f);
    glVertex3f(ofGetScreenWidth(), 0, 0);
    glEnd();
    
    glDisable(GL_BLEND);
}

void thawAppManager::send(ofxOscMessage m){
    if(isConnected)
        sender.sendMessage(m);
}

void thawAppManager::keyPressed  (int key){
    if(isCalibrating){
        
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->keyPressed(key);
    }
    
    if(!isCalibrating && key=='c'){
        measured_color.clear();
        measure_refs.clear();
        
        isCalibrating = true;
        refIndex = 0;
        
        t_calib_begin = ofGetSystemTime();
    }
    if(key=='r'){
        isRecalibrated = true;
    }
    if(key=='d'){
        debug = !debug;
    }
    if(key=='p'){
        pause = !pause;
    }
    if(key=='f'){
        fullscreenpattern = !fullscreenpattern;
    }
    if(key =='i'){
        phoneX = 0;
        phoneY = 0;
    }
    if(key =='m'){
        ofSoundSetVolume(0.f);
    }
    if(key == 'l'){
        if(isConnected){
            ofxOscMessage m;
            m.setAddress( "/host/camera" );
            m.addIntArg(1);
            send( m );
        }
    }
}
void thawAppManager::keyReleased  (int key){
    if(isCalibrating){
        
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->keyReleased(key);
    }
}
void thawAppManager::mouseMoved(int x, int y ){
    if(isCalibrating){
        
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->mouseMoved(x, y);
    }
}
void thawAppManager::mouseDragged(int x, int y, int button){
    if(isCalibrating){
        
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->mouseDragged(x, y, button);
    }
}
void thawAppManager::mousePressed(int x, int y, int button){
    if(isCalibrating){
        
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->mousePressed(x, y, button);
    }
}
void thawAppManager::mouseReleased(int x, int y, int button){
    if(isCalibrating){
        
    }
    else if(cur_app>=0 && cur_app < list_app.size()){
        list_app[cur_app]->mouseReleased(x, y, button);
    }
}