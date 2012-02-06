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

@interface PSViewController : UIViewController <PSStateMachine> {
  UIScrollView *_activeScrollView; // subclasses should set this if they have a scrollView
  UIView *_headerView;
  UIView *_contentView;
  UIView *_footerView;
}

@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIView *footerView;

/**
 Used to update the view when the orientation changes
 */
- (void)orientationChangedFromNotification:(NSNotification *)notification;

/**
 Used to update the currently active scrollview (for scrollsToTop fix)
 */
- (void)updateScrollsToTop:(BOOL)isEnabled;

@end
