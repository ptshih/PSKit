//
//  PSFacebookCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Facebook.h"

// Facebook
#define FB_APP_ID @"145264018857264"
#define FB_PERMISSIONS_PUBLISH @"publish_stream"
#define FB_BASIC_PERMISISONS [NSArray arrayWithObjects:@"offline_access", @"user_photos", nil]

#define kPSFacebookCenterDialogDidBegin @"kPSFacebookCenterDialogDidBegin"
#define kPSFacebookCenterDialogDidSucceed @"PSFacebookCenterDialogDidSucceed"
#define kPSFacebookCenterDialogDidFail @"PSFacebookCenterDialogDidFail"

@interface PSFacebookCenter : NSObject <FBDialogDelegate, FBSessionDelegate, UIAlertViewDelegate> {
  Facebook *_facebook;
  NSArray *_newPermissions;
}

+ (id)defaultCenter;

- (BOOL)handleOpenURL:(NSURL *)url;

// Login
- (BOOL)isLoggedIn;

// Logout
- (void)logout;

// Permissions
- (void)authorizeBasicPermissions;
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
