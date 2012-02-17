//
//  PSNavigationController.m
//  OSnap
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSNavigationController.h"

@interface PSNavigationController (Private)

@end

@implementation PSNavigationController

@synthesize
overlayView = _overlayView,
delegate = _delegate,
disappearingViewController = _disappearingViewController,
topViewController = _topViewController,
rootViewController = _rootViewController,
viewControllers = _viewControllers;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.viewControllers = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        [self.viewControllers addObject:rootViewController];
    }
    return self;
}

- (void)viewDidUnload {
    RELEASE_SAFELY(_overlayView);
    [super viewDidUnload];
}

- (void)dealloc {  
    RELEASE_SAFELY(_overlayView);
    RELEASE_SAFELY(_viewControllers);
    [super dealloc];
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addChildViewController:self.rootViewController];
    [self.view addSubview:self.rootViewController.view];
    [self.rootViewController didMoveToParentViewController:self];
    self.rootViewController.view.frame = self.view.bounds;
    self.rootViewController.view.autoresizingMask = ~UIViewAutoresizingNone;
  
    
    _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _overlayView.exclusiveTouch = YES;
    _overlayView.backgroundColor = [UIColor blackColor];
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

#pragma mark - Push/Pop
const CGFloat kPushPopScale = 0.95;
const CGFloat kOverlayViewAlpha = 0.75;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self pushViewController:viewController direction:PSNavigationControllerDirectionLeft animated:animated];
}

- (void)pushViewController:(UIViewController *)viewController direction:(PSNavigationControllerDirection)direction animated:(BOOL)animated {
    UIViewController *disappearingViewController = nil;
    
    disappearingViewController = self.topViewController;
    [self addChildViewController:viewController];
    [self.viewControllers addObject:viewController];
    
    // Prepare view frames and add shadows
    CGRect offscreenFrame = self.view.bounds;
    CGSize shadowSize = CGSizeZero;
    switch (direction) {
        case PSNavigationControllerDirectionLeft:
            offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
            shadowSize = CGSizeMake(-5.0, 0.0);
            break;
        case PSNavigationControllerDirectionRight:
            offscreenFrame.origin.x = -CGRectGetMaxX(offscreenFrame);
            shadowSize = CGSizeMake(5.0, 0.0);
            break;
        case PSNavigationControllerDirectionUp:
            offscreenFrame.origin.y = CGRectGetMaxY(offscreenFrame);
            shadowSize = CGSizeMake(0.0, -5.0);
            break;
        case PSNavigationControllerDirectionDown:
            offscreenFrame.origin.y = -CGRectGetMaxY(offscreenFrame);
            shadowSize = CGSizeMake(0.0, 5.0);
            break;
        default:
            break;
    }
    self.topViewController.view.frame = offscreenFrame;
    self.topViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.topViewController.view.layer.shadowOffset = shadowSize;
    self.topViewController.view.layer.shadowOpacity = 0.75;
    self.topViewController.view.layer.shadowRadius = 5.0;
    self.topViewController.view.layer.shouldRasterize = YES;
    
    // Add Gray Layer
    _overlayView.frame = disappearingViewController.view.bounds;
    _overlayView.alpha = 0.0;
    [disappearingViewController.view addSubview:_overlayView];
    
    // Transition
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
    [self transitionFromViewController:disappearingViewController toViewController:self.topViewController duration:animationDuration options:animationOptions animations:^{
        self.topViewController.view.frame = self.view.bounds;
        disappearingViewController.view.transform = CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
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
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [self popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (UIViewController *)popViewControllerWithDirection:(PSNavigationControllerDirection)direction animated:(BOOL)animated {
    UIViewController *poppedViewController = nil;
    
    // Don't pop if at root
    if ([self.viewControllers count] == 1) return nil;
    
    poppedViewController = [self.topViewController retain];
    [self.viewControllers removeObject:poppedViewController];
    
    [poppedViewController willMoveToParentViewController:nil];
    
    // Add Shadow
    CGSize shadowSize = CGSizeZero;
    switch (direction) {
        case PSNavigationControllerDirectionLeft:
            shadowSize = CGSizeMake(5.0, 0.0);
            break;
        case PSNavigationControllerDirectionRight:
            shadowSize = CGSizeMake(-5.0, 0.0);
            break;
        case PSNavigationControllerDirectionUp:
            shadowSize = CGSizeMake(0.0, 5.0);
            break;
        case PSNavigationControllerDirectionDown:
            shadowSize = CGSizeMake(0.0, -5.0);
            break;
        default:
            break;
    }

    poppedViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    poppedViewController.view.layer.shadowOffset = shadowSize;
    poppedViewController.view.layer.shadowOpacity = 0.8;
    poppedViewController.view.layer.shadowRadius = 5.0;
    poppedViewController.view.layer.shouldRasterize = YES;
    
    // In case the previous view controller was reloaded due to memory, restore transform
    if (CGAffineTransformIsIdentity(self.topViewController.view.transform)) {
        self.topViewController.view.transform = CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
    }
    
    // Add Gray Layer
    _overlayView.frame = self.topViewController.view.bounds;
    _overlayView.alpha = kOverlayViewAlpha;
    [self.topViewController.view addSubview:_overlayView];
    
    // Transition
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
    [self transitionFromViewController:poppedViewController toViewController:self.topViewController duration:animationDuration options:animationOptions animations:^{
        [self.view exchangeSubviewAtIndex:[[self.view subviews] count] - 1 withSubviewAtIndex:[[self.view subviews] count] - 2];
        
        // Prepare view frames and add shadows
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
        
        _overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        // Remove shadow
        poppedViewController.view.layer.shadowColor = nil;
        poppedViewController.view.layer.shadowOffset = CGSizeZero;
        poppedViewController.view.layer.shadowOpacity = 0.0;
        poppedViewController.view.layer.shadowRadius = 0.0;
        poppedViewController.view.layer.shouldRasterize = NO;
        
        // Remove gray layer
        [_overlayView removeFromSuperview];
        
        [poppedViewController removeFromParentViewController];
        [poppedViewController release];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
    
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
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
    [self popViewControllerAnimated:animated];
    
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    return [self popToViewController:[self.viewControllers firstObject] animated:animated];
}

@end
