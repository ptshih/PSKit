//
//  PSNavigationController.h
//  OSnap
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This class does NOT manage a shared navigation bar.
 It is the responsibility of the view controller to present a navigation bar.
 PSViewController has an optional PSNavigationBar property that will add one.
 
 iOS5 only, uses view containment
 */

typedef void (^PSNavigationControllerCompletionBlock)(void);

typedef enum {
    PSNavigationControllerDirectionLeft = 1,
    PSNavigationControllerDirectionRight = 2,
    PSNavigationControllerDirectionUp = 3,
    PSNavigationControllerDirectionDown = 4
} PSNavigationControllerDirection;

@protocol PSNavigationControllerDelegate;

@class PSViewController;

@interface PSNavigationController : UIViewController <UIGestureRecognizerDelegate> {
}

@property (nonatomic, unsafe_unretained) id <PSNavigationControllerDelegate> delegate;
@property (nonatomic, weak) UIViewController *disappearingViewController;
@property (nonatomic, weak) UIViewController *topViewController;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, strong) NSMutableArray *viewControllers;

/**
 Convenience initializer
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;

/**
 Push and Pop
 */
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(PSNavigationControllerCompletionBlock)completionBlock;

- (void)pushViewController:(UIViewController *)viewController direction:(PSNavigationControllerDirection)direction animated:(BOOL)animated;
- (void)pushViewController:(UIViewController *)viewController direction:(PSNavigationControllerDirection)direction animated:(BOOL)animated completionBlock:(PSNavigationControllerCompletionBlock)completionBlock;

- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (UIViewController *)popViewControllerWithDirection:(PSNavigationControllerDirection)direction animated:(BOOL)animated;

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

- (UIViewController *)removeViewController:(UIViewController *)viewController;

@end

@protocol PSNavigationControllerDelegate <NSObject>

@optional
- (void)psNavigationController:(PSNavigationController *)psNavigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)psNavigationController:(PSNavigationController *)psNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)psNavigationController:(PSNavigationController *)psNavigationController willHideViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)psNavigationController:(PSNavigationController *)psNavigationController didHideViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
