#pragma once

#include "ofMain.h"

#include "thawAppManager.h"
#include "marioStage00.h"
#include "marioStage01.h"
#include "marioStage02.h"
#include "marioStage03.h"
#include "marioStage04.h"
#include "marioStage05.h"
#include "marioStage06.h"
#include "marioStage07.h"
#include "marioStage08.h"
#include "marioStage09.h"
#include "marioStage10.h"

class testApp : public ofBaseApp{
    
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
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);
    
    marioStage00 stage00;
    marioStage01 stage01;
    marioStage02 stage02;
    marioStage03 stage03;
    marioStage04 stage04;
    marioStage05 stage05;
    marioStage06 stage06;
    marioStage07 stage07;
    marioStage08 stage08;
    marioStage09 stage09;
    marioStage10 stage10;

};
