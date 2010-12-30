#import <UIKit/UIKit.h>

#include <notify.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>

BOOL isCapable()
{
	return YES;
}

// This runs when iPhone springboard resets. This is on boot or respring.
BOOL isEnabled()
{
	NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];
	if (!plistDict) {
		return YES;
	}
	BOOL enabled = [[plistDict objectForKey:@"enabled"] boolValue];

	return enabled;
}

// This function is optional and should only be used if it is likely for the toggle to become out of sync
// with the state while the iPhone is running. It must be very fast or you will slow down the animated
// showing of the sbsettings window. Imagine 12 slow toggles trying to refresh tate on show.
BOOL getStateFast()
{
	return isEnabled();
}

// Pass in state to set. YES for enable, NO to disable.
void setState(BOOL Enable)
{
	NSMutableDictionary *plistDict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];
	if (!plistDict) {
		plistDict = [NSMutableDictionary dictionary];
	}
	if (Enable == YES) 
	{
		[plistDict setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
		[plistDict writeToFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist" atomically: YES];
	}
	else if (Enable == NO) 
	{
		[plistDict setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
		[plistDict writeToFile:@"/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist" atomically: YES];
	}
	notify_post("com.conradkramer.uafaker.settings");
}

// Amount of time spinner should spin in seconds after the toggle is selected.
float getDelayTime()
{
	return 0.6f;
}
// Runs when the dylib is loaded. Only useful for debug. Function can be omitted.
__attribute__((constructor)) 
static void toggle_initializer() 
{ 
	NSLog(@"Initializing UAFaker Toggle\n"); 
}