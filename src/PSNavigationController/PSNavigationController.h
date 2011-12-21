//
//  PSNavigationController.h
//  OSnap
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSNavigationControllerDelegate;

@class PSViewController;

@interface PSNavigationController : UIViewController <UIGestureRecognizerDelegate> {
  NSMutableArray *_viewControllers;
  UIViewController *_disappearingViewController;
  UIView *_overlayView;
  
  id <PSNavigationControllerDelegate> _delegate;
}

@property (nonatomic, assign) id <PSNavigationControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *viewControllers; // expect non-mutable as param to setter

// Getter
@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, readonly) UIViewController *rootViewController;

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
- (void)navController:(PSNavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navController:(PSNavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navController:(PSNavigationController *)navigationController willHideViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navController:(PSNavigationController *)navigationController didHideViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end