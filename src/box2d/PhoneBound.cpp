//
//  PhoneBound.cpp
//  bonjourServer
//
//  Created by Philipp Schoessler on 11/29/13.
//
//

#include "PhoneBound.h"


PhoneBound::PhoneBound(){}

//--------------------------------------------------------------

void PhoneBound::init(PhoneType::Value _flags)
{
    // size of iPhones in pixels on a MBP Retina with 1440x900 resolution
    
    if(_flags & PhoneType::IPHONE4)
    {
        width = 499;
        height = 252;
        pPivot.set(37, 40); //position of camera
        phoneType = "IPHONE4";
    }
    else if (_flags & PhoneType::IPHONE5)
    {
        width = 536;
        height = 252;
        pPivot.set(33, 42); //position of camera
        phoneType = "IPHONE5";
    }

}

//--------------------------------------------------------------

void PhoneBound::setupBlock()
{
    phoneBlock.addVertex(0, 0);
    phoneBlock.addVertex(width, 0);
    phoneBlock.addVertex(width, height);
    phoneBlock.addVertex(0, height);
    phoneBlock.addVertex(0, 0);
}

//--------------------------------------------------------------

void PhoneBound::setupContainer()
{
    phoneContainer.addVertex(0, 0);
    phoneContainer.addVertex(0, height);
    phoneContainer.addVertex(width, height);
    phoneContainer.addVertex(width, 0);
}

//--------------------------------------------------------------
// update phone's position and rotate around the camera's position
//--------------------------------------------------------------

void PhoneBound::update(float _x, float _y, float _angle)
{
    x = _x;
    y = _y;
    angle = _angle;
    pivot.set(x, y);
}

//--------------------------------------------------------------

void PhoneBound::updateBlock()
{
    theId = 1;
    //translate
    phoneBlock[0].set(x - pPivot.x, y - pPivot.y);
    phoneBlock[1].set(x + width - pPivot.x, y - pPivot.y);
    phoneBlock[2].set(x + width - pPivot.x, y + height - pPivot.y);
    phoneBlock[3].set(x - pPivot.x, y + height - pPivot.y);
    phoneBlock[4].set(x - pPivot.x, y - pPivot.y);
    
    //rotate around pivot
    for (int i = 0; i < phoneBlock.size(); i++) {
        phoneBlock[i] = phoneBlock[i].rotated(angle, pivot, ofVec3f(0,0,1));
    }
}

//--------------------------------------------------------------

void PhoneBound::updateContainer()
{
    theId = 2;
    //translate
    phoneContainer[0].set(x - pPivot.x, y - pPivot.y);
    phoneContainer[1].set(x - pPivot.x, y + height - pPivot.y);
    phoneContainer[2].set(x + width - pPivot.x, y + height - pPivot.y);
    phoneContainer[3].set(x + width - pPivot.x, y - pPivot.y);
    
    //rotate around pivot
    for (int i = 0; i < phoneContainer.size(); i++) {
        phoneContainer[i] = phoneContainer[i].rotated(angle, pivot, ofVec3f(0,0,1));
    }
}

//--------------------------------------------------------------

ofVec3f PhoneBound::getCentroidTop()
{
    ofVec3f centroid;
    if(theId == 1) centroid = phoneBlock[0].getMiddle(phoneBlock[1]);
    if(theId == 2) centroid = phoneContainer[0].getMiddle(phoneContainer[3]);
    return centroid;
}

//--------------------------------------------------------------

ofVec3f PhoneBound::getCentroidBottom()
{
    ofVec3f centroid;
    if(theId == 1) centroid = phoneBlock[2].getMiddle(phoneBlock[3]);
    if(theId == 2) centroid = phoneContainer[1].getMiddle(phoneContainer[2]);
    return centroid;
}

//--------------------------------------------------------------

ofVec3f PhoneBound::getCentroid()
{
    ofVec3f centroid;
    if(theId == 1) centroid = phoneBlock[2].getMiddle(phoneBlock[4]);
    if(theId == 2) centroid = phoneContainer[0].getMiddle(phoneContainer[2]);
    return centroid;
}

//--------------------------------------------------------------

ofPolyline PhoneBound::getBlock()
{
    return phoneBlock;
}

//--------------------------------------------------------------

ofPolyline PhoneBound::getContainer()
{
    return phoneContainer;
}

//--------------------------------------------------------------

string PhoneBound::getPhoneType()
{
    return phoneType;
}

//--------------------------------------------------------------

void PhoneBound::drawHelper()
{
    
}

//--------------------------------------------------------------

float PhoneBound::pythagoras(float _a, float _b)
{
    float c;
    c = pow(_a, 2) + pow(_b, 2);
    c = sqrt((double) c);
    return c;
}
