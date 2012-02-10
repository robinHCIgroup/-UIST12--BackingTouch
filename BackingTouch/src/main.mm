
#include "ofMain.h"
#include "testApp.h"


int main(){
	ofAppiPhoneWindow * iOSWindow = new ofAppiPhoneWindow();
    iOSWindow->enableRetinaSupport();
	ofSetupOpenGL(iOSWindow,960,640, OF_FULLSCREEN);
	ofRunApp(new testApp);
}
