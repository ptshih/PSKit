//
//  AirWomp.h
//  AirWomp
//
//  Created by Peter on 2/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AirWomp : NSObject

/**
 @method startSession
 @abstract Starts the AirWomp manager. This Singleton class manages all alerts
 in your application.
 @param The application key provided for you from us. (VERY IMPORTANT)
 */
+ (void)startSession:(NSString *)appKey;

/**
 @method presentAlertViewWithTarget
 @abstract Presents an alert with a follow up target and action.
 @param target The target for which the follow up action should be called on.
 @param action The selector for which the follow up action should be called.
 */
+ (void)presentAlertViewWithTarget:(id)target action:(SEL)action;

/**
 @method presentAlertViewWithTarget
 @abstract Presents an alert with a follow up block.
 @param block A block to execute after the alert dismisses.
 */
+ (void)presentAlertViewWithBlock:(void (^)(void))block;

@end
