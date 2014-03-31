//
//  UASettingsController.h
//  UserAgentFaker
//
//  Created by Conrad Kramer on 3/30/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSpecifier : NSObject
@property(retain, nonatomic) NSString *identifier;
@end

@interface PSListController : UITableViewController <UIActionSheetDelegate>
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target;
- (id)readPreferenceValue:(PSSpecifier *)specifier;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
- (PSSpecifier *)specifierForID:(NSString *)identifier;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)reloadSpecifierID:(NSString *)identifier;
@end

@interface UASettingsController : PSListController

@end
