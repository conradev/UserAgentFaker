#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface UAFakerSettingsController : PSListController {
	NSArray *specs;
}

@end

@implementation UAFakerSettingsController

-(void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"UAFaker" style:UIBarButtonItemStylePlain target:self.navigationItem.backBarButtonItem.target action:self.navigationItem.backBarButtonItem.action];
}
-(void)setUserAgentValue:(id)value specifier:(PSSpecifier *)spec {
	[self setPreferenceValue:value specifier:spec];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([value isEqualToString:@"Custom"] && ![self specifierForID:@"customuseragent"]) {
		[self insertSpecifier:[specs objectAtIndex:3] afterSpecifierID:@"useragent" animated:NO];
	} else {
		[self removeSpecifierID:@"customuseragent"];
	}
}
- (NSArray *)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"RootView" target:self] retain];
		specs = [[_specifiers retain] retain];
	}
	
	NSMutableArray *mutSpecs = [_specifiers mutableCopy];
	
	BOOL isCustomEnabled = NO;
	for (PSSpecifier *spec in mutSpecs) {
		if ([[[spec properties] objectForKey:@"id"] isEqualToString:@"useragent"]) {
			isCustomEnabled = [(NSString *)[self readPreferenceValue:spec] isEqualToString:@"Custom"];
		}
	}
	
	BOOL customExists = NO;
	for (PSSpecifier *spec in mutSpecs) {
		if ([[[spec properties] objectForKey:@"id"] isEqualToString:@"customuseragent"]) {
			customExists = YES;
		}
	}
	
	if (isCustomEnabled) {
		if (!customExists) {
			[mutSpecs insertObject:[specs objectAtIndex:3] atIndex:3];
		}
	} else {
		if (customExists) {
			[mutSpecs removeObjectAtIndex:3];
		}
	}

	_specifiers = [mutSpecs copy];
	[mutSpecs release];
	
	return _specifiers;
}

@end