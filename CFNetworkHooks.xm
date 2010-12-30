/*
	Do whatever you want with the code, except sell it
 */

#import <CoreFoundation/CoreFoundation.h>

#import <substrate.h>
#include <notify.h>
#include <unistd.h>

static NSString *userAgent;
static BOOL enabled;
static BOOL isEnabledBundle;
static void (*original_CFHTTPMessageSetHeaderFieldValue)(CFHTTPMessageRef message, CFStringRef headerField, CFStringRef value);

void custom_CFHTTPMessageSetHeaderFieldValue(CFHTTPMessageRef message, CFStringRef headerField, CFStringRef value) {
	original_CFHTTPMessageSetHeaderFieldValue(message, headerField, value);
	
	if ([userAgent length] > 0 && enabled && isEnabledBundle) {
	original_CFHTTPMessageSetHeaderFieldValue(message, CFSTR("User-Agent"), (CFStringRef)userAgent);
	}
}

void reloadSettings () {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];
	
	userAgent = @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.125 Safari/533.4";
	enabled = YES;
	isEnabledBundle = NO;
	
	NSString *customUserAgent = @"";
	if (settings) {
		for (NSString *key in [settings allKeys]) {
			if ([key isEqualToString:@"useragent"]) {
				userAgent = [settings objectForKey:key];
			}
			if ([key isEqualToString:@"enabled"]) {
				enabled = [[settings objectForKey:key] boolValue];
			}
			if ([key isEqualToString:@"customuseragent"]) {
				customUserAgent = [settings objectForKey:key];
			}
			if ([key hasPrefix:@"ALValue-"]) {
				if ([[key substringFromIndex:8] isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
					isEnabledBundle = [[settings objectForKey:key] boolValue];
					if (isEnabledBundle) {
						NSLog(@"UserAgentFaker: Enabled hooks in app %@", [[NSBundle mainBundle] bundleIdentifier]);
					}
				}
			}
		}
	}
	if ([userAgent isEqualToString:@"Custom"]) {
		userAgent = customUserAgent;
	}
	
	[userAgent retain];
}

void receivedNotfication (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	reloadSettings();
}

__attribute__((constructor)) static void init() {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];   
    
    reloadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&receivedNotfication, CFSTR("com.conradkramer.uafaker.settings"), NULL, NULL);
	MSHookFunction(CFHTTPMessageSetHeaderFieldValue, custom_CFHTTPMessageSetHeaderFieldValue, &original_CFHTTPMessageSetHeaderFieldValue);

    [pool release];
}

/* vim: set syntax=objcpp sw=4 ts=4 sts=4 expandtab textwidth=80 ff=unix: */
