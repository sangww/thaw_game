#pragma once

#include "ofMain.h"
#include "thawAppInterface.h"
#include "thawAppManager.h"

#define NUM_ICON 7

class dragdropApp : public thawAppInterface{
    
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
    
    //base
    thawAppManager* thaw;
    long long  t_gap;
    
    //icons
    ofImage icons[NUM_ICON];
    ofPoint pos_icons[NUM_ICON];
    bool loc_icons[NUM_ICON];
    int selected, selectedRemote;
    int drag_x, drag_y, pivot_x, pivot_y, offset_x, offset_y;
    
    //tracking
    bool onPhone;
};
