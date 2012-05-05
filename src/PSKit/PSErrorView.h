//
//  PSErrorView.h
//  PSKit
//
//  Created by Peter Shih on 4/9/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSErrorViewDelegate;

@interface PSErrorView : PSView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, unsafe_unretained) id <PSErrorViewDelegate> delegate;


- (void)showWithMessage:(NSString *)message inRect:(CGRect)rect;
- (void)dismiss;

@end

@protocol PSErrorViewDelegate <NSObject>

@optional
- (void)errorViewDidDismiss:(PSErrorView *)errorView;

@end
