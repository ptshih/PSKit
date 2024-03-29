//
//  PSPullRefreshView.m
//  PSKit
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSPullRefreshView.h"
#import "UIView+PSKit.h"

static NSString * const PSPullRefreshIdleStatus = @"Pull Down to Refresh";
static NSString * const PSPullRefreshTriggeredStatus = @"Release to Refresh";
static NSString * const PSPullRefreshRefreshingStatus = @"Loading...";

@implementation PSPullRefreshView

- (id)initWithFrame:(CGRect)frame style:(PSPullRefreshStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        self.state = PSPullRefreshStateIdle;
        
        self.style = style;
        
        UIImage *icon = nil;
        NSString *labelStyle = nil;
        if (self.style == PSPullRefreshStyleWhite) {
            icon = [UIImage imageNamed:@"PSPullRefreshView.bundle/IconRefreshWhite.png"];
            labelStyle = @"pullRefreshWhiteLabel";
        } else {
            icon = [UIImage imageNamed:@"PSPullRefreshView.bundle/IconRefreshBlack.png"];
            labelStyle = @"pullRefreshBlackLabel";
        }
        self.iconView = [[UIImageView alloc] initWithImage:icon];
        self.iconView.contentMode = UIViewContentModeCenter;
        self.iconView.frame = CGRectMake(0, 0, self.height, self.height);
        
        CGFloat width = 0.0;
        CGFloat left = 0.0;
        left = self.iconView.width;
        width = self.width - self.iconView.width * 2;
        
        self.statusLabel = [UILabel labelWithText:@"PSPullRefreshView Status" style:labelStyle];
        self.statusLabel.frame = CGRectMake(left, 0, width, self.height);
        self.statusLabel.autoresizingMask = self.autoresizingMask;
        self.statusLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:self.iconView];
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame style:PSPullRefreshStyleWhite];
    if (self) {
    }
    return self;
}


- (void)setState:(PSPullRefreshState)state {
    BOOL stateChanged = state != _state;
    _state = state;
    
    if (stateChanged) {
        switch (state) {
            case PSPullRefreshStateIdle:
            {
                self.statusLabel.text = PSPullRefreshIdleStatus;
                [self stopSpinning];
                
                if (!self.scrollView) return;
                
                BLOCK_SELF;
                [UIView animateWithDuration:0.2
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     blockSelf.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
                break;
            }
            case PSPullRefreshStateRefreshing:
            {
                [self startSpinning];
                self.statusLabel.text = PSPullRefreshRefreshingStatus;
                break;
            }
            default:
            {
                break;
            }
        }
    }
}

#pragma mark - Pass-thru UIScrollViewDelegate methods

- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = scrollView.contentOffset.y;
    
    // We update the visual/textual state of the view here
    // This gets called whenever the user is dragging the scrollView
    
    if (self.state == PSPullRefreshStateRefreshing) {
        // Currently actively refreshing, maintain a slight contentInset
        
        // This is a fix for section headers getting stuck during scrolling
        CGFloat offset = MAX(yOffset * -1, 0);
        offset = MIN(offset, self.height);
        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0, 0.0, 0.0);
    } else if (scrollView.isDragging) {
        // The user is actively dragging the scroll view
        if (yOffset < 0) {
            if (yOffset <= -self.height) {
                // Update status to show threshold has been triggered
                self.statusLabel.text = PSPullRefreshTriggeredStatus;
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.iconView.transform = CGAffineTransformMakeRotation(RADIANS(179.9999));
                                 }
                                 completion:^(BOOL finished){
                                 }];
            } else {
                // Update status to show threshold has not been triggered
                self.statusLabel.text = PSPullRefreshIdleStatus;
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseInOut
                                 animations:^{
                                     self.iconView.transform = CGAffineTransformIdentity;
                                 }
                                 completion:^(BOOL finished){
                                     
                                 }];
            }
        } else {
            self.state = PSPullRefreshStateIdle;
        }
    }
}

- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) return;
    
    CGFloat yOffset = scrollView.contentOffset.y;
    
    // We detect to see if the user dragged enough to trigger a refresh here
    if (yOffset <= -self.height && self.state == PSPullRefreshStateIdle) {
        self.state = PSPullRefreshStateRefreshing;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pullRefreshViewDidBeginRefreshing:)]) {
            [self.delegate pullRefreshViewDidBeginRefreshing:self];
        }
        
        if (!self.scrollView) return;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.scrollView.contentInset = UIEdgeInsetsMake(self.height, 0.0, 0.0, 0.0);
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }
}

- (void)startSpinning {
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:RADIANS(360) * INT_MAX * 3];
    rotationAnimation.duration = INT_MAX;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INT_MAX;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    
    [self.iconView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopSpinning {
    [self.iconView.layer removeAllAnimations];
    self.iconView.transform = CGAffineTransformIdentity;
}

@end
