//
//  PSNavigationController.h
//  OSnap
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSDrawerController.h"

/**
 This class does NOT manage a shared navigation bar.
 It is the responsibility of the view controller to present a navigation bar.
 PSViewController has an optional PSNavigationBar property that will add one.
 
 iOS5 only, uses view containment
 */

@protocol PSNavigationControllerDelegate;

@class PSViewController;

@interface PSNavigationController : UIViewController <UIGestureRecognizerDelegate> {
}

@property (nonatomic, assign) UIView *overlayView;
@property (nonatomic, assign) id <PSNavigationControllerDelegate> delegate;
@property (nonatomic, retain) UIViewController *disappearingViewController;
@property (nonatomic, retain) UIViewController *topViewController;
@property (nonatomic, retain) UIViewController *rootViewController;

/**
 Convenience initializer
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/**
 Push and Pop
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;
- (void)removeViewController:(UIViewController *)viewController; // Remove a VC from the stack without popping

@end

@protocol PSNavigationControllerDelegate <NSObject>

@optional
- (void)psNavigationController:(PSNavigationController *)psNavigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)psNavigationController:(PSNavigationController *)psNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)psNavigationController:(PSNavigationController *)psNavigationController willHideViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)psNavigationController:(PSNavigationController *)psNavigationController didHideViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end