#import <Preferences/Preferences.h>
#import <Preferences/PSSpecifier.h>

@interface UserAgentFaker7PrefsListController: PSListController {
}
- (void)setCustomUserAgentEnabled:(id)value forSpecifier:(PSSpecifier *)spec;
- (void)setEnableAllApplications:(id)value forSpecifier:(PSSpecifier *)spec;
@end

@implementation UserAgentFaker7PrefsListController

- (void)setCustomUserAgentEnabled:(id)value forSpecifier:(PSSpecifier *)spec {
    
    [self setPreferenceValue:value specifier:spec];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([value intValue] == 1) {
        
        [((PSSpecifier *)[self specifierForID:@"UserAgentSelection"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
        [self reloadSpecifierID:@"UserAgentSelection" animated:TRUE];
        
        [((PSSpecifier *)[self specifierForID:@"CustomUserAgentString"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
        [self reloadSpecifierID:@"CustomUserAgentString" animated:TRUE];
        
    } else {
        
        [((PSSpecifier *)[self specifierForID:@"UserAgentSelection"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
        [self reloadSpecifierID:@"UserAgentSelection" animated:TRUE];
        
        [((PSSpecifier *)[self specifierForID:@"CustomUserAgentString"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
        [self reloadSpecifierID:@"CustomUserAgentString" animated:TRUE];
    }
    
}

- (void)setEnableAllApplications:(id)value forSpecifier:(PSSpecifier *)spec {
    
    [self setPreferenceValue:value specifier:spec];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([value intValue] == 1) {
        
        [((PSSpecifier *)[self specifierForID:@"AppLinkSpecifier"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
        [self reloadSpecifierID:@"AppLinkSpecifier" animated:TRUE];
        
    } else {
        
        [((PSSpecifier *)[self specifierForID:@"AppLinkSpecifier"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
        [self reloadSpecifierID:@"AppLinkSpecifier" animated:TRUE];
    }

}

- (id)specifiers {
    
	if(_specifiers == nil) {
        
        _specifiers = [[self loadSpecifiersFromPlistName:@"UserAgentFaker7Prefs" target:self] retain];
        
        for (PSSpecifier *spec in _specifiers) {
            
            if ([[[spec properties] objectForKey:@"id"] isEqualToString:@"CustomUserAgentSwitch"]) {
                
                NSNumber *prefValue = (NSNumber *)[self readPreferenceValue:spec];
                
                if ([prefValue intValue] == 1) {
                    
                    [((PSSpecifier *)[self specifierForID:@"UserAgentSelection"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
                    [self reloadSpecifierID:@"UserAgentSelection" animated:TRUE];
                    
                    [((PSSpecifier *)[self specifierForID:@"CustomUserAgentString"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
                    [self reloadSpecifierID:@"CustomUserAgentString" animated:TRUE];
                    
                } else {
                    
                    [((PSSpecifier *)[self specifierForID:@"UserAgentSelection"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
                    [self reloadSpecifierID:@"UserAgentSelection" animated:TRUE];
                    
                    [((PSSpecifier *)[self specifierForID:@"CustomUserAgentString"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
                    [self reloadSpecifierID:@"CustomUserAgentString" animated:TRUE];
                }
                
            }
            
            if ([[[spec properties] objectForKey:@"id"] isEqualToString:@"AllAppsEnableSwitch"]) {
                
                NSNumber *prefValue = (NSNumber *)[self readPreferenceValue:spec];
                
                if ([prefValue intValue] == 1) {
                    
                    [((PSSpecifier *)[self specifierForID:@"AppLinkSpecifier"]) setProperty:[NSNumber numberWithBool:FALSE] forKey:@"enabled"];
                    [self reloadSpecifierID:@"AppLinkSpecifier" animated:TRUE];
                    
                } else {
                    
                    [((PSSpecifier *)[self specifierForID:@"AppLinkSpecifier"]) setProperty:[NSNumber numberWithBool:TRUE] forKey:@"enabled"];
                    [self reloadSpecifierID:@"AppLinkSpecifier" animated:TRUE];
                }
            
            }
        }
        
	}
	return _specifiers;
}

-(NSArray *)getUserAgentValues {
    
    return [NSArray arrayWithObjects:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.74.9 (KHTML, like Gecko) Version/7.0.2 Safari/537.74.9",@"Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14",@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:25.0) Gecko/20100101 Firefox/25.0",@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/32.0.1664.3 Safari/537.36",@"Mozilla/5.0 (compatible; MSIE 10.6; Windows NT 6.1; Trident/5.0; InfoPath.2; SLCC1; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; .NET CLR 2.0.50727) 3gpp-gba UNTRUSTED/1.0",@"Mozilla/5.0 (iPad; CPU OS 7_0_6 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B651 Safari/9537.53",@"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0_4 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11B554a Safari/9537.53",nil];
}

@end

// vim:ft=objc
