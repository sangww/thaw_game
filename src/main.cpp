#include "testApp.h"
#include "ofAppGlutWindow.h"
#include <Cocoa/Cocoa.h>

//--------------------------------------------------------------
int main(){
	ofAppGlutWindow window; // create a window
	// set width, height, mode (OF_WINDOW or OF_FULLSCREEN)
	ofSetupOpenGL(&window, 1440, 900, OF_WINDOW);
	ofRunApp(new testApp()); // start the app
}
