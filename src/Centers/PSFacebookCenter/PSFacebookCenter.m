//
//  PSFacebookCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSFacebookCenter.h"

@implementation PSFacebookCenter

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
        _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"fbAccessToken"] && [defaults objectForKey:@"fbExpirationDate"]) {
            _facebook.accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"fbAccessToken"];
            _facebook.expirationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"fbExpirationDate"];
            NSLog(@"FB Token: %@", _facebook.accessToken);
        }
    }
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(_facebook);
    [super dealloc];
}

- (BOOL)handleOpenURL:(NSURL *)url {
    return [_facebook handleOpenURL:url];
}

- (BOOL)isLoggedIn {
    return ([_facebook isSessionValid] && [self me] && [self accessToken]);
}

- (NSString *)accessToken {
    return [_facebook accessToken];
}

- (NSDate *)expirationDate {
    return [_facebook expirationDate];
}

- (NSDictionary *)me {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"fbMe"];
}

#pragma mark - Permissions
- (void)authorizeBasicPermissions {
    // Check if already authorized
    if (![_facebook isSessionValid]) {
        [_facebook authorize:FB_BASIC_PERMISISONS];
    }
}

- (BOOL)hasPublishStreamPermission {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"fbExtendedPermissions"] containsObject:FB_PERMISSIONS_PUBLISH];
}

- (NSArray *)availableExtendedPermissions {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"fbExtendedPermissions"];
}

- (void)addExtendedPermission:(NSString *)permission {
    _newPermissions = [[[self availableExtendedPermissions] arrayByAddingObject:permission] retain];
    
    // Authorize with FB
    [_facebook authorize:_newPermissions];
}

- (void)requestPublishStream {
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Facebook" message:@"We need your permission to post on your behalf, just this once!" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Okay", nil] autorelease];
    av.tag = kAlertFacebookPermissionsPublish;
    [av show];
}

- (void)showDialog:(NSString *)dialog andParams:(NSMutableDictionary *)params {
    [_facebook dialog:dialog andParams:params andDelegate:self];
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
    if (_newPermissions) {
        [[NSUserDefaults standardUserDefaults] setObject:_newPermissions forKey:@"fbExtendedPermissions"];
        [_newPermissions release], _newPermissions = nil;
    }
    [[NSUserDefaults standardUserDefaults] setObject:_facebook.accessToken forKey:@"fbAccessToken"];
    [[NSUserDefaults standardUserDefaults] setObject:_facebook.expirationDate forKey:@"fbExpirationDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Got FB Token: %@", _facebook.accessToken);
    
    // Get Me
    // Setup the network request
    // This block is passed in to NSURLConnection equivalent to a finish block, it is run inside the provided operation queue
    void (^handlerBlock)(NSURLResponse *response, NSData *data, NSError *error);
    handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"# NSURLConnection completed on thread: %@", [NSThread currentThread]);
        
        // How to check response
        // First check error and data
        if (!error && data) {
            // This is equivalent to the completion block
            // Check the HTTP Status code if available
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = [httpResponse statusCode];
                if (statusCode == 200) {
                    NSLog(@"# NSURLConnection succeeded with statusCode: %d", statusCode);
                    // We got an HTTP OK code, start reading the response
                    NSDictionary *me = [data objectFromJSONData];
                    if (me) {
                        [[NSUserDefaults standardUserDefaults] setObject:me forKey:@"fbMe"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidSucceed object:nil];
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
                    }
                } else {
                    // Failed, read status code
                    [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
                }
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
        }
    };
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:_facebook.accessToken forKey:@"access_token"];
    [parameters setObject:@"id,name,first_name,last_name,middle_name,username,gender,locale,friends" forKey:@"fields"];
    [parameters setObject:@"5000" forKey:@"limit"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/me", @"https://graph.facebook.com"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    [_newPermissions release], _newPermissions = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
}

- (void)fbDidLogout {
    
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
