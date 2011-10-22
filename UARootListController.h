#import <UIKit/UIKit.h>

#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface UARootListController : PSListController {
	PSSpecifier *_customSpec;
}

@property (nonatomic, retain) PSSpecifier *customSpec;

@end