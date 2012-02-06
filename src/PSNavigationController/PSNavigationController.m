//
//  PSNavigationController.m
//  OSnap
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSNavigationController.h"
#import "PSViewController.h"

@interface PSNavigationController (Private)

@end

@implementation PSNavigationController

@synthesize
overlayView = _overlayView,
delegate = _delegate,
disappearingViewController = _disappearingViewController,
topViewController = _topViewController,
rootViewController = _rootViewController;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        [self addChildViewController:rootViewController];
    }
    return self;
}

- (void)viewDidUnload {
    RELEASE_SAFELY(_overlayView);
    RELEASE_SAFELY(_disappearingViewController);
    RELEASE_SAFELY(_topViewController);
    RELEASE_SAFELY(_rootViewController);
    [super viewDidUnload];
}

- (void)dealloc {  
    RELEASE_SAFELY(_overlayView);
    RELEASE_SAFELY(_disappearingViewController);
    RELEASE_SAFELY(_topViewController);
    RELEASE_SAFELY(_rootViewController);
    [super dealloc];
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.rootViewController.view];
    
    _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _overlayView.exclusiveTouch = YES;
    _overlayView.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (UIViewController *)topViewController {
    UIViewController *topViewController = [self.childViewControllers lastObject];
    return topViewController;
}

- (UIViewController *)rootViewController {
    UIViewController *rootViewController = [self.childViewControllers objectAtIndex:0];
    return rootViewController;
}

#pragma mark - Push/Pop
const CGFloat kPushPopScale = 0.95;
const CGFloat kOverlayViewAlpha = 0.75;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.disappearingViewController = self.topViewController;
    [self addChildViewController:viewController];
    
    // Prepare view frames
    CGRect offscreenFrame = CGRectZero;
    offscreenFrame = self.view.bounds;
    offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
    self.topViewController.view.frame = offscreenFrame;
    
    // Add Shadow
    self.topViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.topViewController.view.layer.shadowOffset = CGSizeMake(-5, 0);
    self.topViewController.view.layer.shadowOpacity = 0.75;
    self.topViewController.view.layer.shadowRadius = 5.0;
    self.topViewController.view.layer.shouldRasterize = YES;
    
    // Add Gray Layer
    _overlayView.frame = self.disappearingViewController.view.bounds;
    _overlayView.alpha = 0.0;
    [self.disappearingViewController.view addSubview:_overlayView];
    
    // Transition
    UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
    [self transitionFromViewController:self.disappearingViewController toViewController:self.topViewController duration:animationDuration options:animationOptions animations:^{
        self.topViewController.view.frame = self.view.bounds;
        self.disappearingViewController.view.transform = CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
    } completion:^(BOOL finished) {
        [self.topViewController didMoveToParentViewController:self];
        
        // Remove shadow
        self.topViewController.view.layer.shadowColor = nil;
        self.topViewController.view.layer.shadowOffset = CGSizeZero;
        self.topViewController.view.layer.shadowOpacity = 0.0;
        self.topViewController.view.layer.shadowRadius = 0.0;
        self.topViewController.view.layer.shouldRasterize = NO;
        
        // Remove gray layer
        [_overlayView removeFromSuperview];
    }];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    UIViewController *appearingViewController = nil;
    // Don't pop if at root
    if ([self.childViewControllers count] == 1) return nil;
    
    self.disappearingViewController = self.topViewController;
    appearingViewController = [self.childViewControllers objectAtIndex:[self.childViewControllers count] - 2];
    
    [self.disappearingViewController willMoveToParentViewController:nil];
    
    // Add Shadow
    self.disappearingViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.disappearingViewController.view.layer.shadowOffset = CGSizeMake(-5, 0);
    self.disappearingViewController.view.layer.shadowOpacity = 0.8;
    self.disappearingViewController.view.layer.shadowRadius = 5.0;
    self.disappearingViewController.view.layer.shouldRasterize = YES;
    
    // Add Gray Layer
    _overlayView.frame = appearingViewController.view.bounds;
    _overlayView.alpha = kOverlayViewAlpha;
    [appearingViewController.view addSubview:_overlayView];
    
    // Transition
    UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
    [self transitionFromViewController:self.disappearingViewController toViewController:appearingViewController duration:animationDuration options:animationOptions animations:^{
        [self.view exchangeSubviewAtIndex:[[self.view subviews] count] - 1 withSubviewAtIndex:[[self.view subviews] count] - 2];
        
        CGRect offscreenFrame = CGRectZero;
        offscreenFrame = self.view.bounds;
        offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
        self.disappearingViewController.view.frame = offscreenFrame;
        
        appearingViewController.view.transform = CGAffineTransformIdentity;
        
        _overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        // Remove shadow
        self.disappearingViewController.view.layer.shadowColor = nil;
        self.disappearingViewController.view.layer.shadowOffset = CGSizeZero;
        self.disappearingViewController.view.layer.shadowOpacity = 0.0;
        self.disappearingViewController.view.layer.shadowRadius = 0.0;
        self.disappearingViewController.view.layer.shouldRasterize = NO;
        
        // Remove gray layer
        [_overlayView removeFromSuperview];
        
        [self.disappearingViewController removeFromParentViewController];
    }];
    
    return self.disappearingViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    // Make sure the view controller is in the stack
//    BOOL isInStack = [_viewControllers containsObject:viewController];
//    if (!isInStack) return nil;
//    
//    // If the viewController is already at the top, don't do anything
//    if ([self.topViewController isEqual:viewController]) {
//        return nil;
//    }
//    
//    NSMutableArray *poppedViewControllers = [NSMutableArray array];
//    
//    while (![[_viewControllers lastObject] isEqual:viewController]) {
//        UIViewController *poppedViewController = [_viewControllers lastObject];
//        [poppedViewControllers addObject:poppedViewController];
//        [_viewControllers removeObject:poppedViewController];
//    }
//    
//    // Add the previous top controller back
//    [_viewControllers addObject:[poppedViewControllers firstObject]];
//    
//    // Pop the top view controller with or without animation
//    [self popViewControllerAnimated:animated];
//    
//    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
//    return [self popToViewController:[_viewControllers firstObject] animated:animated];
}

- (void)removeViewController:(UIViewController *)viewController {
    // Don't remove the view controller if it is currently visible
//    if (![viewController isEqual:[self topViewController]]) {
//        [_viewControllers removeObject:viewController];
//    }
}

@end
