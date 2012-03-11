#include <math.h>
#include <string.h>
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
    //ofSetBackgroundAuto(false);
    ofBackground(0,0,0);	
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
    
    
    //set map path and change the draw point
    ntumap.loadImage("NTUCAMPUS.jpg");
    ntumap.setAnchorPercent(0.5,0.5);
    
    resetgroup();
    
    //filesystem
    dir.loadImage("dir.png");
    terminal.loadImage("terminal.png");
    photoIcon.loadImage("photo.png");
    musicIcon.loadImage("music.png");
    dir.setAnchorPercent(0.5, 0.5);
    terminal.setAnchorPercent(0.5, 0.5);
    musicIcon.setAnchorPercent(0.5, 0.5);
    photoIcon.setAnchorPercent(0.5, 0.5);
    
    dClick=false;
    fClick=false;
    
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
        
        landmarks[i].ingroup = false;
        landmarks[i].xmindist=0;
        landmarks[i].ymindist=0;
        
        //0 dir, 1 exe 2 music
        landmarks[i].filetype=i/5;
        landmarks[i].hidden=false;
        landmarks[i].NuminDir=0;
        sprintf(landmarks[i].filename,"test%d", i+1);
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
    
    maporigin.x=320;
    maporigin.y=480;
    dClick=false;
    fClick=false;
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
        
        landmarks[i].ingroup = false;
        landmarks[i].xmindist=0;
        landmarks[i].ymindist=0;
        
        //0 dir, 1 exe 2 music
        landmarks[i].filetype=i/5;
        landmarks[i].hidden=false;
        landmarks[i].NuminDir=0;
        sprintf(landmarks[i].filename,"test%d", i+1);
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
    
    maporigin.x=320;
    maporigin.y=480;
    dClick=false;
    fClick=false;
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
    if(bBubble){
        radius = float(TARGET_R) * canvasScale;
    }else {
        radius = 36.0 * canvasScale;
    }
    //if landmark is in group, move them
    
    //
    
    
    //change the map point
    map.x=-(prevCanvas.x + canvas.x)+maporigin.x;
    map.y=-(prevCanvas.y + canvas.y)+maporigin.y;
    map.x=canvasScale*(map.x - focusZoom.x)+focusZoom.x;
    map.y=canvasScale*(map.y - focusZoom.y)+focusZoom.y;
    
}


//--------------------------------------------------------------
void testApp::stageUpdate(int _x, int _y, bool press, int bID){
    float dX,dY,targetDist;
    float FBDist;
    //draw map  
    if(bBubble){
        ofScale(canvasScale, canvasScale);
        ofSetColor(255, 255, 255);
        ntumap.draw(map.x/canvasScale,map.y/canvasScale);
        ofScale(1/canvasScale, 1/canvasScale);
    }
    if(bBubble){
        selectedIndex = bubbleCursor(_x,_y,0);
        dX = _x - landmarks[selectedIndex].x;
        dY = _y - landmarks[selectedIndex].y;
        targetDist = sqrt(dX*dX + dY*dY);
    }else{
        if (dClick || fClick) {
            showContent(selectedIndex);
            ofSetLineWidth(1);
            ofSetColor(0,255,0);
            ofLine(_x-10,_y,_x+10,_y);
            ofLine(_x,_y-10,_x,_y+10);
        }else{
            selectedIndex = judgeRadius(_x,_y,0);
            if (selectedIndex>=-1) {
                dX = _x - landmarks[selectedIndex].x;
                dY = _y - landmarks[selectedIndex].y;
                targetDist = sqrt(dX*dX + dY*dY);
            }
        }
        if(hasbchoose){
            dX=_x-choose.x;
            dY=_y-choose.y;
            targetDist=sqrt(dX*dX + dY*dY);
        }
    }
    ofSetColor(255);
    ofNoFill();
    if(bDTrans && !dClick){
        ofEnableAlphaBlending();
        ofSetColor(255,255,255,78);
        if(isDTransing){
            if(fingerCID[0]>-1){
                if(!hasbchoose){
                    if(!press){
                        landmarks[fingerCID[0]].x = prevLandmarkPos.x;
                        landmarks[fingerCID[0]].y = prevLandmarkPos.y;
                    }else{
                        landmarks[fingerCID[0]].x= landmarks[selectedIndex].x+dX;
                        landmarks[fingerCID[0]].y= landmarks[selectedIndex].y+dY;
                    }
                }else{
                    int bdrangex=maxboundary.x-minboundary.x;
                    int bdrangey=maxboundary.y-minboundary.y;
                    if(!press){
                        minboundary.x = prevLandmarkPos.x;
                        minboundary.y = prevLandmarkPos.y;
                        for (int j=0; j<groupitemnum; j++) {
                            int index=groupindex[j];
                            lmPos[index].x = (minboundary.x+landmarks[index].xmindist-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                            lmPos[index].y = (minboundary.y+landmarks[index].ymindist-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                        }
                    }else{
                        choose.x=_x;
                        choose.y=_y;
                        minboundary.x = minboundary.x+dX;
                        minboundary.y = minboundary.y+dY;
                        for (int j=0; j<groupitemnum; j++) {
                            int index=groupindex[j];
                            lmPos[index].x = (minboundary.x+landmarks[index].xmindist-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                            lmPos[index].y = (minboundary.y+landmarks[index].ymindist-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                        }
                        
                    }
                    maxboundary.x=minboundary.x+bdrangex;
                    maxboundary.y=minboundary.y+bdrangey;
                }
                dX = _x - frontTouch[0].x;
                dY = _y - frontTouch[0].y;
                FBDist = sqrt(dX*dX + dY*dY);
                if(FBDist>800) FBDist = 800;
                
                ofEnableSmoothing();
                ofSetLineWidth(radius - ((radius-1)*FBDist)/800.);
                if(!hasbchoose){
                    ofLine(frontTouch[0].x,frontTouch[0].y,landmarks[fingerCID[0]].x,landmarks[fingerCID[0]].y);
                }else{
                    if (choose.x>-1 && choose.y>-1) {
                        ofLine(frontTouch[0].x,frontTouch[0].y,choose.x,choose.y);
                    }
                }
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
    if(bBubble){
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
    }else{
        ofScale(canvasScale, canvasScale);
        ofSetColor(255, 255, 255);
        for (int i=0; i<TARGET_NUM; i++) {
            if (landmarks[i].hidden) {
                continue;
            }
            int drawx = landmarks[i].x/canvasScale;
            int drawy = landmarks[i].y/canvasScale;
            ofDrawBitmapString(landmarks[i].filename, drawx-20, drawy+50);
            if(landmarks[i].ingroup && hasbchoose){
                ofSetColor(255, 255, 255, 78);
            }
            switch (landmarks[i].filetype) {
                case 0://dir
                    dir.draw(drawx,drawy);
                    break;
                case 1://exe
                    terminal.draw(drawx,drawy);
                    break;
                case 2://music
                    musicIcon.draw(drawx,drawy);
                    break;
                case 3://photo
                    photoIcon.draw(drawx,drawy);
                    break;
                default:
                    break;
            }
            ofSetColor(255, 255, 255);
        }
        ofScale(1/canvasScale, 1/canvasScale);
        if (bDTrans && !dClick && isDTransing && fingerCID[0]>-1 && hasbchoose) {
            if (choose.x>-1 && choose.y>-1) {
                ofSetLineWidth(3);
                ofSetColor(255,255,255);
                ofLine(minboundary.x,_y,maxboundary.x,_y);
                ofLine(_x,minboundary.y,_x,maxboundary.y);
                ofCircle(_x, _y, radius+5);
            }
        }
    }
    //Group boundary
    if (grouping || hasbgroup) {
        ofEnableAlphaBlending();
        ofFill();
        ofSetColor(255,255,255,78);
        ofSetLineWidth(radius);
        ofRect(minboundary.x, minboundary.y, maxboundary.x-minboundary.x, maxboundary.y-minboundary.y);
        ofSetColor(255, 255, 255, 50);
        for (int j=0; j<groupitemnum; j++) {
            if (!landmarks[groupindex[j]].hidden) {
                ofCircle(landmarks[groupindex[j]].x, landmarks[groupindex[j]].y, radius+5);
            }
        }
        ofNoFill();
        ofSetLineWidth(1);
        ofDisableAlphaBlending();
    }
    if(bDTrans && !dClick){
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
                ofCircle(frontTouch[0].x,frontTouch[0].y, radius);
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
            if(!dClick){
                if(bBubble){
                    i = bubbleCursor(back[0].x, back[0].y, 0);
                }else{
                    i = judgeRadius(back[0].x, back[0].y, 0);
                }
                if(i>=0 && !landmarks[i].ingroup){
                    fingerCID[0] = i;
                    resetgroup();
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
                if (hasbgroup) {
                    hasbchoose=false;
                    if(back[0].x>=minboundary.x && back[0].x<=maxboundary.x 
                       && back[0].y>=minboundary.y && back[0].y<=maxboundary.y ){
                        fingerCID[0] = 100;
                        i=1;
                        hasbchoose=true;
                        choose.x=back[0].x;
                        choose.y=back[0].y;
                        prevLandmarkPos.x=minboundary.x;
                        prevLandmarkPos.y=maxboundary.y;
                        for (int j=0; j<groupitemnum; j++) {
                            landmarks[groupindex[j]].bBeingDragged=true;
                        }
                    }
                }
                //not bubble and back doesn't press on any dot=>start group
                if (!bBubble && i<0 && !grouping) {
                    if (hasbgroup) {
                    resetgroup();
                    }
                    grouping=true;
                    pregrouppoint.x=back[0].x;
                    pregrouppoint.y=back[0].y;
                    //gpboundary[(int)back[0].y][(int)back[0].x]=true;
                }
            }
        }else{
            if(!isDTransing){
                i = judgeRadius(touch.x, touch.y, 0);
                if(!fClick){
                    if(i>=0){
                        isTranslating = true;
                        fingerCID[0] = i;
                        landmarks[i].bOver = true;
                        if(landmarks[i].bDest){
                            isTargetSelected = true;                        
                        }
//                      prevLandmarkPos.x = landmarks[i].x;
//                      prevLandmarkPos.y = landmarks[i].y;
                        landmarks[i].bBeingDragged = true;
                    }else{
                        prevTouch.x = touch.x;
                        prevTouch.y = touch.y;
                    }
                }else{
                    if(i>=0){
                        if(landmarks[i].filetype!=0){
                            i=-1;
                        }
                    }
                    if(i==-1){
                        fClick=false;
                    }
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
    //release front touch=>end grouping
    if (grouping) {
        bool hasdotingroup=false;
        grouping=false;
        for (int i=0; i<TARGET_NUM; i++) {
            if(landmarks[i].x>=minboundary.x && landmarks[i].x<=maxboundary.x && landmarks[i].y>=minboundary.y && landmarks[i].y<=maxboundary.y ){
                landmarks[i].ingroup=true;
                groupindex[groupitemnum++]=i;
                hasdotingroup=true;
                landmarks[i].xmindist=landmarks[i].x-minboundary.x;
                landmarks[i].ymindist=landmarks[i].y-minboundary.y;
                orginmin.x=minboundary.x;
                orginmin.y=minboundary.y;
            }
        }
        if(hasdotingroup){
            hasbgroup=true;
        }else{
            resetgroup();
        }
    }
    if( touch.id < NUM_OF_FRONT && !dClick){
        if(fingerCID[0]>=0){
            landmarks[fingerCID[0]].bBeingDragged = false;	            
            if(!landmarks[fingerCID[0]].bDest) landmarks[fingerCID[0]].bOver = false;
            int index = fingerCID[0];
            if(bDTrans){
                if(index>=0){
                    if(isDTransing){
                        selectedIndex=judgeRadius(back[0].x, back[0].y, 0);
                        if(!hasbchoose){
                            ofPoint tmp;
                            if (!press[0]) {
                                tmp.x=prevLandmarkPos.x;
                                tmp.y=prevLandmarkPos.y;
                            }else{
                                tmp.x=back[0].x;
                                tmp.y=back[0].y;
                            }
                            lmPos[index].x = (tmp.x-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                            lmPos[index].y = (tmp.y-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                            if (press && selectedIndex>-1) {
                                if (landmarks[selectedIndex].filetype==0){//isdir
                                    landmarks[fingerCID[0]].hidden=true;
                                    landmarks[selectedIndex].insideID[landmarks[selectedIndex].NuminDir++]=fingerCID[0];
                                }
                            }
                        }else{
                            for (int j=0; j<groupitemnum; j++) {
                                index=groupindex[j];
                                lmPos[index].x = (minboundary.x+landmarks[index].xmindist-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                                lmPos[index].y = (minboundary.y+landmarks[index].ymindist-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                            }
                            selectedIndex=judgeRadius(choose.x, choose.y, 0);
                            if(press && selectedIndex>-1){
                                if (landmarks[selectedIndex].filetype==0){//isdir
                                    bool check=false;
                                    for (int j=0; j<groupitemnum; j++) {
                                        int index=groupindex[j];
                                        if (index==selectedIndex) {
                                            check=true;
                                        }
                                    }
                                    if (!check) {
                                        for (int j=0; j<groupitemnum; j++) {
                                            int index=groupindex[j];
                                            landmarks[index].hidden=true;
                                            landmarks[selectedIndex].insideID[landmarks[selectedIndex].NuminDir++]=index;    
                                        }
                                        resetgroup();
                                    }
                                }
                            }
                        }
                        isDTransing = false;
                        if (hasbchoose) {
                            hasbchoose=false;
                        }
                    }
                    if(isTranslating){
                        lmPos[index].x = (touch.x-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
                        lmPos[index].y = (touch.y-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
                        selectedIndex=judgeRadius(touch.x, touch.y, 0);
                        if(selectedIndex>-1){
                            if (landmarks[selectedIndex].filetype==0){//isdir
                                landmarks[index].hidden=true;
                                landmarks[selectedIndex].insideID[landmarks[selectedIndex].NuminDir++]=index;
                            }
                        }
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
    return 1;
}
//--------------------------------------------------------------
int testApp::backReleased(int oscX, int oscY){
    if (hasbchoose) {
        for (int j=0; j<groupitemnum; j++) {
            int index=groupindex[j];
            lmPos[index].x = (orginmin.x+landmarks[index].xmindist-focusZoom.x)/canvasScale + focusZoom.x+ (prevCanvas.x+canvas.x);
            lmPos[index].y = (orginmin.y+landmarks[index].ymindist-focusZoom.y)/canvasScale + focusZoom.y+ (prevCanvas.y+canvas.y);
        }
    }
    if (dClick==true) {
        isDTransing=false;
        fingerCID[0] = -1;
        dClick=false;
    }
    resetgroup();
    prevTouch.x = frontTouch[0].x;
    prevTouch.y = frontTouch[0].y;
    if(bSetup){
        
    }else{
        if(isTargetTranslated){
        }else{
        }
    }
    return 1;
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
                if(prevScale+tempScale<=0.5){
                    tempScale = 0.5-prevScale;
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
    //save the group map
    if (grouping) {
        nextgrouppoint.x=back[0].x;
        nextgrouppoint.y=back[0].y;
        if (nextgrouppoint.x<pregrouppoint.x) {
            minboundary.x=nextgrouppoint.x;
            maxboundary.x=pregrouppoint.x;
        }else{
            minboundary.x=pregrouppoint.x;
            maxboundary.x=nextgrouppoint.x;
        }
        if (nextgrouppoint.y<pregrouppoint.y) {
            minboundary.y=nextgrouppoint.y;
            maxboundary.y=pregrouppoint.y;
        }else{
            minboundary.y=pregrouppoint.y;
            maxboundary.y=nextgrouppoint.y;
        }
    }
    return 1;
}


//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
    if (press[0] && !dClick) {
        isDTransing=false;
        fingerCID[0] = -1;
        selectedIndex = judgeRadius(back[0].x, back[0].y, 0);
        if (landmarks[selectedIndex].filetype==0) {
            dClick=true;
        }
    }
    if(!press[0] && !fClick){
        selectedIndex = judgeRadius(touch.x, touch.y, 0);
        if(landmarks[selectedIndex].filetype==0){
            fClick=true;
        }
    }
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
        if (dist < landmarks[i].radius && !landmarks[i].hidden){
            if (i!=fingerCID[0] || dClick) {
                if(dist<minR){
                    minR = dist;
                    index = i;
                }
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
void testApp::resetgroup(){
    for (int j = 0; j < TARGET_NUM; j++){ 
        landmarks[j].ingroup = false;
        landmarks[j].xmindist=0;
        landmarks[j].ymindist=0;
        groupindex[j]=0;
    }
    hasbgroup=false;
    grouping=false;
    pregrouppoint.x=-1;
    pregrouppoint.y=-1;
    nextgrouppoint.x=-1;
    nextgrouppoint.y=-1;
    groupitemnum=0;
    choose.x=-1;
    choose.y=-1;
}
//--------------------------------------------------------------
void testApp::showContent(int index){
    ofSetColor(255,255,255,78);
    ofFill();
    ofRect(1, 720, 640, 240);
    ofSetColor(255, 255, 255);
    int totalNum=landmarks[index].NuminDir;
    for (int i=0; i<totalNum; i++) {
        int tmpx=(i%4 + 1) * 120;
        int mul=80;
        if (i/4==0) {
            mul=50;
        }
        int tmpy=(i/4 + 1) * mul + 720;
        ofDrawBitmapString(landmarks[landmarks[index].insideID[i]].filename, tmpx-20, tmpy+50);
        switch (landmarks[landmarks[index].insideID[i]].filetype) {
            case 0:
                dir.draw(tmpx, tmpy);
                break;
            case 1:
                terminal.draw(tmpx, tmpy);
                break;
            case 2:
                musicIcon.draw(tmpx, tmpy);
                break;
            case 3:
                photoIcon.draw(tmpx, tmpy);
                break;
            default:
                break;
        }
    }
    ofNoFill();
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
