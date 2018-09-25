//
//  PhoneBound.h
//  bonjourServer
//
//  Created by Philipp Schoessler on 11/29/13.
//
//

#ifndef __bonjourServer__PhoneBound__
#define __bonjourServer__PhoneBound__

#include "ofMain.h"
#include <iostream>

struct PhoneType
{
    enum Value
    {
        IPHONE4 = 1,
        IPHONE5 = 2
    };
};

class PhoneBound
{
public:
    
    PhoneBound();
    void init(PhoneType::Value _flags);
    void setupBlock();
    void setupContainer();
    void update(float _x, float _y, float _angle);
    void updateBlock();
    void updateContainer();
    void drawHelper();
    
    ofPolyline getBlock();
    ofPolyline getContainer();
    ofVec3f getCentroidTop();
    ofVec3f getCentroidBottom();
    ofVec3f getCentroid();
    string getPhoneType();
    
    float x;
    float y;
    float width;
    float height;
    float angle;
    ofVec3f pivot;
    ofPoint pPivot;
    int theId;

    bool bShowBound;
    ofPolyline phoneBlock;
    ofPolyline phoneContainer;

private:
    string phoneType;
    float pythagoras(float _a, float _b);
};

#endif /* defined(__bonjourServer__PhoneBound__) */