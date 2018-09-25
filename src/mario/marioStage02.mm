#include "marioStage02.h"

#define MARGIN_X 50
#define MARGIN_Y 30

#define FLAG_X 1200
#define FLAG_Y 680
#define FLAG_W 90
#define FLAG_H 130

//--------------------------------------------------------------
void marioStage02::setup(){
    ofEnableAlphaBlending();
    
    thaw = thawAppManager::getInstance();
    
    //spritemanager
    stage.setup("settings.xml", "stage02.xml");
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
    availableMode = 1; // 0:box, 1:inside/shoot
}

//--------------------------------------------------------------
void marioStage02::update(){
    
	stage.update(thaw->phoneX, thaw->phoneY, thaw->phoneW, thaw->phoneH, thaw->angle);
    
    vector<ofPoint> poly;
    poly.push_back( ofPoint(thaw->phoneX+20, thaw->phoneY+20) );
    poly.push_back( ofPoint(thaw->phoneX+thaw->phoneW-20, thaw->phoneY+20) );
    poly.push_back( ofPoint(thaw->phoneX+thaw->phoneW-20, thaw->phoneY+thaw->phoneH-20) );
    poly.push_back( ofPoint(thaw->phoneX+20, thaw->phoneY+thaw->phoneH-20) );
    if(ofInsidePoly(ofPoint(stage.get1X(), stage.get1Y()), poly)){
        if(thaw->isConnected && marioMode == 0 && availableMode >0 && thaw->onTrackPattern){
            marioMode = availableMode;
            stage.teleportPlayer1(false, thaw->phoneX, thaw->phoneY, 0, 0);
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
void marioStage02::gotOSCMessage(ofxOscMessage m){
    
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
}

//--------------------------------------------------------------
void marioStage02::draw(){
    
    if(ofGetSystemTime() - t_reset < 1000){
        ofSetColor(0);
        ofRect(0, 0, ofGetScreenWidth(), ofGetScreenHeight());
        
        ofSetColor(225);
        stage.assets->font.drawString("STAGE03", 500, 500);
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
void marioStage02::keyPressed  (int key){
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
void marioStage02::keyReleased  (int key){
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
void marioStage02::mouseMoved(int x, int y ){
}

//--------------------------------------------------------------
void marioStage02::mouseDragged(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage02::mousePressed(int x, int y, int button){
}

//--------------------------------------------------------------
void marioStage02::mouseReleased(int x, int y, int button){
}

void marioStage02::reset(){
    t_reset = ofGetSystemTime();
    isCleared = false;
    
    //init position
    stage.set1X(10);
    stage.set1Y(200);
}
