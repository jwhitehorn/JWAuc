#include <ApplicationServices/ApplicationServices.h>
#include <unistd.h>
#include <stdlib.h>
//helper to simulate user input
//gcc -o keyboard keyboard.c -Wall -framework ApplicationServices

int main() {
	int keyCode = 49; //space bar
	srand ( time(NULL) );
	printf("User input coming in 30 seconds\n");
	sleep(30);
	while(1){
		CGEventRef ourEvent = CGEventCreate(NULL);
		CGPoint point = CGEventGetLocation(ourEvent);
		
	    // Left button down at 250x250
	    CGEventRef click1_down = CGEventCreateMouseEvent(
	        NULL, kCGEventLeftMouseDown,
	        point,
	        kCGMouseButtonLeft
	    );
	    CGEventRef click1_up = CGEventCreateMouseEvent(
	        NULL, kCGEventLeftMouseUp,
	        point,
	        kCGMouseButtonLeft
	    );
		
	    CGEventPost(kCGHIDEventTap, click1_down);
	    sleep(0.11);			
	    CGEventPost(kCGHIDEventTap, click1_up);
		
		CFRelease(click1_up);
	    CFRelease(click1_down);
		CFRelease(ourEvent);
		
		sleep(0.89);
		if(rand() % 100 <= 2){	//2% chance
			CGEventRef e = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)keyCode, true);
			CGEventPost(kCGSessionEventTap, e);
			CFRelease(e);
			e = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)keyCode, false);
			CGEventPost(kCGSessionEventTap, e);		
			CFRelease(e);
		}
		sleep(9);
	}
}