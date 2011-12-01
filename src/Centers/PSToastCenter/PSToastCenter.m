//
//  PSToastCenter.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSToastCenter.h"
#import <QuartzCore/QuartzCore.h>

@interface PSToastCenter (Private)

- (void)setupToastView;
- (void)showToastFromDictionary:(NSDictionary *)dictionary;

@end

@implementation PSToastCenter

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    _toastQueue = [[NSMutableArray alloc] initWithCapacity:1];
    _toastAnimationDuration = 0.4;
    _isShowing = NO;
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_toastView);
  RELEASE_SAFELY(_toastButton);
  RELEASE_SAFELY(_toastQueue);
  [super dealloc];
}

#pragma mark - Setup
- (void)setupToastView {
  UIWindow *window = [UIApplication sharedApplication].keyWindow;
  if (!window) {
    window = [[UIApplication sharedApplication].windows objectAtIndex:0];
  }
  
  _toastView = [[UIView alloc] initWithFrame:CGRectMake(0, window.bounds.size.height, window.bounds.size.width, 44.0)];
  _toastView.backgroundColor = [UIColor clearColor];
  
  _toastButton = [[UIButton alloc] initWithFrame:_toastView.bounds];
  [_toastView addSubview:_toastButton];
  
  [window addSubview:_toastView];
}

#pragma mark - External Interface
- (void)showToastWithMessage:(NSString *)toastMessage toastType:(PSToastType)toastType toastDuration:(NSTimeInterval)toastDuration {
  [self showToastWithMessage:toastMessage toastType:toastType toastDuration:toastDuration toastTarget:nil toastAction:nil];
}

- (void)showToastWithMessage:(NSString *)toastMessage toastType:(PSToastType)toastType toastDuration:(NSTimeInterval)toastDuration toastTarget:(id)toastTarget toastAction:(SEL)toastAction {
  // Setup toastView if necessary
  if (!_toastView) {
    [self setupToastView];
  }
  
  // Attempt to show toast
  if (_isShowing) {
    // Add toast to queue
    NSDictionary *queuedToast = [NSDictionary dictionaryWithObjectsAndKeys:toastMessage, @"toastMessage", [NSNumber numberWithInteger:toastType], @"toastType", [NSNumber numberWithDouble:toastDuration], @"toastDuration", toastTarget, @"toastTarget", NSStringFromSelector(toastAction), @"toastAction", nil];
    [_toastQueue addObject:queuedToast];
  } else {
    // Show Toast
    _isShowing = YES;
    
    // Configure toast button
    [_toastButton setTitle:toastMessage forState:UIControlStateNormal];
    [_toastButton addTarget:toastTarget action:toastAction forControlEvents:UIControlEventTouchUpInside]; // optional
    [_toastButton setBackgroundImage:[UIImage imageNamed:@"bg_toast.png"] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:_toastAnimationDuration
                     animations:^{
                       _toastView.top -= _toastView.height;
                     }
                     completion:^(BOOL finished) {
                       // Toast Fully Shown, hide after delay if delay > 0
                       if (toastDuration > 0) {
                         [self performSelector:@selector(hideToast) withObject:nil afterDelay:toastDuration];
                       }
                     }];
  }
}

#pragma mark - Private Interface
- (void)hideToast {
  if (!_isShowing) return;
  
  [UIView animateWithDuration:_toastAnimationDuration
                   animations:^{
                     _toastView.top += _toastView.height;
                   }
                   completion:^(BOOL finished) {
                     // Toast Hidden
                     _isShowing = NO;
                     // Check for any remaining toasts to show
                     if ([_toastQueue count] > 0) {
                       NSDictionary *queuedToast = [_toastQueue objectAtIndex:0];
                       [[queuedToast retain] autorelease];
                       [_toastQueue removeObjectAtIndex:0];
                       [self showToastFromDictionary:queuedToast];
                     }
                   }];
}

- (void)showToastFromDictionary:(NSDictionary *)dictionary {
  [self showToastWithMessage:[dictionary objectForKey:@"toastMessage"] toastType:[[dictionary objectForKey:@"toastType"] integerValue] toastDuration:[[dictionary objectForKey:@"toastDuration"] doubleValue] toastTarget:[dictionary objectForKey:@"toastTarget"] toastAction:NSSelectorFromString([dictionary objectForKey:@"toastAction"])];
}

@end
