//
//  WebView.x
//  UserAgentFaker
//
//  Created by Conrad Kramer on 3/30/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <notify.h>

typedef NS_ENUM(NSInteger, UAFakerUserAgent) {
    UAFakerUserAgentChrome,
    UAFakerUserAgentFirefox,
    UAFakerUserAgentSafari,
    UAFakerUserAgentOpera,
    UAFakerUserAgentIE,
    UAFakerUserAgentiPad,
    UAFakerUserAgentiPhone
};

@interface WebView : NSObject

@property (nonatomic, copy) NSString *customUserAgent;

@property (nonatomic, setter=__uafaker_setToken:, getter=__uafaker_token) int token;

@end

static NSString * const UAFakerPreferencesPath = @"/private/var/mobile/Library/Preferences/com.conradkramer.uafaker.plist";
static NSString * const UAFakerUserAgentKey = @"UAUserAgent";
static NSString * const UAFakerCustomUserAgentKey = @"customuseragent";
static NSString * const UAFakerEnabledKey = @"enabled";

static char * const UAFakerPreferencesNotification = "com.conradkramer.uafaker.preferences";
static char * const UAFakerTokenKey = "UAFakerTokenKey";

%hook WebView

- (id)initWithFrame:(CGRect)frame frameName:(NSString *)frameName groupName:(NSString *)groupName {
    self = %orig();
    if (self) {
        int token = 0;
        __block __typeof__(self) blockSelf = self;
        notify_register_dispatch(UAFakerPreferencesNotification, &token, dispatch_get_main_queue(), ^(int token) {
            NSDictionary *userAgents = @{
                @(UAFakerUserAgentChrome): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.92 Safari/537.36",
                @(UAFakerUserAgentFirefox): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:24.0) Gecko/20100101 Firefox/24.0",
                @(UAFakerUserAgentSafari): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.74.9 (KHTML, like Gecko) Version/7.0.2 Safari/537.74.9",
                @(UAFakerUserAgentOpera): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.154 Safari/537.36 OPR/20.0.1387.82",
                @(UAFakerUserAgentIE): @"Mozilla/5.0 (IE 11.0; Windows NT 6.3; Trident/7.0; .NET4.0E; .NET4.0C; rv:11.0) like Gecko",
                @(UAFakerUserAgentiPad): @"Mozilla/5.0 (iPad; CPU OS 7_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D167 Safari/9537.53",
                @(UAFakerUserAgentiPhone): @"Mozilla/5.0 (iPhone; CPU iPhone OS 7_1 like Mac OS X) AppleWebKit/537.51.2 (KHTML, like Gecko) Version/7.0 Mobile/11D167 Safari/9537.53"
            };
            NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:UAFakerPreferencesPath];
            NSString *userAgent = preferences[UAFakerUserAgentKey] ? userAgents[preferences[UAFakerUserAgentKey]] : preferences[UAFakerCustomUserAgentKey];

            if (userAgent) {
                NSString *bundleEnabledKey = [@"ALValue-" stringByAppendingString:[[NSBundle mainBundle] bundleIdentifier]];
                BOOL bundleEnabled = preferences[bundleEnabledKey] ? [preferences[bundleEnabledKey] boolValue] : YES;
                BOOL enabled = preferences[UAFakerEnabledKey] ? [preferences[UAFakerEnabledKey] boolValue] : YES;
                if (!enabled || !bundleEnabled) {
                    userAgent = nil;
                }
            }

            blockSelf.customUserAgent = userAgent;
        });
        notify_post(UAFakerPreferencesNotification);
        self.token = token;
    }

    return self;
}

- (void)dealloc {
    notify_cancel(self.token);
    %orig();
}

%new(v@:i)
- (void)__uafaker_setToken:(int)token {
    objc_setAssociatedObject(self, UAFakerTokenKey, @(token), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new(i@:)
- (int)__uafaker_token {
    return [objc_getAssociatedObject(self, UAFakerTokenKey) intValue];
}

%end
