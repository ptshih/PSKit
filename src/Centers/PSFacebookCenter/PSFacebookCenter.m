//
//  PSFacebookCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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
    if ([defaults objectForKey:@"facebookAccessToken"] && [defaults objectForKey:@"facebookExpirationDate"]) {
      _facebook.accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
      _facebook.expirationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookExpirationDate"];
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
  return [_facebook isSessionValid];
}

#pragma mark - Permissions
- (void)authorizeBasicPermissions {
  // Check if already authorized
  if (![_facebook isSessionValid]) {
    [_facebook authorize:FB_BASIC_PERMISISONS];
  }
}

- (BOOL)hasPublishStreamPermission {
  return [[[NSUserDefaults standardUserDefaults] objectForKey:@"facebookExtendedPermissions"] containsObject:FB_PERMISSIONS_PUBLISH];
}

- (NSArray *)availableExtendedPermissions {
  return [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookExtendedPermissions"];
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
    [[NSUserDefaults standardUserDefaults] setObject:_newPermissions forKey:@"facebookExtendedPermissions"];
    [_newPermissions release], _newPermissions = nil;
  }
  [[NSUserDefaults standardUserDefaults] setObject:_facebook.accessToken forKey:@"facebookAccessToken"];
  [[NSUserDefaults standardUserDefaults] setObject:_facebook.expirationDate forKey:@"facebookExpirationDate"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidSucceed object:nil];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
  [_newPermissions release], _newPermissions = nil;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kPSFacebookCenterDialogDidFail object:nil];
}

- (void)fbDidLogout {
  
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == alertView.cancelButtonIndex) return;
  
  if (alertView.tag == kAlertFacebookPermissionsPublish) {
    [self addExtendedPermission:FB_PERMISSIONS_PUBLISH];
  }
}

@end
