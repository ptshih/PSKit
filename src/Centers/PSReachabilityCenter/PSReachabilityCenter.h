//
//  PSReachabilityCenter.h
//  MealTime
//
//  Created by Peter Shih on 9/29/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSReachabilityCenter : NSObject

+ (id)defaultCenter;

- (BOOL)isNetworkReachable;
- (BOOL)isNetworkReachableViaWWAN;

@end
