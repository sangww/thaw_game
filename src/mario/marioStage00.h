#pragma once

#include "ofMain.h"
#include "thawAppInterface.h"
#include "thawAppManager.h"
#include "StateRunning.h"

class marioStage00 : public thawAppInterface{
    
	public:
        void setup();
        void update();
        void draw();
        
        void keyPressed(int key);
        void keyReleased(int key);
        void mouseMoved(int x, int y);
        void mouseDragged(int x, int y, int button);
        void mousePressed(int x, int y, int button);
        void mouseReleased(int x, int y, int button);
        void gotOSCMessage(ofxOscMessage m);
    
        void reset();
    
    //intro
    long long t_clear;
    long long t_reset;
    bool isCleared = false;
    
    //base
    thawAppManager* thaw;
	StateRunning stage;
    
    ofImage flag;
    
    //mode
    int marioMode;
    int availableMode;
    
    //mario
    int phoneMarioX, phoneMarioY, phoneMarioVX, phoneMarioVY;
    bool shouldTeleport;
    int pipe_id;
    bool falling_out_pipe;
    long long t_falling_out_pipe;
};
