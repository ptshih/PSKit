//
//  PSFacebookCenter.m
//  PSKit
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSFacebookCenter.h"

@interface PSFacebookCenter ()

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSArray *extendedPermissions;

@end

@implementation PSFacebookCenter

@synthesize
facebook = _facebook,
extendedPermissions = _extendedPermissions;

+ (id)defaultCenter {
    static id defaultCenter = nil;
    if (!defaultCenter) {
        defaultCenter = [[self alloc] init];
    }
    return defaultCenter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.facebook = [[[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self] autorelease];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"fbAccessToken"] && [defaults objectForKey:@"fbExpirationDate"]) {
            self.facebook.accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"fbAccessToken"];
            self.facebook.expirationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"fbExpirationDate"];
            NSLog(@"FB Token: %@", self.facebook.accessToken);
        }
    }
    return self;
}

- (void)dealloc {
    self.extendedPermissions = nil;
    self.facebook = nil;
    [super dealloc];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [self.facebook handleOpenURL:url];
}

- (BOOL)isLoggedIn {
    return ([self.facebook isSessionValid] && [self me] && [self accessToken]);
}

- (NSString *)accessToken {
    return [self.facebook accessToken];
}

- (NSDate *)expirationDate {
    return [self.facebook expirationDate];
}

- (NSDictionary *)me {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"fbMe"];
}

- (void)logout {
    [self.facebook logout];
}

#pragma mark - Permissions
- (void)authorizeBasicPermissions {
    // Check if already authorized
    if (![self.facebook isSessionValid]) {
        [self.facebook authorize:FB_BASIC_PERMISISONS];
    }
}

- (BOOL)hasPublishStreamPermission {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"fbExtendedPermissions"] containsObject:FB_PERMISSIONS_PUBLISH];
}

- (NSArray *)availableExtendedPermissions {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"fbExtendedPermissions"];
}

- (void)addExtendedPermission:(NSString *)permission {
    self.extendedPermissions = [[self availableExtendedPermissions] arrayByAddingObject:permission];
    
    // Authorize with FB
    [self.facebook authorize:self.extendedPermissions];
}

- (void)requestPublishStream {
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"We need your permission to post on your behalf, just this once!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Okay", nil] autorelease];
    av.tag = kAlertFacebookPermissionsPublish;
    [av show];
}

- (void)showDialog:(NSString *)dialog andParams:(NSMutableDictionary *)params {
    [self.facebook dialog:dialog andParams:params andDelegate:self];
}

#pragma mark - FBDialogDelegate
- (void)dialogDidComplete:(FBDialog *)dialog {
    
}

- (void)dialogCompleteWithUrl:(NSURL *)url {
    
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url {
    
}

- (void)dialogDidNotComplete:(FBDialog *)dialog {
    
}

- (void)dialog:(FBDialog *)dialog didFailWithError:(NSError *)error {
    
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url {
    return YES;
}

#pragma mark - FBSessionDelegate
- (void)fbDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidBegin object:nil];
    
    if (self.extendedPermissions) {
        [[NSUserDefaults standardUserDefaults] setObject:self.extendedPermissions forKey:@"fbExtendedPermissions"];
        self.extendedPermissions = nil;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.facebook.accessToken forKey:@"fbAccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:self.facebook.expirationDate forKey:@"fbExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Got FB Token: %@", self.facebook.accessToken);
    
    // Get Me
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:self.facebook.accessToken forKey:@"access_token"];
    [parameters setObject:@"id,name,first_name,last_name,middle_name,username,gender,locale,friends" forKey:@"fields"];
    [parameters setObject:@"5000" forKey:@"limit"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/me", @"https://graph.facebook.com"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
            [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
        } else {
            NSDictionary *me = (NSDictionary *)JSON;
            NSString *fbId = [me objectForKey:@"id"];
            if (me) {
                [[NSUserDefaults standardUserDefaults] setObject:fbId forKey:@"fbId"];
                [[NSUserDefaults standardUserDefaults] setObject:me forKey:@"fbMe"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidSucceed object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
    }];
    [op start];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    self.extendedPermissions = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
}

- (void)fbDidLogout {
    // Clear FB user defaults keys
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fbId"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fbMe"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fbAccessToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fbExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    
}

- (void)fbSessionInvalidated {
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) return;
    
    if (alertView.tag == kAlertFacebookPermissionsPublish) {
        [self addExtendedPermission:FB_PERMISSIONS_PUBLISH];
    }
}

@end
