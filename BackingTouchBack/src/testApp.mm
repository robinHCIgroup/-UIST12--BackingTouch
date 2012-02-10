#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    ofxiPhoneDisableIdleTimer();
    ofSetCircleResolution(80);
    ofSetFrameRate(60);
	ofBackground(0);
	ofxRegisterMultitouch(this);
    
    touches.assign(5, Ball());
	for(int i=0; i<NUM_OF_TOUCH; i++){
		backTouch[i].x = -1;
        backTouch[i].y = -1;
	}
    for(int i=0; i<touches.size(); i++){
		touches[i].init(i);
	}
    currentTouchID = -1;
	sender.setup( HOST, PORT );
    dataNum = NUM_OF_TOUCH*3;
    boxX = 40;
    boxY = 0;
    boxW = 560;
    boxH = 920;
}

//--------------------------------------------------------------
void testApp::update(){
    for(int i=0; i < touches.size(); i++){
		touches[i].update();
	}
    ofxOscMessage m;
    m.setAddress( "/DATA");
    for(int i=0; i < dataNum ; i++){
        m.addIntArg( touchStats[i] );
    }
    printf("Osc: %d %d %d\n",touchStats[0],touchStats[1],touchStats[2]);
    sender.sendMessage( m );
}

//--------------------------------------------------------------
void testApp::draw(){
    ofNoFill();
    ofSetColor(148,198,221);
    ofPushStyle();
    for(int i = 0; i< touches.size(); i++){
        int touchX = touches[i].pos.x;
        int touchY = touches[i].pos.y;
        if(touchX > boxX && touchX < boxX+boxW && touchY < boxY+boxH){
            touches[i].draw();
        }
    }
	ofPopStyle();
    ofSetColor(0);
    ofNoFill();
}

//--------------------------------------------------------------
void testApp::exit(){

}
//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    touches[touch.id].moveTo(touch.x,touch.y);
    touches[touch.id].bDragged = true;
    if(touch.x > boxX && touch.x < boxX+boxW && touch.y < boxY+boxH){
        touchStats[0] = ofGetWidth() - touch.x; 
        touchStats[1] = touch.y;
        touchStats[2] = 1;
        currentTouchID = touch.id;
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
    touches[touch.id].moveTo(touch.x,touch.y);
    touches[touch.id].bDragged = true;
    if(touch.x > boxX && touch.x < boxX+boxW && touch.y < boxY+boxH){
        if(currentTouchID == -1) currentTouchID = touch.id;
        touchStats[0] = ofGetWidth() - touch.x; 
        touchStats[1] = touch.y;
        touchStats[2] = 1;
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    touches[touch.id].bDragged = false;
    if(touch.x > boxX && touch.x < boxX+boxW && touch.y < boxY+boxH){
        touchStats[0] = ofGetWidth() - touch.x; 
        touchStats[1] = touch.y;
        touchStats[2] = 0;
        currentTouchID = -1;
    }else{
        if(touch.id == currentTouchID){
            touchStats[2] = 0;
            currentTouchID = -1;
        }
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}


//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args){

}

