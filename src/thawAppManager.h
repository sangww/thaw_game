#pragma once

#include "ofMain.h"
#include "ofxOsc.h"
#include "ofxBonjour.h"
#include "ofxLeastSquares.h"
#include "thawAppInterface.h"

using namespace ofxBonjour;
#define NUM_MSG_STRINGS 20
#define PORT_BONJOUR 7888
#define PORT_S 7788
#define PORT_R 7789

class thawAppManager : public ofBaseApp{

    public:
        void setup();
        void update();
        void draw();
        void addApp(thawAppInterface *app);
        void setApp(int i);
        void toggleApp();
    
        void keyPressed(int key);
        void keyReleased(int key);
        void mouseMoved(int x, int y);
        void mouseDragged(int x, int y, int button);
        void mousePressed(int x, int y, int button);
        void mouseReleased(int x, int y, int button);
    
        //util functions
        void drawFullScreenPattern();
        void drawPartScreenPattern(int x, int y, int size);
        void send(ofxOscMessage m);

    
 	static thawAppManager *singleton; // pointer to the singleton
	static thawAppManager *getInstance() {
		if (singleton == 0)
			singleton= new thawAppManager;
		return singleton;
	}
    
    //app management
    vector<thawAppInterface*> list_app;
    int cur_app;
    
    //network
    Server bonjourServer;
    ofxOscReceiver receiver;
    ofxOscSender sender;
    bool isConnected;
    
    //calibration
	vector<ofPoint> ref_pnt, measure_refs, measured_color;
	ofxLeastSquares ls;
    float axr, axg, byr, byg;
    bool isCalibrating, isRecalibrated;
    int refIndex;
    long long t_calib_trans, t_calib_stay, t_calib_begin, t_calib_stay_offset;
    
    //debug
    bool debug;
    bool pause;
    bool fullscreenpattern;
    
    //tracking
    int phoneX, phoneY, phoneVX, phoneVY;
    float accelX, accelY, accelZ;
    float angle, phoneW, phoneH;
    float r, g, b;
    bool out_index[4];
    int phoneX_offset, phoneY_offset;
    float pattern_size;
    long long t_lost;
    
    //onscreenmode
    bool onScreenMode;
    bool onTrackPattern;
    float distance;
    
    //touch on phone
    bool screenTouch;
    int touchX, touchY;
};
