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
                @(UAFakerUserAgentChrome): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.54 Safari/535.19",
                @(UAFakerUserAgentFirefox): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:10.0.2) Gecko/20100101 Firefox/10.0.2",
                @(UAFakerUserAgentSafari): @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.53.11 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10",
                @(UAFakerUserAgentOpera): @"Opera/9.80 (Macintosh; Intel Mac OS X 10.7.3; U; en) Presto/2.10.229 Version/11.61",
                @(UAFakerUserAgentIE): @"Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)",
                @(UAFakerUserAgentiPad): @"Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3",
                @(UAFakerUserAgentiPhone): @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
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
