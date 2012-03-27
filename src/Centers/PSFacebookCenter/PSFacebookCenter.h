//
//  PSFacebookCenter.h
//  PSKit
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

#define kPSFacebookCenterDialogDidBegin @"kPSFacebookCenterDialogDidBegin"
#define kPSFacebookCenterDialogDidSucceed @"PSFacebookCenterDialogDidSucceed"
#define kPSFacebookCenterDialogDidFail @"PSFacebookCenterDialogDidFail"

@interface PSFacebookCenter : NSObject <FBDialogDelegate, FBSessionDelegate, UIAlertViewDelegate>

+ (id)defaultCenter;

- (BOOL)handleOpenURL:(NSURL *)url;

// Login
- (BOOL)isLoggedIn;

// Logout
- (void)logout;

// Permissions
- (void)authorizeWithPermissions:(NSArray *)permissions;
- (BOOL)hasPublishStreamPermission;
- (void)requestPublishStream;
- (NSArray *)availableExtendedPermissions;
- (void)addExtendedPermission:(NSString *)permission;

// Dialog
- (void)showDialog:(NSString *)dialog andParams:(NSMutableDictionary *)params;

// Convenience
- (NSString *)accessToken;
- (NSDate *)expirationDate;

- (NSDictionary *)me;

@end
