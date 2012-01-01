#import <CoreFoundation/CoreFoundation.h>

#import <substrate.h>
#import <notify.h>
#import <unistd.h>

static NSString *userAgent;

static BOOL isEnabled = NO;

typedef const struct _CFURLRequest* CFURLRequestRef;
extern "C" CFDictionaryRef CFURLRequestCopyAllHTTPHeaderFields(CFURLRequestRef request);

static CFDictionaryRef (*original_CFURLRequestCopyAllHTTPHeaderFields)(CFURLRequestRef request);
static void (*original_CFHTTPMessageSetHeaderFieldValue)(CFHTTPMessageRef message, CFStringRef headerField, CFStringRef value);

// iOS 5
CFDictionaryRef custom_CFURLRequestCopyAllHTTPHeaderFields(CFURLRequestRef request) {

    CFDictionaryRef originalHeaders = original_CFURLRequestCopyAllHTTPHeaderFields(request);

    if (userAgent && isEnabled && originalHeaders) {
        CFMutableDictionaryRef newHeaders = CFDictionaryCreateMutableCopy(CFGetAllocator(originalHeaders), 0, originalHeaders);
        CFRelease(originalHeaders);
        CFDictionarySetValue (newHeaders, CFSTR("User-Agent"), (CFStringRef)userAgent);
        return newHeaders;
    }

    return originalHeaders;
}

// iOS 4
void custom_CFHTTPMessageSetHeaderFieldValue(CFHTTPMessageRef message, CFStringRef headerField, CFStringRef value) {
    original_CFHTTPMessageSetHeaderFieldValue(message, headerField, value);

    if (userAgent && isEnabled) {
        original_CFHTTPMessageSetHeaderFieldValue(message, CFSTR("User-Agent"), (CFStringRef)userAgent);
    }
}

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

    // Initialize hooks
    if (kCFCoreFoundationVersionNumber >= 675.00f) { // iOS 4 or 5
        MSHookFunction(CFURLRequestCopyAllHTTPHeaderFields, custom_CFURLRequestCopyAllHTTPHeaderFields, &original_CFURLRequestCopyAllHTTPHeaderFields); // Screws up iOS 4
    } else {
        MSHookFunction(CFHTTPMessageSetHeaderFieldValue, custom_CFHTTPMessageSetHeaderFieldValue, &original_CFHTTPMessageSetHeaderFieldValue); // Doesn't work on iOS 5
    }

    [pool release];
}
