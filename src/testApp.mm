#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
	//ofSetVerticalSync(true);
    
	ofSetFrameRate(30);
    ofSetFullscreen(true);
    
    stage00.setup();
    stage01.setup();
    stage02.setup();
    stage03.setup();
    stage04.setup();
    stage05.setup();
    stage06.setup();
    stage07.setup();
    stage08.setup();
    stage09.setup();
    stage10.setup();
    
    thawAppManager::getInstance()->setup();
    //thawAppManager::getInstance()->addApp(&stage00);
    thawAppManager::getInstance()->addApp(&stage01);
    thawAppManager::getInstance()->addApp(&stage04);
    thawAppManager::getInstance()->addApp(&stage02);
    thawAppManager::getInstance()->addApp(&stage03);
    thawAppManager::getInstance()->addApp(&stage05);
    thawAppManager::getInstance()->addApp(&stage06);
    thawAppManager::getInstance()->addApp(&stage07);
    //thawAppManager::getInstance()->addApp(&stage08);
    //thawAppManager::getInstance()->addApp(&stage09);
    thawAppManager::getInstance()->addApp(&stage10);
    
    thawAppManager::getInstance()->setApp(0);
}

//--------------------------------------------------------------
void testApp::update(){
    thawAppManager::getInstance()->update();
}

//--------------------------------------------------------------
void testApp::draw(){
    thawAppManager::getInstance()->draw();
}

//--------------------------------------------------------------
void testApp::keyPressed  (int key){
    
    if(key==' '){
        thawAppManager::getInstance()->toggleApp();
    }
    thawAppManager::getInstance()->keyPressed(key);
}

//--------------------------------------------------------------
void testApp::keyReleased  (int key){
    thawAppManager::getInstance()->keyReleased(key);
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){
    thawAppManager::getInstance()->mouseMoved(x, y);
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
    thawAppManager::getInstance()->mouseDragged(x, y, button);
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){
    thawAppManager::getInstance()->mousePressed(x, y, button);
}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
    thawAppManager::getInstance()->mouseReleased(x, y, button);
}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){
    
}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){
    
}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){
    
}