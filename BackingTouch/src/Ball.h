#pragma once

#define BOUNCE_FACTOR			0.7
#define ACCELEROMETER_FORCE		0.2
#define RADIUS					0


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
		pos.set(ofRandomWidth(), ofRandomHeight(), 0);
		vel.set(ofRandomf(), ofRandomf(), 0);
		
		float val = ofRandom( 200, 250 );
		col.set(val, val, val);
        tokenCol.set(255);
		
        switch(id){
            case 0: touchCol.setHex(0xEB6E9B); break;
            case 1: touchCol.setHex(0x009d88); break;
            case 2: touchCol.setHex(0xf7941d); break;
            case 3: touchCol.setHex(0xf70088); break;
            case 4: touchCol.setHex(0x003368); break;
            default: touchCol.setHex(0x333333); break;
        }
        bIntersectToken = false;
		bDragged = false;
	}
	
	//----------------------------------------------------------------	
    void update() {
        if(!bDragged){
            vel.x += ACCELEROMETER_FORCE * ofxAccelerometer.getForce().x * ofRandomuf();
            vel.y += -ACCELEROMETER_FORCE * ofxAccelerometer.getForce().y * ofRandomuf();        //this one is subtracted cos world Y is opposite to opengl Y
            
            // add vel to pos
            pos += vel;
            
            // check boundaries
            if(pos.x < RADIUS) {
                pos.x = RADIUS;
                vel.x *= -BOUNCE_FACTOR;
            } else if(pos.x >= ofGetWidth() - RADIUS) {
                pos.x = ofGetWidth() - RADIUS;
                vel.x *= -BOUNCE_FACTOR;
            }
            
            if(pos.y < RADIUS) {
                pos.y = RADIUS;
                vel.y *= -BOUNCE_FACTOR;
            } else if(pos.y >= ofGetHeight() - RADIUS) {
                pos.y = ofGetHeight() - RADIUS;
                vel.y *= -BOUNCE_FACTOR; 
            }
        }
	}
	
	//----------------------------------------------------------------
	void draw() {
		if( bDragged ){
            //if(!bIntersectToken){
                ofSetColor(touchCol);
                ofNoFill();
                //ofCircle(pos.x, pos.y, 40);
                ofLine(pos.x-40, pos.y, pos.x+40, pos.y);
                ofLine(pos.x, pos.y-40, pos.x, pos.y+40);
            /*
            }else{
                ofSetColor(tokenCol);
                ofNoFill();
                ofCircle(pos.x, pos.y, 50);
                ofLine(pos.x-50, pos.y, pos.x+50, pos.y);
                ofLine(pos.x, pos.y-50, pos.x, pos.y+50);
            }*/
		}else{
			ofSetColor(col);		
			ofCircle(pos.x, pos.y, RADIUS);
		}
	}
	
	//----------------------------------------------------------------	
	void moveTo(int x, int y) {
		pos.set(x, y, 0);
		vel.set(0, 0, 0);
	}
    
    Boolean checkIntersection(int x, int y){
        double diffX = (x-pos.x)*(x-pos.x);
        double diffY = (y-pos.y)*(y-pos.y);
        double d=sqrt(diffX+diffY);
        d<40 ? bIntersectToken = true : bIntersectToken = false;
        return bIntersectToken;
    }
};
