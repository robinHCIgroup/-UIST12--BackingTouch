#include <math.h>
#include "testApp.h"
#include "MyGuiView.h"

MyGuiView * myGuiViewController;

//--------------------------------------------------------------
void testApp::setup(){	
	myGuiViewController	= [[MyGuiView alloc] initWithNibName:@"MyGuiView" bundle:nil];
	[ofxiPhoneGetUIWindow() addSubview:myGuiViewController.view];
    ofxiPhoneDisableIdleTimer();
	ofxRegisterMultitouch(this);
    ofSetCircleResolution(80);
    ofBackground(0);	
	ofSetFrameRate(60);
    
    bBGView = false;
    bTrans = false;
    bSetup = false;
    bDTrans = true;
    bBubble = true;
    bVisBack = false;
    magWidgetR = TARGET_R * MAG_RATE;
	radius = TARGET_R;
    mode = 2;
    
    //Front Touch variables
    for(int i = 0 ; i < NUM_OF_FRONT ; i ++){        
        frontTouch[i].x = -1;
        frontTouch[i].y = -1;
        fingerCID[i] = -1;
    }
    
    for(int i = 0 ; i < NUM_OF_BACK ; i++){
        back[i].x = -1;
        back[i].y = -1;
        press[i] = false;
        tempPress[i] = false;
    }
    
    senRegion.x = 320;
    senRegion.y = 90 + Y_OFFSET;
    senW = 320;
    senH = 480;
    setupDone = true;
    focusZoom.x = float(SCR_W/2);
    focusZoom.y = float(SCR_H/2);
    
    // listen to the given OSC port
	cout << "listening for osc messages on port " << PORT << "\n";
	receiver.setup( PORT );
    
    if(!bSetup){ 
        resetTargets();
    }
    else{
        clearTargets();
    }
}
//--------------------------------------------------------------
void testApp::update(){
	// check OSC data
	while( receiver.hasWaitingMessages() ){
		ofxOscMessage m;
		receiver.getNextMessage( &m );
        oscValIndex = 0;  
        for( int i=0; i<m.getNumArgs(); i++ ){
            if( m.getArgType( i ) == OFXOSC_TYPE_INT32 ){
                oscVal[oscValIndex] = m.getArgAsInt32( i );
                ++oscValIndex;
            }
        }
	}	
    
    //get parameters of the current sensing region
    float SEN_L = senRegion.x - senW/2; 
    float SEN_R = senRegion.x + senW/2;
    float SEN_U = senRegion.y - senH/2; 
    float SEN_D = senRegion.y + senH/2; 
    float cdRatio = float(SCR_H)/senH;
    
    //Handle back events
    if(oscVal[0] > SEN_L && oscVal[0] < SEN_R){
        back[0].x = (oscVal[0]-SEN_L)*cdRatio;
    }
    if(oscVal[1] > SEN_U && oscVal[1] < SEN_D){
        back[0].y = (oscVal[1]-SEN_U)*cdRatio;   
    }
    if(oscVal[2] >0){
        tempPress[0] = true;
    }else{
        tempPress[0] = false;                
    }
    if(tempPress[0]){
        if(!press[0]){
            backPressed(oscVal[0],oscVal[1]);
            press[0] = true;
        }else{
            backMoved(oscVal[0],oscVal[1]);
        }
    }else{
        if(press[0]){
            backReleased(oscVal[0],oscVal[1]);
            press[0] = false;
        }
    }
    canvasUpdate();
}

//--------------------------------------------------------------
void testApp::draw(){
    if(bSetup){
        setupUpdate(oscVal[0],oscVal[1]-Y_OFFSET, press[0]);
    }else{
        stageUpdate(back[0].x, back[0].y, press[0], 0);
    }
    drawStage(mode, back[0].x, back[0].y, press[0], 0);
}
//---------------------------------------------
void testApp::setupUpdate(int _oscX,int _oscY,bool _p){
    float senL = senRegion.x - senW/2; 
    float senR = senRegion.x + senW/2;
    float senU = senRegion.x - senH/2; 
    float senD = senRegion.x + senH/2; 
    float cdRatio = float(SCR_H)/senH;
    ofNoFill();
    ofSetColor(0,0,192);
    ofRect(senL, senU-Y_OFFSET, senW, senH); 
    ofLine(senL, senU-Y_OFFSET, senR, senD-Y_OFFSET);
    ofLine(senR, senU-Y_OFFSET, senL, senD-Y_OFFSET);
    if(_p){
        ofLine(_oscX-10,_oscY,_oscX+10,_oscY);
        ofLine(_oscX,_oscY-10,_oscX,_oscY+10);
    }
}

void testApp::clearTargets(){
    for (int i = 0; i < TARGET_NUM; i++){
        landmarks[i].bBeingDragged 	= false;
		landmarks[i].bOver 			= false;
//        landmarks[i].bHalo          = false;
        landmarks[i].x = -99;
        landmarks[i].y = -99;
        lmPos[i].x = landmarks[i].x;
        lmPos[i].y = landmarks[i].y;
		landmarks[i].radius = radius;
	}
    canvas.x = 0;
    canvas.y = 0;
    prevCanvas.x = 0;
    prevCanvas.y = 0;
    prevScale = 1;
    tempScale = 0;
    
    isTargetSelected = false;
    isTargetTranslated = false;
    isDTransing = false;
    isTranslating = false;
}

void testApp::resetTargets(){
    int offsetX,offsetY;
    int newTarget = random() % TARGET_NUM;
    if(newTarget>=TARGET_NUM) newTarget = TARGET_NUM -1;
    
    for (int i = 0; i < TARGET_NUM; i++){
        landmarks[i].bBeingDragged 	= false;
		landmarks[i].bOver 			= false;
//        landmarks[i].bHalo          = false;
        offsetX = random() % 104 - 52;
        offsetY = random() % 116 - 58;
        
        landmarks[i].x = 64+ 128 * (i%5) + int(offsetX);
        landmarks[i].y = 70+ 142 * int(i/5) + int(offsetY);
        lmPos[i].x = landmarks[i].x;
        lmPos[i].y = landmarks[i].y;
        
        if(i == newTarget){
            landmarks[i].bDest          = true;
        }else{
            landmarks[i].bDest          = false;
        }
		landmarks[i].radius = radius;
	}
    canvas.x = 0;
    canvas.y = 0;
    prevCanvas.x = 0;
    prevCanvas.y = 0;
    prevScale = 1;
    tempScale = 0;
    
    selectedIndex = -1;
    isTargetSelected = false;
    isTargetTranslated = false;
    isDTransing = false;
    isTranslating = false;
} 
//--------------------------------------------------------------

void testApp::canvasUpdate(){
    canvasScale = prevScale+tempScale;
    canvasCenter.x = -(prevCanvas.x + canvas.x);
    canvasCenter.y = -(prevCanvas.y + canvas.y);
    for (int i = 0; i < TARGET_NUM; i++){
        landmarks[i].x = -(prevCanvas.x + canvas.x) + lmPos[i].x ;
        landmarks[i].y = -(prevCanvas.y + canvas.y) + lmPos[i].y ;
        landmarks[i].x = canvasScale*(landmarks[i].x - focusZoom.x)+focusZoom.x;
        landmarks[i].y = canvasScale*(landmarks[i].y - focusZoom.y)+focusZoom.y;
    }
    radius= float(TARGET_R) * canvasScale;
}


//--------------------------------------------------------------
void testApp::stageUpdate(int _x, int _y, bool press, int bID){
    float dX,dY,targetDist;
    float FBDist;
    if(bBubble){
        selectedIndex = bubbleCursor(_x,_y,0);
        dX = _x - landmarks[selectedIndex].x;
        dY = _y - landmarks[selectedIndex].y;
        targetDist = sqrt(dX*dX + dY*dY);
    }else{
        selectedIndex = judgeRadius(_x,_y,0);
        if(selectedIndex>=-1){
            dX = _x - landmarks[selectedIndex].x;
            dY = _y - landmarks[selectedIndex].y;
            targetDist = sqrt(dX*dX + dY*dY);
        }
    }
    ofSetColor(255);
    ofNoFill();
    if(bDTrans){
        ofEnableAlphaBlending();
        ofSetColor(255,255,255,78);
        if(isDTransing){
            if(fingerCID[0]>-1){
                if(!press){
                    landmarks[fingerCID[0]].x = prevLandmarkPos.x;
                    landmarks[fingerCID[0]].y = prevLandmarkPos.y;
                }else{
                    landmarks[fingerCID[0]].x= _x;
                    landmarks[fingerCID[0]].y= _y;
                }
                dX = _x - frontTouch[0].x;
                dY = _y - frontTouch[0].y;
                FBDist = sqrt(dX*dX + dY*dY);
                if(FBDist>800) FBDist = 800;
                
                ofEnableSmoothing();
                ofSetLineWidth(radius - ((radius-1)*FBDist)/800.);
                ofLine(frontTouch[0].x,frontTouch[0].y,landmarks[fingerCID[0]].x,landmarks[fingerCID[0]].y);
                ofSetLineWidth(1);
                ofDisableSmoothing();
            }
        }else{
            if(isTranslating){
                landmarks[fingerCID[0]].x= frontTouch[0].x;
                landmarks[fingerCID[0]].y= frontTouch[0].y;
            }
            if(press){
                ofFill();
                if(selectedIndex>-1){
                    if(frontTouch[0].x>-1 && frontTouch[0].y>-1){
                        
                    }else{
                        ofCircle(landmarks[selectedIndex].x,landmarks[selectedIndex].y,radius+5);
                        if(bBubble){
                            ofCircle(_x,_y,targetDist);
                        }
                    }
                }
                
            }
        }
        ofDisableAlphaBlending();
    }
    
    for(int i = 0; i < TARGET_NUM ; i++){
        int circleX = landmarks[i].x;
        int circleY = landmarks[i].y;     
        int circleR = radius;
        landmarks[i].radius = radius;
        ofFill();
        if(!landmarks[i].bOver){
            if(landmarks[i].bDest){
                ofSetColor(235,110,155);
            }else{
                ofSetColor(34,174,230);
            }
        }else{
            ofSetColor(0,255,0); 
        }
        ofCircle(circleX, circleY, circleR);
        ofNoFill();
        ofSetColor(52);
        ofCircle(circleX, circleY, circleR);                
    }
    
    if(bDTrans){
        if(isDTransing){
            if(fingerCID[0]>-1){
                ofEnableAlphaBlending();
                ofFill();
                ofSetColor(255,255,255,78);
                ofCircle(frontTouch[0].x,frontTouch[0].y, magWidgetR);
                ofNoFill();
                ofDisableAlphaBlending();
            }else{
                ofSetColor(255,0,0);
                ofLine(_x-10,_y,_x+10,_y);
                ofLine(_x,_y-10,_x,_y+10);
            }
        }else{
            if(press){
                ofSetColor(0,255,0);
                if(frontTouch[0].x>-1 && frontTouch[0].y>-1){
                    ofEnableAlphaBlending();
                    ofFill();
                    ofSetColor(255,255,255,78);
                    ofCircle(_x,_y,22);
                    ofNoFill();
                    ofDisableAlphaBlending();
                }else{
                    ofLine(_x-10,_y,_x+10,_y);
                    ofLine(_x,_y-10,_x,_y+10);
                }
            }else{
                
            }
            if(isTranslating){
                ofEnableAlphaBlending();
                ofFill();
                ofSetColor(255,255,255,78);
                ofCircle(frontTouch[0].x,frontTouch[0].y, magWidgetR);
                ofSetColor(255,255,255,192);
                ofLine(frontTouch[0].x-magWidgetR,frontTouch[0].y,frontTouch[0].x+magWidgetR,frontTouch[0].y);
                ofLine(frontTouch[0].x,frontTouch[0].y-magWidgetR,frontTouch[0].x,frontTouch[0].y+magWidgetR);
                ofNoFill();
                ofDisableAlphaBlending();
            }
        }
    }
}

//--------------------------------------------------------------
void testApp::drawStage(int mode, int x, int y, bool press, int bID){
    //Draw Additional Informations
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    if( touch.id < NUM_OF_FRONT  ){
        frontTouch[touch.id].x = touch.x;
        frontTouch[touch.id].y = touch.y;
        int i = -1;
        if(press[0]){ // back finger is pressing
            isDTransing = true;
            if(bBubble){
                i = bubbleCursor(back[0].x, back[0].y, 0);
            }else{
                i = judgeRadius(back[0].x, back[0].y, 0);
            }
            if(i>=0){
                fingerCID[0] = i;
                landmarks[i].bOver = true;
                if(landmarks[i].bDest){
                    isTargetSelected = true;
                }
                if(bDTrans){ 
                    prevLandmarkPos.x = landmarks[i].x;
                    prevLandmarkPos.y = landmarks[i].y;
                    landmarks[i].bBeingDragged = true;
                }
            }
        }else{
            if(!isDTransing){
                i = judgeRadius(touch.x, touch.y, 0);
                if(i>=0){
                    isTranslating = true;
                    fingerCID[0] = i;
                    landmarks[i].bOver = true;
                    if(landmarks[i].bDest){
                        isTargetSelected = true;                        
                    }
//                    prevLandmarkPos.x = landmarks[i].x;
//                    prevLandmarkPos.y = landmarks[i].y;
                    landmarks[i].bBeingDragged = true;
                }else{
                    prevTouch.x = touch.x;
                    prevTouch.y = touch.y;
                }
            }
        }
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
    if( touch.id < NUM_OF_FRONT){
        frontTouch[touch.id].x = touch.x;
        frontTouch[touch.id].y = touch.y;
        if(!isDTransing){
            if(!press[0]){ //Pan
                if(!isTranslating){
                    canvas.x = (prevTouch.x - touch.x)/canvasScale;
                    canvas.y = (prevTouch.y - touch.y)/canvasScale;
                }
            }else{ //Zoom            
            }
        }else{
            
        }
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    frontTouch[touch.id].x = -1;
    frontTouch[touch.id].y = -1;
    if( touch.id < NUM_OF_FRONT){
        if(fingerCID[0]>=0){
            landmarks[fingerCID[0]].bBeingDragged = false;	            
            if(!landmarks[fingerCID[0]].bDest) landmarks[fingerCID[0]].bOver = false;
            int index = fingerCID[0];
            if(bDTrans){
                if(index>=0){
                    if(isDTransing){
                        lmPos[index].x = (back[0].x-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                        lmPos[index].y = (back[0].y-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                        isDTransing = false;
                    }
                    if(isTranslating){
                        lmPos[index].x = (touch.x-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                        lmPos[index].y = (touch.y-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                        isTranslating = false;
                    }
                    isTargetTranslated = true;
                    canvas.x = 0;
                    canvas.y = 0;
                }
            }
            fingerCID[0] = -1;
        }else{
            isDTransing = false;
            if(!press[0]){ //Pan
                prevCanvas.x += canvas.x;
                prevCanvas.y += canvas.y;
                canvas.x = 0;
                canvas.y = 0;
            }else{ //Zoom
            }
        }
    }
}

//-------------------------------------------------------------- lense/selected
int testApp::backPressed(int oscX, int oscY){
    if(bSetup){
        
    }else{
        if(frontTouch[0].x>-1 && frontTouch[0].y>-1){
            float dX = back[0].x;
            float dY = back[0].y;
            float diff = sqrt(dX*dX + dY*dY);
            zoomDiff = diff;
            prevScale += tempScale;
            tempScale = 0;
        }
    }
}
//--------------------------------------------------------------
int testApp::backReleased(int oscX, int oscY){
    prevTouch.x = frontTouch[0].x;
    prevTouch.y = frontTouch[0].y;
    if(bSetup){
        
    }else{
        if(isTargetTranslated){
        }else{
        }
    }
}
//--------------------------------------------------------------
int testApp::backMoved(int oscX, int oscY){
    if(bSetup){
        
    }else{
        if(!isDTransing){
            prevCanvas.x += canvas.x;
            prevCanvas.y += canvas.y;
            canvas.x = 0;
            canvas.y = 0;
            if(frontTouch[0].x>-1 && frontTouch[0].y>-1){
                float dX = back[0].x;
                float dY = back[0].y;
                float diff = sqrt(dX*dX + dY*dY);
                tempScale = -(diff-zoomDiff)/500.;
                if(prevScale+tempScale<=0.1){
                    tempScale = 0.1-prevScale;
                }
                if(prevScale+tempScale>=2){
                    tempScale = 2-prevScale;
                }
            }
        }
        
        if (isTranslating) {
            prevCanvas.x += canvas.x;
            prevCanvas.y += canvas.y;
            canvas.x = 0;
            canvas.y = 0;
            float dX = back[0].x;
            float dY = back[0].y;
            float diff = sqrt(dX*dX + dY*dY);
            tempScale = -(diff-zoomDiff)/500.;
            if(prevScale+tempScale<=0.1){
                tempScale = 0.1-prevScale;
            }
            if(prevScale+tempScale>=2){
                tempScale = 2-prevScale;
            }
        }
    }

}


//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
    if( myGuiViewController.view.hidden ){
        if( touch.id == 0 ){
            if(touch.x<80 && touch.y<80)myGuiViewController.view.hidden = NO;
            if(touch.x>560 && touch.y<80)resetTargets();
        }
	}
}
//--------------------------------------------------------------

int testApp::judgeRadius(int x, int y, int bID){
    int index = -1;
    int minR = 640+960;
    for (int i = 0; i < TARGET_NUM; i++){
        float diffx = x - landmarks[i].x;
        float diffy = y - landmarks[i].y;
        float dist = sqrt(diffx*diffx + diffy*diffy);
        if (dist < landmarks[i].radius){// && !landmarks[i].bHalo){
            if(dist<minR){
                minR = dist;
                index = i;
            }
        }	
    }
    return index;
}

//--------------------------------------------------------------
int testApp::bubbleCursor(int backX, int backY,int bID){
    int bubbleID = -1;
    float minD = 960+640;
    float diffx, diffy, dist;
    for (int i = 0; i < TARGET_NUM; i++){
        diffx = backX  - landmarks[i].x;
        diffy = backY  - landmarks[i].y;
        dist = sqrt(diffx*diffx + diffy*diffy);
        if (dist < minD){
            minD = dist;
            bubbleID = i;
        }
    }
    return bubbleID;
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
