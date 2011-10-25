#import "UARootListController.h"

@implementation UARootListController

@synthesize customSpec=_customSpec;

- (void)viewDidUnload {
    self.customSpec = nil;

    [super viewDidUnload];
}

- (void)setUserAgentValue:(id)value specifier:(PSSpecifier *)spec {
	[self setPreferenceValue:value specifier:spec];
	[[NSUserDefaults standardUserDefaults] synchronize];

	if ([value isEqualToString:@"Custom"] && ![self specifierForID:@"customuseragent"]) {
		[self insertSpecifier:self.customSpec afterSpecifierID:@"useragent" animated:NO];
	} else if (![value isEqualToString:@"Custom"] && [self specifierForID:@"customuseragent"]) {
		[self removeSpecifierID:@"customuseragent"];
	}
}

- (NSArray *)specifiers {
	if(_specifiers == nil) {
		NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"RootListController" target:self]];

        for (PSSpecifier *spec in specs) {
            if ([[[spec properties] objectForKey:@"id"] isEqualToString:@"customuseragent"]) {
                self.customSpec = spec;
            }
        }

        BOOL isCustom = NO;
        for (PSSpecifier *spec in specs) {
            if ([[[spec properties] objectForKey:@"id"] isEqualToString:@"useragent"]) {
                isCustom = [(NSString *)[self readPreferenceValue:spec] isEqualToString:@"Custom"];
            }
        }

        if (!isCustom) {
            [specs removeObject:self.customSpec];
        }

        _specifiers = [specs copy];
    }

	return _specifiers;
}

@end
