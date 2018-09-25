#include "marioStage06.h"

#define FLAG_X 1200
#define FLAG_Y 680
#define FLAG_W 90
#define FLAG_H 130

//--------------------------------------------------------------
void marioStage06::setup(){
    ofEnableAlphaBlending();
    
    thaw = thawAppManager::getInstance();
    
    //spritemanager
    stage.setup("settings.xml", "stage06.xml");
    stage.setEntry(true, true, true, true);
    
    //flag
    flag.loadImage("flag.png");
    
    //pipe animation
    shouldTeleport = false;
    falling_out_pipe = false;
    falling_into_pipe = false;
    stage.pipeAnimation = false;
    pipe_id = 0;
    
    //mode of interaction
    marioMode = 0; // 0: here
    availableMode = 5; // 1: inside, 2: water, 3: pipe, 4: force, 5: window
}

//--------------------------------------------------------------
void marioStage06::update(){
    
    if(!falling_into_pipe) stage.update(thaw->phoneX, thaw->phoneY, thaw->phoneW, thaw->phoneH, thaw->angle);
    if(falling_out_pipe){
        if(pipe_id==3){
            stage.set1Y(490);
            stage.pipeAnimation = true;
        }
        else if(pipe_id >0) {
            stage.set1Y(140);
            stage.kill1();
            falling_out_pipe = false;
        }
    }
    
    if(stage.get1X()>FLAG_X && stage.get1X()<FLAG_X+FLAG_W && stage.get1Y()>FLAG_Y && stage.get1Y()<FLAG_Y+FLAG_H/3){
        isCleared = true;
        t_clear = ofGetSystemTime();
    }
    
    if(isCleared && ofGetSystemTime() - t_clear > 1000){
        thaw->toggleApp();
    }
}

//--------------------------------------------------------------
void marioStage06::gotOSCMessage(ofxOscMessage m){
    
    if(m.getAddress() == "/mario/client/player"){
        phoneMarioX = m.getArgAsInt32(0);
        phoneMarioY = m.getArgAsInt32(1);
        phoneMarioVX = m.getArgAsInt32(3);
        phoneMarioVY = m.getArgAsInt32(4);
        //pipe_id = m.getArgAsInt32(5);
    }
}

//--------------------------------------------------------------
void marioStage06::draw(){
    
    if(ofGetSystemTime() - t_reset < 1000){
        ofSetColor(0);
        ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
        
        ofSetColor(225);
        stage.assets->font.drawString("STAGE06", 500, 500);
    }
    else{
        
        if(falling_into_pipe){
            long long t = ofGetSystemTime() - t_falling_into_pipe;
            stage.set1Y(stage.get1Y() + t/80);
            if(t>1000){
                falling_into_pipe = false;
                falling_out_pipe = true;
                t_falling_out_pipe = ofGetSystemTime();
            }
        }
        if(falling_out_pipe){
            long long t = ofGetSystemTime() - t_falling_out_pipe;
            if(t>800){
                stage.set1Y(stage.get1Y() + (t-800)/80);
                if(t>1200){
                    falling_out_pipe = false;
                    stage.pipeAnimation = false;
                }
            }
        }
        
        //mario
        ofSetColor(255);
        ofEnableSmoothing();
        stage.draw();
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
    }
}


//--------------------------------------------------------------
void marioStage06::keyPressed  (int key){
    if(!falling_out_pipe) stage.keyPressed(key);
    
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
    
    if(key == OF_KEY_DOWN){
        if(stage.get1X()>355 && stage.get1X()<400 && stage.get1Y() == 131){
            //go in to pipe
            pipe_id = 1;
            if(!falling_into_pipe){
                falling_into_pipe = true;
                t_falling_into_pipe = ofGetSystemTime();
            }
        }
        else if(stage.get1X()>670 && stage.get1X()<715 && stage.get1Y() == 131){
            //go in to pipe
            pipe_id = 2;
            if(!falling_into_pipe){
                falling_into_pipe = true;
                t_falling_into_pipe = ofGetSystemTime();
            }
        }
        else if(stage.get1X()>985 && stage.get1X()<1030 && stage.get1Y() == 131){
            //go in to pipe
            pipe_id = 3;
            if(!falling_into_pipe){
                falling_into_pipe = true;
                t_falling_into_pipe = ofGetSystemTime();
            }
        }
    }
}

//--------------------------------------------------------------
void marioStage06::keyReleased  (int key){
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
}

//--------------------------------------------------------------
void marioStage06::mouseMoved(int x, int y ){
}

//--------------------------------------------------------------
void marioStage06::mouseDragged(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage06::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage06::mouseReleased(int x, int y, int button){
}

void marioStage06::reset(){
    t_reset = ofGetSystemTime();
    isCleared = false;
    
    //init position
    stage.set1X(10);
    stage.set1Y(10);
}