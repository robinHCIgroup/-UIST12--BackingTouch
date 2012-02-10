#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"
#include "Ball.h"

#define HOST "DNIPhone.local"
#define PORT 12345

#define NUM_OF_TOUCH 2

class testApp : public ofxiPhoneApp {

	public:
		void setup();
		void update();
		void draw();
		void exit();
		
		void touchDown(ofTouchEventArgs &touch);
		void touchMoved(ofTouchEventArgs &touch);
		void touchUp(ofTouchEventArgs &touch);
		void touchDoubleTap(ofTouchEventArgs &touch);
		void touchCancelled(ofTouchEventArgs &touch);

		void lostFocus();
		void gotFocus();
		void gotMemoryWarning();
		void deviceOrientationChanged(int newOrientation);
    
        vector <Ball> touches;
        int touchStats[NUM_OF_TOUCH*3];
        int dataNum;
        
        int boxX;
        int boxY;
        int boxW;
        int boxH;
        int currentTouchID;
        ofPoint backTouch[NUM_OF_TOUCH];
		ofxOscSender sender;
};

