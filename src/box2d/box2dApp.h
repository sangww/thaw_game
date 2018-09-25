#pragma once

#include "thawAppInterface.h"
#include "thawAppManager.h"

#include "PhoneBound.h"
#include "BoundElement.h"
#include "ofxBox2d.h"

class box2dApp : public thawAppInterface{
    
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
    
        void spawnParticle(int _x, int _y, ofVec2f _velocity);
        void deleteParticles();
    
    bool bDrawBounds;
    bool bDemo1;
    bool bDemo2;
    bool bDemo3;
    bool bDemo4;
    
    //base
    thawAppManager* thaw;
    long long  t_gap;
    
    //#phil
    ofxBox2d box2d;
    vector <ofPtr<ofxBox2dCircle> > circles;
    ofxBox2dEdge phoneBound; // phone's boundaries
    ofxBox2dEdge elementBound; // boundaries of extra Elements
    ofRectangle worldBound;
    PhoneBound myPhoneBound;
    BoundElement myBoundElement;
    float particleSize;
    float iParticleSize;
};
