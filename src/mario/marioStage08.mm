#include "marioStage08.h"

#define MARGIN_X 50
#define MARGIN_Y 30

#define FLAG_X 1110
#define FLAG_Y 590
#define FLAG_W 35
#define FLAG_H 40

//--------------------------------------------------------------
void marioStage08::setup(){
    ofEnableAlphaBlending();
    
    thaw = thawAppManager::getInstance();
    
    //spritemanager
    stage.setup("settings.xml", "stage08.xml");
    stage.setEntry(true, true, true, true);
    
    //flag
    flag.loadImage("flag.png");
    
    //pipe animation
    shouldTeleport = false;
    falling_out_pipe = false;
    stage.pipeAnimation = false;
    pipe_id = 0;
    
    //mode of interaction
    marioMode = 0; // 0: here
    availableMode = 7; // 6: pinch mario, 7: shoot mario
}

//--------------------------------------------------------------
void marioStage08::update(){
    if(1-pt.z/400.f <0.2) stage.set1Move(1,10);
    else stage.set1Move(3,30);
    
    if(isFlying){
        vy +=0.5;
        if(pt.y>560 && vy >0.f){
            isFlying = false;
            hasFlied = true;
            return;
        }
        
        pt.x += vxz * sinA;
        pt.y += vy;
        pt.z += vxz * cosA;
        
        stage.set1X(pt.x);
        stage.set1Y(pt.y);
    }
    else
    {
        stage.update(thaw->phoneX, thaw->phoneY, thaw->phoneW, thaw->phoneH, thaw->angle);
        
        vector<ofPoint> poly;
        poly.push_back( ofPoint(thaw->phoneX+20, thaw->phoneY+20) );
        poly.push_back( ofPoint(thaw->phoneX+thaw->phoneW-20, thaw->phoneY+20) );
        poly.push_back( ofPoint(thaw->phoneX+thaw->phoneW-20, thaw->phoneY+thaw->phoneH-20) );
        poly.push_back( ofPoint(thaw->phoneX+20, thaw->phoneY+thaw->phoneH-20) );
        if(ofInsidePoly(ofPoint(stage.get1X(), stage.get1Y()), poly)){
            if(marioMode == 0 && availableMode >0 && thaw->onTrackPattern){
                marioMode = availableMode;
                stage.teleportPlayer1(false, thaw->phoneX, thaw->phoneY, 0, 0);
            }
        }
    }
    
    if(stage.get1X()>FLAG_X-30 && stage.get1X()<FLAG_X-30+FLAG_W && stage.get1Y()>FLAG_Y-30 && stage.get1Y()<FLAG_Y-30+FLAG_H/3){
        isCleared = true;
        t_clear = ofGetSystemTime();
    }
    
    if(isCleared && ofGetSystemTime() - t_clear > 1000){
        thaw->toggleApp();
    }
}

//--------------------------------------------------------------
void marioStage08::gotOSCMessage(ofxOscMessage m){
    
    if(m.getAddress() == "/mario/client/player"){
        phoneMarioX = m.getArgAsInt32(0);
        phoneMarioY = m.getArgAsInt32(1);
        phoneMarioVX = m.getArgAsInt32(3);
        phoneMarioVY = m.getArgAsInt32(4);
        
        if(marioMode >0){
            if(m.getArgAsInt32(2)>0 &&(phoneMarioX<-MARGIN_X + 15
                                       || phoneMarioX>MARGIN_X+568 - 70
                                       || phoneMarioY<-MARGIN_Y
                                       || phoneMarioY>MARGIN_Y+thaw->phoneH)){
                
                marioMode = 0;
                float theta = PI*thaw->angle/180.f;
                
                float x = thaw->phoneX + phoneMarioY*sin(-theta) + phoneMarioX*cos(-theta);
                float y = thaw->phoneY + phoneMarioY*cos(-theta) - phoneMarioX*sin(-theta);
                float vx = phoneMarioVY*sin(-theta) + phoneMarioVX*cos(-theta);
                float vy = phoneMarioVY*cos(-theta) - phoneMarioVX*sin(-theta);
                stage.teleportPlayer1(true, x, y, vx, vy);
            }
        }
    }
    else if(m.getAddress() == "/mario/client/shoot"){
        float vv = m.getArgAsFloat(0);
        marioMode = 0;
        stage.teleportPlayer1(true, thaw->phoneX, thaw->phoneY-100, 0, 0);
        
        isFlying = true;
        sinA = 0.7;
        cosA = 0.7;
        pt.x = stage.get1X();
        pt.y = stage.get1Y();
        pt.z = 0.;
        vy = -25*vv;
        vxz = 12*vv;
    }
}

//--------------------------------------------------------------
void marioStage08::draw(){
    
    if(ofGetSystemTime() - t_reset < 1000){
        ofSetColor(0);
        ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
        
        ofSetColor(225);
        stage.assets->font.drawString("STAGE08", 500, 500);
    }
    else{
        ofSetColor(100);
        ofLine(0, 640, ofGetScreenWidth(), 640);
        ofLine(995, 640, -500, ofGetScreenHeight());
        ofLine(1170, 640, 600, ofGetScreenHeight());
        
        //mario
        ofSetColor(255);
        ofEnableSmoothing();
        float scale = MAX(0.2, 1-pt.z/400.f);
        stage.draw(scale, scale);
        ofDisableSmoothing();
        
        ofEnableAlphaBlending();
        flag.draw(FLAG_X, FLAG_Y, FLAG_W, FLAG_H);
        ofDisableAlphaBlending();
    }
    
    if(thaw->debug){
        ofSetColor(255);
        ofDrawBitmapString("fps: " + ofToString(ofGetFrameRate()), 10, 20);
        ofDrawBitmapString("(x,y) : " + ofToString(thaw->phoneX) + " " + ofToString(thaw->phoneY), 10, 40);
        ofDrawBitmapString("(vx,vy) : " + ofToString(thaw->phoneVX) + " " + ofToString(thaw->phoneVY), 10, 60);
        ofDrawBitmapString("(r,g,b) : " + ofToString(thaw->r) + " " + ofToString(thaw->g) + " " + ofToString(thaw->b), 10, 80);
        ofDrawBitmapString("on : " + ofToString(thaw->onScreenMode) + " " + ofToString(thaw->onTrackPattern), 10, 100);
        ofDrawBitmapString("out : " + ofToString(thaw->out_index[0]) + " " + ofToString(thaw->out_index[1])
                           + " " + ofToString(thaw->out_index[2]) + " " + ofToString(thaw->out_index[3]), 10, 120);
        
        ofDrawBitmapString("(mx,my) : " + ofToString(stage.get1X()) + " " + ofToString(stage.get1Y()), 10, 140);
        ofDrawBitmapString("(mvx,mvy) : " + ofToString(stage.get1VX()) + " " + ofToString(stage.get1VY()), 10, 160);
        ofDrawBitmapString("mario here : " + ofToString(stage.isPlayer1Here), 10, 180);
        ofDrawBitmapString("distance : " + ofToString(thaw->distance), 10, 200);
        ofDrawBitmapString("touch : " + ofToString(thaw->screenTouch), 10, 220);
        ofDrawBitmapString("isFlying : " + ofToString(isFlying), 10, 240);
        ofDrawBitmapString("accel : " + ofToString(thaw->accelX)+" "+ofToString(thaw->accelY)+" "+ofToString(thaw->accelZ), 10, 260);
    }
}


//--------------------------------------------------------------
void marioStage08::keyPressed  (int key){
    stage.keyPressed(key);
    
    if(key == OF_KEY_UP || key == OF_KEY_DOWN || key == OF_KEY_LEFT || key == OF_KEY_RIGHT){
        ofxOscMessage m;
        m.setAddress( "/mario/host/key" );
        m.addIntArg( key );
        m.addIntArg( 1 );
        m.addIntArg( stage.get1X() - thaw->phoneX);
        m.addIntArg( stage.get1Y() - thaw->phoneY);
        m.addIntArg( stage.get1VX());
        m.addIntArg( stage.get1VY());
        m.addIntArg( marioMode ); //stage
        m.addIntArg( availableMode ); //stage
        
        thaw->send( m );
    }
}

//--------------------------------------------------------------
void marioStage08::keyReleased  (int key){
    stage.keyReleased(key);
    
    if(key == OF_KEY_UP || key == OF_KEY_DOWN || key == OF_KEY_LEFT || key == OF_KEY_RIGHT){
        ofxOscMessage m;
        m.setAddress( "/mario/host/key" );
        m.addIntArg( key );
        m.addIntArg( 0 );
        m.addIntArg( stage.get1X() - thaw->phoneX);
        m.addIntArg( stage.get1Y() - thaw->phoneY);
        m.addIntArg( stage.get1VX());
        m.addIntArg( stage.get1VY());
        m.addIntArg( marioMode ); //stage
        m.addIntArg( availableMode ); //stage
        
        thaw->send( m );
    }
    
    if(key =='s'){
        isFlying = true;
        sinA = 0.7;
        cosA = 0.7;
        pt.x = stage.get1X();
        pt.y = stage.get1Y();
        pt.z = 0.;
        vy = -25;
        vxz = 12;
    }
}

//--------------------------------------------------------------
void marioStage08::mouseMoved(int x, int y ){
}

//--------------------------------------------------------------
void marioStage08::mouseDragged(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage08::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage08::mouseReleased(int x, int y, int button){
}

void marioStage08::reset(){
    t_reset = ofGetSystemTime();
    isCleared = false;
    
    //init position
    stage.set1X(10);
    stage.set1Y(10);
}
