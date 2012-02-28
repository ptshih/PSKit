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

@property (nonatomic, assign) UIView *overlayView;
@property (nonatomic, assign) id <PSPopoverViewDelegate> delegate;

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView;

- (void)show;
- (void)dismiss;

@end

@protocol PSPopoverViewDelegate <NSObject>

@optional
- (void)popoverViewDidDismiss:(PSPopoverView *)popoverView;

@end
