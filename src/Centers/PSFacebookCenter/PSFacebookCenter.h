//
//  PSFacebookCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "Facebook.h"

#define kPSFacebookCenterDialogDidSucceed @"PSFacebookCenterDialogDidSucceed"
#define kPSFacebookCenterDialogDidFail @"PSFacebookCenterDialogDidFail"

@interface PSFacebookCenter : PSObject <FBDialogDelegate, FBSessionDelegate, UIAlertViewDelegate> {
  Facebook *_facebook;
  NSArray *_newPermissions;
}

+ (id)defaultCenter;

- (BOOL)handleOpenURL:(NSURL *)url;

// Login
- (BOOL)isLoggedIn;

// Permissions
- (void)authorizeBasicPermissions;
- (BOOL)hasPublishStreamPermission;
- (void)requestPublishStream;
- (NSArray *)availableExtendedPermissions;
- (void)addExtendedPermission:(NSString *)permission;

// Dialog
- (void)showDialog:(NSString *)dialog andParams:(NSMutableDictionary *)params;

@end
