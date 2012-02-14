//
//  PSToastCenter.h
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    PSToastTypeAlert = 0,
    PSToastTypeWarning = 1,
    PSToastTypeError = 2
} PSToastType;

@interface PSToastCenter : PSObject {
    UIView *_toastView;
    UIButton *_toastButton;
    NSMutableArray *_toastQueue;
    
    NSTimeInterval _toastAnimationDuration;
    BOOL _isShowing;
}

+ (id)defaultCenter;

- (void)showToastWithMessage:(NSString *)toastMessage toastType:(PSToastType)toastType toastDuration:(NSTimeInterval)toastDuration;
- (void)showToastWithMessage:(NSString *)toastMessage toastType:(PSToastType)toastType toastDuration:(NSTimeInterval)toastDuration toastTarget:(id)toastTarget toastAction:(SEL)toastAction;
- (void)hideToast;

@end
