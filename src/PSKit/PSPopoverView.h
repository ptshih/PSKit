//
//  PSPopoverView.h
//  Phototime
//
//  Created by Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@protocol PSPopoverViewDelegate;

@interface PSPopoverView : PSView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, unsafe_unretained) id <PSPopoverViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView;
- (id)initWithTitle:(NSString *)title contentController:(UIViewController *)contentController;

- (void)showWithSize:(CGSize)size inView:(UIView *)view;
- (void)dismiss;

@end

@protocol PSPopoverViewDelegate <NSObject>

@optional
- (void)popoverViewDidDismiss:(PSPopoverView *)popoverView;

@end
