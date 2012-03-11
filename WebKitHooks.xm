#import <notify.h>

static NSString *userAgent;
static BOOL isEnabled = NO;

@interface WebView : NSObject
+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName;
+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName osMarketingVersion:(id)marketingVersion;
@end

%group OlderHook
%hook WebView

+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName {
    if (userAgent && isEnabled) {
        return userAgent;
    }
    
    return %orig;
}

%end
%end

%group NewerHook
%hook WebView

+ (NSString *)_standardUserAgentWithApplicationName:(id)applicationName osMarketingVersion:(id)marketingVersion {
    if (userAgent && isEnabled) {
        return userAgent;
    }
    
    return %orig;
}

%end
%end

void reloadSettings() {
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];

    if (settingsDict) {
        [userAgent release];

        int userAgentSetting = [settingsDict objectForKey:@"UAUserAgent"] ? [[settingsDict objectForKey:@"UAUserAgent"] intValue] : 0;
        switch (userAgentSetting) {
            case 0:
                userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.63 Safari/535.7";
                break;
            case 1:
                userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2; rv:9.0) Gecko/20100101 Firefox/9.0";
                break;
            case 2:
                userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/534.51.22 (KHTML, like Gecko) Version/5.1.1 Safari/534.51.22";
                break;
            case 3:
                userAgent = @"Opera/9.80 (Macintosh; Intel Mac OS X 10_7_2; U; en) Presto/2.9.168 Version/11.60";
                break;
            case 4:
                userAgent = @"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)";
                break;
            case 5:
                userAgent = @"Mozilla/5.0 (iPad; CPU OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3";
                break;
            case 6:
                userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3";
                break;
            default:
                NSString *customUserAgent = [settingsDict objectForKey:@"customuseragent"];
                if  ([customUserAgent length] > 0) {
                    userAgent = customUserAgent;
                } else {
                    isEnabled = NO;
                    userAgent = nil;
                }
        }

        [userAgent retain];

        NSString *displayIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        NSString *enabledKey = [NSString stringWithFormat:@"ALValue-%@", displayIdentifier];

        BOOL globalEnabled = [settingsDict objectForKey:@"enabled"] ? [[settingsDict objectForKey:@"enabled"] boolValue] : YES;
        BOOL bundleEnabled = [settingsDict objectForKey:enabledKey] ? [[settingsDict objectForKey:enabledKey] boolValue] : NO;

        if ((bundleEnabled && globalEnabled) != isEnabled) {
            if (bundleEnabled && globalEnabled) {
                NSLog(@"UserAgentFaker: Enabled hooks in %@", displayIdentifier);
            } else {
                NSLog(@"UserAgentFaker: Disabled hooks in %@", displayIdentifier);
            }
        }

        isEnabled = (bundleEnabled && globalEnabled);
    }
}

void receivedReloadNotfication(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    reloadSettings();
}

%ctor {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    // Configure settings
    reloadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&receivedReloadNotfication, CFSTR("com.conradkramer.uafaker.settings"), NULL, NULL);
    
    %init;
    
    if ([[WebView class] respondsToSelector:@selector(_standardUserAgentWithApplicationName:osMarketingVersion:)]) {
        %init(NewerHook);
    } else {
        %init(OlderHook);
    }
    
    [pool release];
}
