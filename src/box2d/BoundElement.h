//
//  BoundElement.h
//  bonjourServer
//
//  Created by Philipp Schoessler on 11/29/13.
//
//

#include <ofMain.h>
#include <iostream>
#include "PhoneBound.h"

#ifndef __bonjourServer__BoundElement__
#define __bonjourServer__BoundElement__

class BoundElement //: public PhoneBound
{
public:
    BoundElement();
    void init(PhoneBound *_phoneBound);
    void update();
    
    void setupBarriers();
    void updateBarriers(float _height);
    
    void setupGates();
    void updateGates(float _gateAngle);
    
    ofPolyline barrierBound;
    ofPolyline gateBound1;
    ofPolyline gateBound2;
    
    float widthB;
    float heightB;
    
    float widthG;
    float heightG;
    
    PhoneBound *pb;
    ofPolyline getPolyline();
    
private:
    string phoneType;
    float x;
    float y;
    float angle;
    float gateAngle;
    ofVec3f pivot;
    ofPoint assignedPivot;
};

#endif /* defined(__bonjourServer__BoundElement__) */