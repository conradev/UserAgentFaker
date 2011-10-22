#import <CoreFoundation/CoreFoundation.h>

#import <substrate.h>
#import <notify.h>
#import <unistd.h>

static NSString *userAgent;

static BOOL isEnabled = NO;

extern "C" CFDictionaryRef CFURLRequestCopyAllHTTPHeaderFields();

static CFDictionaryRef (*original_CFURLRequestCopyAllHTTPHeaderFields)();

CFDictionaryRef custom_CFURLRequestCopyAllHTTPHeaderFields() {
	
	NSDictionary *originalHeaders = (NSDictionary *)original_CFURLRequestCopyAllHTTPHeaderFields();
    NSMutableDictionary *headersDict = [[NSMutableDictionary alloc] initWithDictionary:originalHeaders];
    [originalHeaders release];

    if (userAgent && isEnabled) {
        [headersDict setObject:userAgent forKey:@"User-Agent"];
    }
    
    return (CFDictionaryRef)headersDict;
}

void reloadSettings() {
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist"];
	    
	if (settingsDict) {
        [userAgent release];
        
        userAgent = [settingsDict objectForKey:@"useragent"] ? [settingsDict objectForKey:@"useragent"] : @"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/533.4 (KHTML, like Gecko) Chrome/5.0.375.125 Safari/533.4";
        
        if ([userAgent isEqualToString:@"Custom"]) {
            NSString *customUserAgent = [settingsDict objectForKey:@"customuseragent"];
            if ([customUserAgent length] > 0) {
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
    
    reloadSettings();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)&receivedReloadNotfication, CFSTR("com.conradkramer.uafaker.settings"), NULL, NULL);
    
	MSHookFunction(CFURLRequestCopyAllHTTPHeaderFields, custom_CFURLRequestCopyAllHTTPHeaderFields, &original_CFURLRequestCopyAllHTTPHeaderFields);
    
    [pool release];
}
