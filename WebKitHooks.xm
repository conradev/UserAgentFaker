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
                userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.54 Safari/535.19"; // Chrome
                break;
            case 1:
                userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:10.0.2) Gecko/20100101 Firefox/10.0.2"; // Firefox
                break;
            case 2:
                userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.53.11 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10"; // Safari
                break;
            case 3:
                userAgent = @"Opera/9.80 (Macintosh; Intel Mac OS X 10.7.3; U; en) Presto/2.10.229 Version/11.61"; // Opera
                break;
            case 4:
                userAgent = @"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)"; // Internet Explorer
                break;
            case 5:
                userAgent = @"Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"; // iPad
                break;
            case 6:
                userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"; // iPhone
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
