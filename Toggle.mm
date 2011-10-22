#import <UIKit/UIKit.h>

#include <notify.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>

extern "C" BOOL isCapable() {
	return YES;
}

// This runs when iPhone springboard resets. This is on boot or respring.
extern "C" BOOL isEnabled() {
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];
	return [settingsDict objectForKey:@"enabled"] ? [[settingsDict objectForKey:@"enabled"] boolValue] : YES;
}

// This function is optional and should only be used if it is likely for the toggle to become out of sync
// with the state while the iPhone is running. It must be very fast or you will slow down the animated
// showing of the sbsettings window. Imagine 12 slow toggles trying to refresh state on show.
extern "C" BOOL getStateFast() {
	return isEnabled();
}

// Pass in state to set. YES for enable, NO to disable.
extern "C" void setState(BOOL enabled) {
    
	NSMutableDictionary *settingsDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];
	
    if (!settingsDict) {
		settingsDict = [NSMutableDictionary dictionary];
	}
	
    [settingsDict setValue:[NSNumber numberWithBool:enabled] forKey:@"enabled"];
    [settingsDict writeToFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist" atomically:YES];

	notify_post("com.conradkramer.uafaker.settings");
}

// Amount of time spinner should spin in seconds after the toggle is selected.
extern "C" float getDelayTime() {
	return 0.6f;
}