#include "marioStage09.h"

#define FLAG_X 1200
#define FLAG_Y 680
#define FLAG_W 90
#define FLAG_H 130

//--------------------------------------------------------------
void marioStage09::setup(){
    ofEnableAlphaBlending();
    
    thaw = thawAppManager::getInstance();
    
    //spritemanager
    stage.setup("settings.xml", "stage09.xml");
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
    availableMode = 8; // 8: tilt
}

//--------------------------------------------------------------
void marioStage09::update(){
    
    if(tilt){
        if(key_up) tz -= 10;
        if(key_down) tz += 10;
        if(key_left) tx -= 10;
        if(key_right) tx += 10;
    }
    else{
        stage.update(thaw->phoneX, thaw->phoneY, thaw->phoneW, thaw->phoneH, thaw->angle);
        
        if(stage.get1X()>FLAG_X && stage.get1X()<FLAG_X+FLAG_W && stage.get1Y()>FLAG_Y && stage.get1Y()<FLAG_Y+FLAG_H/3){
            isCleared = true;
            t_clear = ofGetSystemTime();
        }
        
        if(isCleared && ofGetSystemTime() - t_clear > 1000){
            thaw->toggleApp();
        }
    }
}

//--------------------------------------------------------------
void marioStage09::gotOSCMessage(ofxOscMessage m){
    
    if(m.getAddress() == "/mario/client/player"){
        phoneMarioX = m.getArgAsInt32(0);
        phoneMarioY = m.getArgAsInt32(1);
        phoneMarioVX = m.getArgAsInt32(3);
        phoneMarioVY = m.getArgAsInt32(4);
        pipe_id = m.getArgAsInt32(5);
    }
}

//--------------------------------------------------------------
void marioStage09::draw(){
    
    if(ofGetSystemTime() - t_reset < 1000){
        ofSetColor(0);
        ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
        
        ofSetColor(225);
        stage.assets->font.drawString("STAGE09", 500, 500);
    }
    else{
        
        if(fabs(thaw->accelZ)>0.8){
            ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
        }
        else{
            if(tilt){
                ofSetColor(255);
                ofCircle(tx, tz, 20);
                
                ofSetColor(100);
                ofRect(400, 500, 630, ofGetScreenHeight());
                ofRect(0, 0, ofGetScreenWidth(), 200);
            }
            else{
                //mario
                ofSetColor(255);
                ofEnableSmoothing();
                stage.draw();
                ofDisableSmoothing();
                
                ofEnableAlphaBlending();
                flag.draw(FLAG_X, FLAG_Y, FLAG_W, FLAG_H);
                ofDisableAlphaBlending();
            }
        }
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
        ofDrawBitmapString("(accel) : " + ofToString(thaw->accelX) + " " + ofToString(thaw->accelY) + " " + ofToString(thaw->accelZ), 10, 240);
    }
}


//--------------------------------------------------------------
void marioStage09::keyPressed  (int key){
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
    
    if(key == 't'){
        tilt = !tilt;
        if(tilt){
            tx = stage.get1X()+22;
            tz = ofGetScreenHeight()-50;
        }
        else{
            stage.set1X(tx-22);
        }
    }
    if(tilt){
        if(key==OF_KEY_UP){
            key_up = true;
        }
        else if(key==OF_KEY_DOWN){
            key_down = true;
        }
        else if(key==OF_KEY_LEFT){
            key_left = true;
        }
        else if(key==OF_KEY_RIGHT){
            key_right = true;
        }
    }
}

//--------------------------------------------------------------
void marioStage09::keyReleased  (int key){
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
    if(tilt){
        if(key==OF_KEY_UP){
            key_up = false;
        }
        else if(key==OF_KEY_DOWN){
            key_down = false;
        }
        else if(key==OF_KEY_LEFT){
            key_left = false;
        }
        else if(key==OF_KEY_RIGHT){
            key_right = false;
        }
    }
}

//--------------------------------------------------------------
void marioStage09::mouseMoved(int x, int y ){
}

//--------------------------------------------------------------
void marioStage09::mouseDragged(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage09::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage09::mouseReleased(int x, int y, int button){
}

void marioStage09::reset(){
    t_reset = ofGetSystemTime();
    isCleared = false;
    
    //init position
    stage.set1X(10);
    stage.set1Y(200);
}
