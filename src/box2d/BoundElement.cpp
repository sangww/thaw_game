//
//  BoundElement.cpp
//  bonjourServer
//
//  Created by Philipp Schoessler on 11/29/13.
//
//

#include "BoundElement.h"



BoundElement::BoundElement(){}

//--------------------------------------------------------------

void BoundElement::init(PhoneBound *_phoneBound)
{
    pb = _phoneBound;
    phoneType = pb->getPhoneType();
    assignedPivot = pb->pPivot;
}

//--------------------------------------------------------------

void BoundElement::update()
{
    x = pb->x;
    y = pb->y;
    angle = pb->angle;
    pivot = pb->pivot;
}

//--------------------------------------------------------------


void BoundElement::setupBarriers()
{
    widthB = 40;
    heightB = 100;
    
    barrierBound.addVertex(0, 0);
    barrierBound.addVertex(widthB, 0);
    barrierBound.addVertex(widthB, heightB);
    barrierBound.addVertex(0, heightB);
    barrierBound.addVertex(0, 0);
}

//--------------------------------------------------------------

void BoundElement::updateBarriers(float _height)
{
    heightB + _height;
    
    //translate
    barrierBound[0].set(x - assignedPivot.x, y - assignedPivot.y - heightB);
    barrierBound[1].set(x + widthB - assignedPivot.x, y - assignedPivot.y - heightB);
    barrierBound[2].set(x + widthB - assignedPivot.x, y + heightB - assignedPivot.y);
    barrierBound[3].set(x - assignedPivot.x, y + heightB - assignedPivot.y);
    barrierBound[4].set(x - assignedPivot.x, y - assignedPivot.y - heightB);
    
    //rotate around pivot
    for (int i = 0; i < barrierBound.size(); i++) {
        barrierBound[i] = barrierBound[i].rotated(angle, pivot, ofVec3f(0,0,1));
    }
    
}

//--------------------------------------------------------------

void BoundElement::setupGates()
{
    widthG = pb->width/2;
    heightG = 20;
    
    gateBound1.addVertex(0, 0);
    gateBound1.addVertex(widthG, 0);
    gateBound1.addVertex(widthG, heightG);
    gateBound1.addVertex(0, heightG);
    gateBound1.addVertex(0, 0);
    
    gateBound2.addVertex(0, 0);
    gateBound2.addVertex(widthG, 0);
    gateBound2.addVertex(widthG, heightG);
    gateBound2.addVertex(0, heightG);
    gateBound2.addVertex(0, 0);
    
    
}

//--------------------------------------------------------------

void BoundElement::updateGates(float _gateAngle)
{
    gateAngle = _gateAngle * -1;
    ofVec3f gatePivot1 = pb->phoneBlock[0];
    ofVec3f gatePivot2 = pb->phoneBlock[1];
    
    //translate
    gateBound1[0].set(x - assignedPivot.x, y - assignedPivot.y);
    gateBound1[1].set(x + widthG - assignedPivot.x, y - assignedPivot.y);
    gateBound1[2].set(x + widthG - assignedPivot.x, y + heightG - assignedPivot.y);
    gateBound1[3].set(x - assignedPivot.x, y + heightG - assignedPivot.y);
    gateBound1[4].set(x - assignedPivot.x, y - assignedPivot.y);
    
    gateBound2[0].set(x - assignedPivot.x + 2*widthG, y - assignedPivot.y);
    gateBound2[1].set(x - assignedPivot.x + 2*widthG, y + heightG - assignedPivot.y);
    gateBound2[2].set(x - assignedPivot.x + widthG, y + heightG - assignedPivot.y);
    gateBound2[3].set(x - assignedPivot.x + widthG, y - assignedPivot.y);
    gateBound2[4].set(x - assignedPivot.x + 2*widthG, y - assignedPivot.y);
    
    
    //rotate around pivot
    for (int i = 0; i < gateBound1.size(); i++) {
        gateBound1[i] = gateBound1[i].rotated(angle, pivot, ofVec3f(0,0,1));
        gateBound2[i] = gateBound2[i].rotated(angle, pivot, ofVec3f(0,0,1));
    }
    
    //openGate according to gateAngle
    for (int i = 0; i < gateBound1.size(); i++) {
        gateBound1[i] = gateBound1[i].rotated(gateAngle, gatePivot1, ofVec3f(0,0,1));
        gateBound2[i] = gateBound2[i].rotated(gateAngle * -1, gatePivot2, ofVec3f(0,0,1));
    }

    
}

//--------------------------------------------------------------

ofPolyline BoundElement::getPolyline()
{
    return barrierBound;
}