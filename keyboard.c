#include <ApplicationServices/ApplicationServices.h>
#include <unistd.h>
#include <stdlib.h>
//helper to simulate keyboard space bar pressing.
//gcc -o keyboard keyboard.c -Wall -framework ApplicationServices

int main() {
	int keyCode = 56;
	srand ( time(NULL) );
	printf("Keyboard SPACE keys coming in 30 seconds\n");
	sleep(30);
	while(1){
		CGEventRef e = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)keyCode, true);
		CGEventPost(kCGSessionEventTap, e);
		CFRelease(e);
		e = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)keyCode, false);
		CGEventPost(kCGSessionEventTap, e);		
		printf(".\n");
		//sleep((rand() % 1000) / 50.0 + 40.3);
		sleep(10);
	}
}