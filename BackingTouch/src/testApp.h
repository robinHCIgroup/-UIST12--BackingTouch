#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"

#define PORT 12345

#define SCR_W 640
#define SCR_H 960

#define NUM_OF_FRONT 1
#define NUM_OF_BACK 1
#define Y_OFFSET 218

#define TARGET_NUM 20
#define MAG_RATE 2
#define TARGET_R 15

typedef struct {
	float 	x;
	float 	y;
    float 	radius;
    
	bool 	bBeingDragged;
	bool 	bOver;
    bool    bDest;
//    bool    bHalo;
    bool    ingroup;
    int     xmindist;
    int     ymindist;
}	draggableVertex;



class testApp : public ofxiPhoneApp {
	
public:
    //Default Flow
	void setup();
	void update();
	void draw();
    
    //Setup Functions
    void resetTargets();
    void clearTargets();
    
    //Update Functions
    void canvasUpdate();
    void setupUpdate(int _oscX,int _oscY,bool _p);
    void stageUpdate(int x, int y, bool press, int bid);
    
    //Draw Functions
    void drawStage(int mode, int x, int y, bool press, int bid);
    
	//Touch Events
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
    int backPressed(int oscX, int oscY);
    int backReleased(int oscX, int oscY);
    int backMoved(int oscX, int oscY);
    
    //APIs
    int bubbleCursor(int tokenX, int tokenY, int bid);
    int judgeRadius(int x, int y, int bID);
    
    //Env. Variables
    bool bBGView;
    bool bBubble;
    bool bVisBack;    
    bool bTrans;
    bool bDTrans;
    bool bSetup;  
    
    float magWidgetR;
    int radius;
    int mode;
    
    //OSC related
    ofxOscReceiver	receiver;
    int oscVal[6];
    int oscValIndex;
    
    //Targets
    draggableVertex landmarks[TARGET_NUM];
    ofPoint lmPos[TARGET_NUM];
    
    
    //Front Touch
    ofPoint frontTouch[NUM_OF_FRONT];
    int fingerCID[NUM_OF_FRONT];
    
    //Back Touch
    ofPoint back[NUM_OF_BACK];
    bool press[NUM_OF_BACK];
    bool tempPress[NUM_OF_BACK];
    
    //Events and Targets
    int selectedIndex;
    bool isTargetSelected;
    bool isTargetTranslated;
    bool isTranslating;
    bool isDTransing;
    bool setupDone; 
    ofPoint prevTouch;
    ofPoint prevLandmarkPos;
    
    //setupUpdate
    ofPoint senRegion;
    float senW;
    float senH;
    
    //canvasUpdate
    ofPoint canvas;
    ofPoint prevCanvas;
    ofPoint canvasCenter;
    ofPoint focusZoom;
    float zoomDiff;
    float tempScale;
    float prevScale;
    float canvasScale;
    
    
    // User Test variables
    int testID;
    int iter;
    int src;
    int dest;
    long acqTime;
    long transTime;
    int acqError;
    int transError;
    int clutches;
    
    //Unused Functions
    void touchCancelled(ofTouchEventArgs &touch);
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    //Map
    ofImage ntumap;
    draggableVertex map;
    ofPoint maporigin;
    
    //Group Region
    /*this variable is for non rect group
    bool gpboundary[960][640];
    */
    bool grouping;
    bool hasbgroup;
    bool hasbchoose;
    ofPoint pregrouppoint;
    ofPoint nextgrouppoint;
    ofPoint minboundary;
    ofPoint maxboundary;
    ofPoint orginmin;
    int groupindex[TARGET_NUM];
    int groupitemnum;
    ofPoint choose;
    void resetgroup();
};


