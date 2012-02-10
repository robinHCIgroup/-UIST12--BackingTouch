#pragma once

#define BOUNCE_FACTOR			0.7
#define ACCELEROMETER_FORCE		0.2
#define RADIUS					0
#define FingerR                 88

class Ball {
public:
	ofPoint pos;
	ofPoint vel;
	ofColor col;
	ofColor touchCol;
    ofColor tokenCol;
	bool bDragged;
    bool bIntersectToken;
	
	//----------------------------------------------------------------	
	void init(int id) {
		pos.set(-99, -99, 0);
		switch(id){
            case 0: touchCol.setHex(0xFFFFFF); break;
            case 1: touchCol.setHex(0xFFFFFF); break;
            case 2: touchCol.setHex(0xFFFFFF); break;
            case 3: touchCol.setHex(0xFFFFFF); break;
            case 4: touchCol.setHex(0xFFFFFF); break;
            default: touchCol.setHex(0xFFFFFF); break;
        }
		bDragged = false;
	}
	
	//----------------------------------------------------------------	
    void update() {
	}
	
	//----------------------------------------------------------------
	void draw() {
		if( bDragged ){
            ofSetColor(touchCol);
            ofNoFill();
            ofCircle(pos.x, pos.y, FingerR);
            ofLine(pos.x-FingerR, pos.y, pos.x+FingerR, pos.y);
            ofLine(pos.x, pos.y-FingerR, pos.x, pos.y+FingerR);
            ofFill();
            ofCircle(pos.x, pos.y, FingerR/2);
		}
	}
	
	//----------------------------------------------------------------	
	void moveTo(int x, int y) {
		pos.set(x, y, 0);
		vel.set(0, 0, 0);
	}
};
