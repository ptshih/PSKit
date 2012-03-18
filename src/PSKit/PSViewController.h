//
//  PSViewController.h
//  PSKit
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PSStateMachine.h"

#import "PSNavigationController.h"

@interface PSViewController : UIViewController <PSStateMachine>

@property (nonatomic, assign) UIView *headerView;
@property (nonatomic, assign) UIView *footerView;
@property (nonatomic, assign) UIScrollView *activeScrollView; // subclasses should set this if they have a scrollView
@property (nonatomic, assign) CGPoint contentOffset;

/**
 Used to update the view when the orientation changes
 */
- (void)orientationChangedFromNotification:(NSNotification *)notification;

/**
 Used to update the currently active scrollview (for scrollsToTop fix)
 */
- (void)updateScrollsToTop:(BOOL)isEnabled;

- (void)addRoundedCorners;

@end
