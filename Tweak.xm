#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#define PLIST_PATH @"/User/Library/Preferences/com.sharedroutine.useragentfaker7.plist"

static NSDictionary *preferences = NULL;

@interface WebView : NSObject
+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName;
+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName osMarketingVersion:(id)marketingVersion;
@end

%group OldHook
%hook WebView
+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName {

if (![preferences[@"kEnabled"] boolValue]) return %orig;

if ([preferences[@"kWantsCustomUserAgent"] boolValue]) {

return preferences[@"kCustomUserAgentString"] ?: %orig;

}

return preferences[@"kUserAgentString"] ?: %orig;

}
%end
%end

%group NewHook
%hook WebView
+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName osMarketingVersion:(id)marketingVersion {

if (![preferences[@"kEnabled"] boolValue]) return %orig;

if ([preferences[@"kWantsCustomUserAgent"] boolValue]) {

return preferences[@"kCustomUserAgentString"] ?: %orig;

}

return preferences[@"kUserAgentString"] ?: %orig;

}
%end
%end

void settingsUpdated(CFNotificationCenterRef center,
                           void * observer,
                           CFStringRef name,
                           const void * object,
                           CFDictionaryRef userInfo) {
                           
       if (preferences) 
            preferences = nil;
            
       preferences = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];

}

%ctor {

CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsUpdated,
                                    CFSTR("UserAgentFakerDidUpdateSettingsNotification"), NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

preferences = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];

if (![preferences[@"kEnableAllApplications"] boolValue]) {

NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

if (![((NSArray *)preferences[@"kEnabledApps"]) containsObject:bundleIdentifier]) {

return; //not enabled for all apps and not enabled for current app

}

}

if ([preferences[@"kEnabled"] boolValue]) {
if ([[WebView class] respondsToSelector:@selector(_standardUserAgentWithApplicationName:osMarketingVersion:)])
%init(NewHook);
else
%init(OldHook);

}

}