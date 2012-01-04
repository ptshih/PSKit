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

@synthesize drawerController = _drawerController;
@synthesize delegate = _delegate;
@synthesize viewControllers = _viewControllers;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.wantsFullScreenLayout = YES;
    _viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
  }
  return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController {
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    [self setViewControllers:[NSMutableArray arrayWithObject:rootViewController]];
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
- (void)loadView {
  // Setup the main container view
  CGRect frame = [[UIScreen mainScreen] applicationFrame];
  UIView *view = [[UIView alloc] initWithFrame:frame];
  view.backgroundColor = [UIColor blackColor];
  self.view = view;
  [view release];
  
  _overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
  _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _overlayView.exclusiveTouch = YES;
  _overlayView.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (!self.childViewControllers) {
    [self.topViewController viewWillAppear:animated];
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  if (!self.childViewControllers) {
    [self.topViewController viewDidAppear:animated];
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  if (!self.childViewControllers) {
    [self.topViewController viewWillDisappear:animated];
  }
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  if (!self.childViewControllers) {
    [self.topViewController viewDidDisappear:animated];
  }
}

#pragma mark - Getter/Setter
- (void)setViewControllers:(NSArray *)viewControllers {
  if (_viewControllers != viewControllers) {
    [_viewControllers makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_viewControllers release];
    _viewControllers = [viewControllers mutableCopy];
    
    for (UIViewController *viewController in _viewControllers) {
      if ([viewController isKindOfClass:[PSViewController class]]) {
        [(PSViewController *)viewController setPsNavigationController:self];
      }
    }
    
    // Show the top view controller without animation
    if (self.topViewController.wantsFullScreenLayout) {
      self.topViewController.view.frame = self.view.bounds;
    } else {
      CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
      self.topViewController.view.frame = CGRectMake(0.0, statusBarHeight, self.view.width, self.view.height - statusBarHeight);
    }
    [self.view addSubview:self.topViewController.view];
  }
}

- (UIViewController *)topViewController {
  UIViewController *topViewController = [_viewControllers lastObject];
  return topViewController;
}

- (UIViewController *)rootViewController {
  UIViewController *rootViewController = [_viewControllers firstObject];
  return rootViewController;
}

#pragma mark - Push/Pop
const CGFloat kPushPopScale = 0.95;
const CGFloat kOverlayViewAlpha = 0.75;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  _disappearingViewController = self.topViewController;
  [_viewControllers addObject:viewController];
  
  // Set psNavigationController property for new controller
  if ([self.topViewController isKindOfClass:[PSViewController class]]) {
    [(PSViewController *)self.topViewController setPsNavigationController:self];
  }
  
  // topViewController is now the new viewController
  [self.view addSubview:self.topViewController.view];
  
  // Let the views know of this event (in iOS4)
  if (!self.childViewControllers) {
    [self.topViewController viewWillAppear:animated];
    [_disappearingViewController viewWillDisappear:animated];
  }
  
  // Let the delegate know
  if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:willShowViewController:animated:)]) {
    [self.delegate psNavigationController:self willShowViewController:self.topViewController animated:YES];
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:willHideViewController:animated:)]) {
    [self.delegate psNavigationController:self willHideViewController:_disappearingViewController animated:YES];
  }
  
  // Prepare view frames
  CGRect offscreenFrame = CGRectZero;
  if (self.topViewController.wantsFullScreenLayout) {
    offscreenFrame = self.view.bounds;
  } else {
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    offscreenFrame = CGRectMake(0.0, statusBarHeight, self.view.width, self.view.height - statusBarHeight);
  }
  offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
  self.topViewController.view.frame = offscreenFrame;
  
  // Add Shadow
  self.topViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
  self.topViewController.view.layer.shadowOffset = CGSizeMake(-5, 0);
  self.topViewController.view.layer.shadowOpacity = 0.75;
  self.topViewController.view.layer.shadowRadius = 5.0;
  self.topViewController.view.layer.shouldRasterize = YES;
  
  // Add Gray Layer
  _overlayView.frame = _disappearingViewController.view.bounds;
  _overlayView.alpha = 0.0;
  [_disappearingViewController.view addSubview:_overlayView];
  
  // Transition
  UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
  NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
  
  [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
    if (self.topViewController.wantsFullScreenLayout) {
      self.topViewController.view.frame = self.view.bounds;
    } else {
      CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
      self.topViewController.view.frame = CGRectMake(0.0, statusBarHeight, self.view.width, self.view.height - statusBarHeight);
    }
    _disappearingViewController.view.transform = CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
    _overlayView.alpha = kOverlayViewAlpha;
    
  } completion:^(BOOL finished) {        
    // Remove shadow
    self.topViewController.view.layer.shadowColor = nil;
    self.topViewController.view.layer.shadowOffset = CGSizeZero;
    self.topViewController.view.layer.shadowOpacity = 0.0;
    self.topViewController.view.layer.shadowRadius = 0.0;
    self.topViewController.view.layer.shouldRasterize = NO;
    
    // Remove gray layer
    [_overlayView removeFromSuperview];
    
    // Let the delegate know
    if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:didShowViewController:animated:)]) {
      [self.delegate psNavigationController:self didShowViewController:self.topViewController animated:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:didHideViewController:animated:)]) {
      [self.delegate psNavigationController:self didHideViewController:_disappearingViewController animated:YES];
    }
    
    // Let the views know of this event (in iOS4)
    if (!self.childViewControllers) {
      [self.topViewController viewDidAppear:animated];
      [_disappearingViewController viewDidDisappear:animated];
    }
    
    // Remove old view
    [_disappearingViewController.view removeFromSuperview];
    _disappearingViewController = nil;
  }];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
  UIViewController *poppedViewController = nil;
  
  if ([_viewControllers count] > 1) {
    poppedViewController = [self.topViewController retain];
    _disappearingViewController = poppedViewController;
    
    // Remove from stack
    [_viewControllers removeObject:poppedViewController];
    
    // Add the new top view
    [self.view insertSubview:self.topViewController.view belowSubview:_disappearingViewController.view];
    
    // Let the views know of this event (in iOS4)
    if (!self.childViewControllers) {
      [self.topViewController viewWillAppear:animated];
      [_disappearingViewController viewWillDisappear:animated];
    }
    
    // Let the delegate know
    if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:willShowViewController:animated:)]) {
      [self.delegate psNavigationController:self willShowViewController:self.topViewController animated:YES];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:willHideViewController:animated:)]) {
      [self.delegate psNavigationController:self willHideViewController:_disappearingViewController animated:YES];
    }
    
    // Prepare view frames
    
    // Add Shadow
    _disappearingViewController.view.layer.shadowColor = [[UIColor blackColor] CGColor];
    _disappearingViewController.view.layer.shadowOffset = CGSizeMake(-5, 0);
    _disappearingViewController.view.layer.shadowOpacity = 0.8;
    _disappearingViewController.view.layer.shadowRadius = 5.0;
    _disappearingViewController.view.layer.shouldRasterize = YES;
    
    // Add Gray Layer
    _overlayView.frame = self.topViewController.view.bounds;
    _overlayView.alpha = kOverlayViewAlpha;
    [self.topViewController.view addSubview:_overlayView];
    
    self.topViewController.view.transform =  CGAffineTransformMakeScale(kPushPopScale, kPushPopScale);
    
    // Transition
    UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
      CGRect offscreenFrame = CGRectZero;
      if (_disappearingViewController.wantsFullScreenLayout) {
        offscreenFrame = self.view.bounds;
      } else {
        CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        offscreenFrame = CGRectMake(0.0, statusBarHeight, self.view.width, self.view.height - statusBarHeight);
      }
      offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
      _disappearingViewController.view.frame = offscreenFrame;

      self.topViewController.view.transform = CGAffineTransformIdentity;
      
      _overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
      // Remove shadow
      _disappearingViewController.view.layer.shadowColor = nil;
      _disappearingViewController.view.layer.shadowOffset = CGSizeZero;
      _disappearingViewController.view.layer.shadowOpacity = 0.0;
      _disappearingViewController.view.layer.shadowRadius = 0.0;
      _disappearingViewController.view.layer.shouldRasterize = NO;
      
      // Remove gray layer
      [_overlayView removeFromSuperview];
      
      // Let the delegate know
      if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:didShowViewController:animated:)]) {
        [self.delegate psNavigationController:self didShowViewController:self.topViewController animated:YES];
      }
      if (self.delegate && [self.delegate respondsToSelector:@selector(psNavigationController:didHideViewController:animated:)]) {
        [self.delegate psNavigationController:self didHideViewController:_disappearingViewController animated:YES];
      }
      
      // Let the views know of this event (in iOS4)
      if (!self.childViewControllers) {
        [self.topViewController viewDidAppear:animated];
        [_disappearingViewController viewDidDisappear:animated];
      }
      
      // Remove old view
      [_disappearingViewController.view removeFromSuperview];
      [_disappearingViewController release];
      _disappearingViewController = nil;
    }];
  }
  
  return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
  // Make sure the view controller is in the stack
  BOOL isInStack = [_viewControllers containsObject:viewController];
  if (!isInStack) return nil;
  
  // If the viewController is already at the top, don't do anything
  if ([self.topViewController isEqual:viewController]) {
    return nil;
  }
  
  NSMutableArray *poppedViewControllers = [NSMutableArray array];
  
  while (![[_viewControllers lastObject] isEqual:viewController]) {
    UIViewController *poppedViewController = [_viewControllers lastObject];
    [poppedViewControllers addObject:poppedViewController];
    [_viewControllers removeObject:poppedViewController];
  }
  
  // Add the previous top controller back
  [_viewControllers addObject:[poppedViewControllers firstObject]];
  
  // Pop the top view controller with or without animation
  [self popViewControllerAnimated:animated];
  
  return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
  return [self popToViewController:[_viewControllers firstObject] animated:animated];
}

- (void)removeViewController:(UIViewController *)viewController {
  // Don't remove the view controller if it is currently visible
  if (![viewController isEqual:[self topViewController]]) {
    [_viewControllers removeObject:viewController];
  }
}

@end
