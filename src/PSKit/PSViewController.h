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

//@class PSNavigationController;
//@class PSSpringboardController;
//@class PSCurtainController;
@class PSNullView;

@interface PSViewController : UIViewController <PSStateMachine>

// References
@property (nonatomic, assign) PSNavigationController *navigationController;
@property (nonatomic, assign) PSSpringboardController *springboardController;
@property (nonatomic, assign) PSCurtainController *curtainController;

@property (nonatomic, copy) NSArray *curtainItems;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) PSNullView *nullView;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *centerButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, weak) UIScrollView *activeScrollView; // subclasses should set this if they have a scrollView
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) UIImage *icon;

// Config
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) BOOL loadingMore;

@property (nonatomic, assign) BOOL shouldShowHeader;
@property (nonatomic, assign) BOOL shouldShowFooter;
@property (nonatomic, assign) BOOL shouldShowNullView;
@property (nonatomic, assign) BOOL shouldAddRoundedCorners;
@property (nonatomic, assign) BOOL shouldAdjustViewForKeyboard;

@property (nonatomic, strong) UIColor *nullBackgroundColor;
@property (nonatomic, strong) NSString *nullLabelStyle;
@property (nonatomic, assign) UIActivityIndicatorViewStyle nullIndicatorStyle;

@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;

@property (nonatomic, assign) CGFloat headerLeftWidth;
@property (nonatomic, assign) CGFloat headerRightWidth;

@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger offset;

/**
 Used to update the view when the orientation changes
 */
- (void)orientationChangedFromNotification:(NSNotification *)notification;

/**
 Used to update the currently active scrollview (for scrollsToTop fix)
 */
- (void)updateScrollsToTop:(BOOL)isEnabled;

- (void)addRoundedCorners;

- (void)layoutHeaderWithLeftWidth:(CGFloat)leftWidth rightWidth:(CGFloat)rightWidth;

@end
