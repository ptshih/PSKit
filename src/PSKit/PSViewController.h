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

#import "CurtainController.h"

@interface PSViewController : UIViewController <PSStateMachine, CurtainControllerDelegate>

@property (nonatomic, strong) CurtainController *curtainController;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, weak) UIScrollView *activeScrollView; // subclasses should set this if they have a scrollView
@property (nonatomic, assign) CGPoint contentOffset;

// Config
@property (nonatomic, assign) BOOL shouldShowHeader;
@property (nonatomic, assign) BOOL shouldShowFooter;
@property (nonatomic, assign) BOOL shouldAddRoundedCorners;

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
