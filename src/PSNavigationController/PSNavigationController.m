//
//  PSNavigationController.m
//  PSKit
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSNavigationController.h"

@interface PSNavigationController ()

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) BOOL isTransitioning;

@end

@implementation PSNavigationController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isTransitioning = NO;
        
        self.viewControllers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        if ([rootViewController isKindOfClass:[PSViewController class]]) {
            [(PSViewController *)rootViewController setNavigationController:self];
        }
        [self.viewControllers addObject:rootViewController];
    }
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewController:self.rootViewController];
    [self.view addSubview:self.rootViewController.view];
    [self.rootViewController didMoveToParentViewController:self];
    self.rootViewController.view.frame = self.view.bounds;
    self.rootViewController.view.autoresizingMask = ~UIViewAutoresizingNone;
  
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.exclusiveTouch = YES;
    self.overlayView.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIViewController *)topViewController {
    UIViewController *topViewController = [self.viewControllers lastObject];
    return topViewController;
}

- (UIViewController *)rootViewController {
    UIViewController *rootViewController = [self.viewControllers objectAtIndex:0];
    return rootViewController;
}

#pragma mark - Push
const CGFloat kPushPopScale = 0.95;
const CGFloat kOverlayViewAlpha = 0.75;
const CGFloat kAnimationDuration = 0.35;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self pushViewController:viewController direction:PSNavigationControllerDirectionLeft animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completionBlock:(PSNavigationControllerCompletionBlock)completionBlock {
    [self pushViewController:viewController direction:PSNavigationControllerDirectionLeft animated:animated completionBlock:completionBlock];
}

- (void)pushViewController:(UIViewController *)viewController direction:(PSNavigationControllerDirection)direction animated:(BOOL)animated {
    [self pushViewController:viewController direction:direction animated:animated completionBlock:NULL];
}

- (void)pushViewController:(UIViewController *)viewController direction:(PSNavigationControllerDirection)direction animated:(BOOL)animated completionBlock:(PSNavigationControllerCompletionBlock)completionBlock {
    
    if (!self.isTransitioning) {
        self.isTransitioning = YES;
    } else {
        return;
    }
    
    if ([viewController isKindOfClass:[PSViewController class]]) {
        [(PSViewController *)viewController setNavigationController:self];
    }
    
    UIViewController *disappearingViewController = nil;
    
    disappearingViewController = self.topViewController;
    [self addChildViewController:viewController];
    [self.viewControllers addObject:viewController];
    
    // Prepare view frames
    CGRect offscreenFrame = self.view.bounds;
    switch (direction) {
        case PSNavigationControllerDirectionLeft:
            offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
            break;
        case PSNavigationControllerDirectionRight:
            offscreenFrame.origin.x = -CGRectGetMaxX(offscreenFrame);
            break;
        case PSNavigationControllerDirectionUp:
            offscreenFrame.origin.y = CGRectGetMaxY(offscreenFrame);
            break;
        case PSNavigationControllerDirectionDown:
            offscreenFrame.origin.y = -CGRectGetMaxY(offscreenFrame);
            break;
        default:
            break;
    }
    self.topViewController.view.frame = offscreenFrame;
    
    // Add Gray Layer
    self.overlayView.frame = disappearingViewController.view.bounds;
    self.overlayView.alpha = 0.0;
    [disappearingViewController.view addSubview:self.overlayView];
    
    // Transition
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? kAnimationDuration : 0.0;
    [self transitionFromViewController:disappearingViewController toViewController:self.topViewController duration:animationDuration options:animationOptions animations:^{
        self.overlayView.alpha = kOverlayViewAlpha;
        self.topViewController.view.frame = self.view.bounds;
        disappearingViewController.view.transform = CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
    } completion:^(BOOL finished) {
        [self.topViewController didMoveToParentViewController:self];
        
        // Remove gray layer
        [self.overlayView removeFromSuperview];
        
        self.isTransitioning = NO;
        
        if (completionBlock) {
            completionBlock();
        }
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

#pragma mark - Pop
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [self popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:animated];
}

- (UIViewController *)popViewControllerWithDirection:(PSNavigationControllerDirection)direction animated:(BOOL)animated {
    // Don't pop if at root
    if ([self.viewControllers count] == 1) return nil;
    
    if (!self.isTransitioning) {
        self.isTransitioning = YES;
    } else {
        return nil;
    }
    
    UIViewController *poppedViewController = self.topViewController;
    [self.viewControllers removeObject:poppedViewController];
    
    [poppedViewController willMoveToParentViewController:nil];

    // In case the previous view controller was reloaded due to memory, restore transform

    // Reset hidden view controller's frame and transform
    self.topViewController.view.transform = CGAffineTransformIdentity;
    self.topViewController.view.frame = self.view.bounds;
    self.topViewController.view.transform = CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
    
    // Add Gray Layer
    self.overlayView.frame = self.topViewController.view.bounds;
    self.overlayView.alpha = kOverlayViewAlpha;
    [self.topViewController.view addSubview:self.overlayView];
    
    // Transition
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? kAnimationDuration : 0.0;
    [self transitionFromViewController:poppedViewController toViewController:self.topViewController duration:animationDuration options:animationOptions animations:^{
        [self.view exchangeSubviewAtIndex:[[self.view subviews] count] - 1 withSubviewAtIndex:[[self.view subviews] count] - 2];
        
        // Prepare view frames
        CGRect offscreenFrame = self.view.bounds;
        switch (direction) {
            case PSNavigationControllerDirectionLeft:
                offscreenFrame.origin.x = -CGRectGetMaxX(offscreenFrame);
                break;
            case PSNavigationControllerDirectionRight:
                offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
                break;
            case PSNavigationControllerDirectionUp:
                offscreenFrame.origin.y = -CGRectGetMaxY(offscreenFrame);
                break;
            case PSNavigationControllerDirectionDown:
                offscreenFrame.origin.y = CGRectGetMaxY(offscreenFrame);
                break;
            default:
                break;
        }
        
        poppedViewController.view.frame = offscreenFrame;
        
        self.topViewController.view.transform = CGAffineTransformIdentity;
        
        self.overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        // Remove gray layer
        [self.overlayView removeFromSuperview];
        
        [poppedViewController removeFromParentViewController];
        
        self.isTransitioning = NO;
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    return [self popToViewController:viewController direction:PSNavigationControllerDirectionRight animated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController direction:(PSNavigationControllerDirection)direction animated:(BOOL)animated {
    // Make sure the view controller is in the stack
    BOOL isInStack = [self.viewControllers containsObject:viewController];
    if (!isInStack) return nil;
    
    // If the viewController is already at the top, don't do anything
    if ([self.topViewController isEqual:viewController]) return nil;
    
    NSMutableArray *poppedViewControllers = [NSMutableArray array];
    
    while (![[self.viewControllers lastObject] isEqual:viewController]) {
        UIViewController *poppedViewController = [self.viewControllers lastObject];
        [poppedViewControllers addObject:poppedViewController];
        [self.viewControllers removeObject:poppedViewController];
    }
    
    // Add the previous top controller back
    [self.viewControllers addObject:[poppedViewControllers firstObject]];
    
    // Pop the top view controller with or without animation
    [self popViewControllerWithDirection:direction animated:animated];
    
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [self popToRootViewControllerWithDirection:PSNavigationControllerDirectionRight animated:animated];
}

- (NSArray *)popToRootViewControllerWithDirection:(PSNavigationControllerDirection)direction animated:(BOOL)animated {
    return [self popToViewController:[self.viewControllers firstObject] direction:direction animated:animated];
}

- (UIViewController *)removeViewController:(UIViewController *)viewController {
    // Make sure the view controller is in the stack
    BOOL isInStack = [self.viewControllers containsObject:viewController];
    if (!isInStack) return nil;
    
    // If the viewController is already at the top, don't do anything
    if ([self.topViewController isEqual:viewController]) return nil;
    
    [self.viewControllers removeObject:viewController];
    
    return viewController;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

@end
