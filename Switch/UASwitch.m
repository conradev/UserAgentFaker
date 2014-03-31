//
//  UASwitch.m
//  UserAgentFaker
//
//  Created by Conrad Kramer on 3/30/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <notify.h>

#import "UASwitch.h"

@interface UASwitch ()

@property (nonatomic) int token;

@end

static NSString * const UAFakerPreferencesPath = @"/private/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist";
static NSString * const UAFakerEnabledKey = @"enabled";

static char * const UAFakerPreferencesNotification = "com.conradkramer.uafaker.preferences";

@implementation UASwitch

+ (void)load {
    int token = 0;
	notify_register_dispatch(UAFakerPreferencesNotification, &token, dispatch_get_main_queue(), ^(int token) {
		[[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:[[NSBundle bundleForClass:[UASwitch class]] bundleIdentifier]];
    });
}

#pragma mark - FSSwitchDataSource

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:UAFakerPreferencesPath];
    BOOL enabled = preferences[UAFakerEnabledKey] ? [preferences[UAFakerEnabledKey] boolValue] : YES;
	return enabled ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	switch (newState) {
		case FSSwitchStateOn:
		case FSSwitchStateOff: {
			NSMutableDictionary *preferences = [NSMutableDictionary dictionaryWithContentsOfFile:UAFakerPreferencesPath];
			preferences[UAFakerEnabledKey] = @(newState == FSSwitchStateOn ? YES : NO);
			[preferences writeToFile:UAFakerPreferencesPath atomically:YES];
	        notify_post(UAFakerPreferencesNotification);
			break;
		}

		case FSSwitchStateIndeterminate:
		default:
			break;
	}
}

@end
