//
//  UASettingsController.m
//  UserAgentFaker
//
//  Created by Conrad Kramer on 3/30/14.
//  Copyright (c) 2014 Kramer Software Productions, LLC. All rights reserved.
//

#import <notify.h>

#import "UASettingsController.h"

@interface UASettingsController ()

@property (nonatomic, strong) PSSpecifier *applicationsSpec;

@property (nonatomic, strong) PSSpecifier *customSpec;

@property (nonatomic) int token;

@end

static NSString * const UAApplicationsID = @"UAApplications";
static NSString * const UACustomUserAgentID = @"UACustomUserAgent";
static NSString * const UAUserAgentID = @"UAUserAgent";
static NSString * const UAEnabledID = @"UAEnabled";

static char * const UAFakerPreferencesNotification = "com.conradkramer.uafaker.preferences";

@implementation UASettingsController

#pragma mark - PSListController

- (instancetype)init {
    self = [super init];
    if (self) {
        int token = 0;
        __weak __typeof__(self) weakSelf = self;
        notify_register_dispatch(UAFakerPreferencesNotification, &token, dispatch_get_main_queue(), ^(int token) {
            [weakSelf reloadSpecifierID:UAEnabledID];
        });
        self.token = token;
    }
    return self;
}

- (void)dealloc {
    notify_cancel(self.token);
}

- (NSArray *)loadSpecifiersFromPlistName:(NSString *)name target:(id)target {
    NSMutableArray *specifiers = [NSMutableArray arrayWithArray:[super loadSpecifiersFromPlistName:@"UserAgentFaker" target:self]];

    NSPredicate *applicationsPredicate = [NSPredicate predicateWithFormat:@"identifier = %@", UAApplicationsID];
    self.applicationsSpec = [[specifiers filteredArrayUsingPredicate:applicationsPredicate] firstObject];

    NSPredicate *customPredicate = [NSPredicate predicateWithFormat:@"identifier = %@", UACustomUserAgentID];
    self.customSpec = [[specifiers filteredArrayUsingPredicate:customPredicate] firstObject];

    NSPredicate *enabledPredicate = [NSPredicate predicateWithFormat:@"identifier = %@", UAEnabledID];
    PSSpecifier *enabledSpec = [[specifiers filteredArrayUsingPredicate:enabledPredicate] firstObject];

    NSPredicate *userAgentPredicate = [NSPredicate predicateWithFormat:@"identifier = %@", UAUserAgentID];
    PSSpecifier *userAgentSpec = [[specifiers filteredArrayUsingPredicate:userAgentPredicate] firstObject];

    if (![[self readPreferenceValue:enabledSpec] boolValue])
        [specifiers removeObject:self.applicationsSpec];

    if ([[self readPreferenceValue:userAgentSpec] integerValue] >= 0)
        [specifiers removeObject:self.customSpec];

    return [specifiers copy];
}

#pragma mark - UASettingsController

- (void)setEnabledValue:(id)value specifier:(PSSpecifier *)specifier {
    [self setPreferenceValue:value specifier:specifier];

    if ([value boolValue] && ![self specifierForID:UAApplicationsID]) {
        [self insertSpecifier:self.applicationsSpec afterSpecifier:specifier animated:YES];
    } else if (![value boolValue] && [self specifierForID:UAApplicationsID]) {
        [self removeSpecifier:self.applicationsSpec animated:YES];
    }
}

- (void)setUserAgentValue:(id)value specifier:(PSSpecifier *)specifier {
    [self setPreferenceValue:value specifier:specifier];

    if ([value integerValue] < 0 && ![self specifierForID:UACustomUserAgentID]) {
        [self insertSpecifier:self.customSpec afterSpecifier:specifier animated:YES];
    } else if ([value intValue] >= 0 && [self specifierForID:UACustomUserAgentID]) {
        [self removeSpecifier:self.customSpec animated:YES];
    }
}

@end
