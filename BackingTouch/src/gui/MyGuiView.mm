//
//  MyGuiView.m
//  iPhone Empty Example
//
//  Created by theo on 26/01/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MyGuiView.h"
#include "ofxiPhoneExtras.h"


@implementation MyGuiView

// called automatically after the view is loaded, can be treated like the constructor or setup() of this class
-(void)viewDidLoad {
	myApp = (testApp*)ofGetAppPtr();
    string statusStr = "BackingTouch is Launched, Target Size: "+ofToString(myApp->radius);
	[self setStatusString:ofxStringToNSString(statusStr)];
}

//----------------------------------------------------------------
-(void)setStatusString:(NSString *)trackStr{
	displayText.text = trackStr;
}

//----------------------------------------------------------------
-(IBAction)hide:(id)sender{
	self.view.hidden = YES;
    myApp->resetTargets();
}

//----------------------------------------------------------------
-(IBAction)adjustPoints:(id)sender{
	
	UISlider * slider = sender;
	printf("slider value is - %f\n", [slider value]);
	int size = [slider value];
    if(size<4) size = 4;
	myApp->radius = size;
	string statusStr = " Changing Target Size: "+ofToString(myApp->radius);;
	[self setStatusString:ofxStringToNSString(statusStr)];
	
}


//----------------------------------------------------------------
-(IBAction)adjustLense:(id)sender{
	UISlider * slider = sender;
	myApp->magWidgetR = [slider value];
	string statusStr = " Changing Ideal Size: "+ofToString(myApp->magWidgetR);
	[self setStatusString:ofxStringToNSString(statusStr)];
}

//----------------------------------------------------------------
-(IBAction)modeSelect:(id)sender{
    UISegmentedControl * UISeg = sender;
    string statusStr; 
    myApp->bDTrans = false;
    myApp->bTrans = false;
    myApp->bVisBack = false;
    myApp->bBubble = false;
    myApp->bSetup = false;
    myApp->mode = UISeg.selectedSegmentIndex;

    switch(myApp->mode){
        case 0: 
            myApp->bSetup = true;
            statusStr = "Mode: Customization"; break;
        case 1: 
            myApp->bDTrans = true;
            myApp->bBubble = false;
            statusStr = "Mode: BackingTouch"; break;
        case 2: 
            myApp->bDTrans = true;
            myApp->bBubble = true;
            statusStr = "Mode: BackingTouch+ Bubble"; break;
        default: break;
    }
    if(!myApp->bSetup) myApp->resetTargets();
    statusStr += ", Target Size: "+ofToString(myApp->radius);
	[self setStatusString:ofxStringToNSString(statusStr)];	
}
//----------------------------------------------------------------

-(IBAction)bgSwitch:(id)sender{
	UISwitch * toggle = sender;
	printf("background is - %i\n", [toggle isOn]);
	myApp->bBubble = [toggle isOn];
	string statusStr; 
    if(myApp->bBubble) statusStr = "BubbleCursor: ON";
    else statusStr = "BubbleCursor: OFF ";
	[self setStatusString:ofxStringToNSString(statusStr)];	
//	UISwitch * toggle = sender;
//	printf("background is - %i\n", [toggle isOn]);
//	myApp->bBGView = [toggle isOn];
//	string statusStr; 
//    if(myApp->bBGView) statusStr = "Background: ON";
//    else statusStr = "Background: OFF ";
//    statusStr += ", Target Size: "+ofToString(myApp->radius);
//	[self setStatusString:ofxStringToNSString(statusStr)];	
}
//
-(IBAction)fillSwitch:(id)sender{
//	UISwitch * toggle = sender;
//	myApp->bMegaLense = [toggle isOn];
//	string statusStr; 
//    if(myApp->bMegaLense) statusStr = "Fisheye on Target: ON";
//    else statusStr = "Fisheye on Target: OFF ";
//    statusStr += ", Target Size: " + ofToString(myApp->radius);
//	[self setStatusString:ofxStringToNSString(statusStr)];	
}
@end
