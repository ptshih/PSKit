//
//  PSReachabilityCenter.m
//  MealTime
//
//  Created by Peter Shih on 9/29/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSReachabilityCenter.h"
#import "Reachability.h"

@interface PSReachabilityCenter (Private)

- (void)registerForNetworkReachabilityNotifications;
- (void)unsubscribeFromNetworkReachabilityNotifications;
- (void)reachabilityChanged:(NSNotification *)note;

@end

@implementation PSReachabilityCenter

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
    [self registerForNetworkReachabilityNotifications];
  }
  return self;
}

- (void)dealloc {
  [self unsubscribeFromNetworkReachabilityNotifications];
  [super dealloc];
}

- (void)registerForNetworkReachabilityNotifications {
  [[Reachability reachabilityForInternetConnection] startNotifier];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)unsubscribeFromNetworkReachabilityNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)reachabilityChanged:(NSNotification *)note {
  // NOT IMPLEMENTED YET
}

- (BOOL)isNetworkReachable {
  return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);	
}

- (BOOL)isNetworkReachableViaWWAN {
	return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN);	
}

@end
