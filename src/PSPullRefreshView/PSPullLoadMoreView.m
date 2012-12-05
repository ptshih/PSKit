//
//  PSPullLoadMoreView.m
//  PSKit
//
//  Created by Peter Shih on 10/29/12.
//
//

#import "PSPullLoadMoreView.h"
#import "UIView+PSKit.h"

static NSString * const PSPullLoadMoreIdleStatus = @"Pull Up to Load More";
static NSString * const PSPullLoadMoreTriggeredStatus = @"Release to Load More";
static NSString * const PSPullLoadMoreRefreshingStatus = @"Loading...";

@implementation PSPullLoadMoreView

- (id)initWithFrame:(CGRect)frame style:(PSPullLoadMoreStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        self.state = PSPullLoadMoreStateIdle;
        
        self.style = style;
        
        UIImage *icon = nil;
        NSString *labelStyle = nil;
        if (self.style == PSPullLoadMoreStyleWhite) {
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
        
        self.statusLabel = [UILabel labelWithText:@"PSPullLoadMoreView Status" style:labelStyle];
        self.statusLabel.frame = CGRectMake(left, 0, width, self.height);
        self.statusLabel.autoresizingMask = self.autoresizingMask;
        self.statusLabel.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:self.iconView];
        [self addSubview:self.statusLabel];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [self initWithFrame:frame style:PSPullLoadMoreStyleWhite];
    if (self) {
    }
    return self;
}

- (void)setState:(PSPullLoadMoreState)state {
    BOOL stateChanged = state != _state;
    _state = state;
    
    if (stateChanged) {
        switch (state) {
            case PSPullLoadMoreStateIdle:
            {
                self.statusLabel.text = PSPullLoadMoreIdleStatus;
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
            case PSPullLoadMoreStateRefreshing:
            {
                [self startSpinning];
                self.statusLabel.text = PSPullLoadMoreRefreshingStatus;
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

- (void)pullLoadMoreScrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentHeight = MAX(scrollView.contentSize.height, scrollView.height);
    CGFloat yOffset = scrollView.contentOffset.y + scrollView.height;
    
    // We update the visual/textual state of the view here
    // This gets called whenever the user is dragging the scrollView
    
    if (self.state == PSPullLoadMoreStateRefreshing) {
        // Currently actively refreshing, maintain a slight contentInset
        
        // This is a fix for section headers getting stuck during scrolling
//        CGFloat offset = MAX(yOffset * -1, 0);
//        offset = MIN(offset, self.height);
//        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0, 0.0, 0.0);
    } else if (scrollView.isDragging && self.state == PSPullLoadMoreStateIdle) {
        // The user is actively dragging the scroll view
        if (yOffset > contentHeight) {
            if (yOffset >= (contentHeight + self.height)) {
                // Update status to show threshold has been triggered
                self.statusLabel.text = PSPullLoadMoreTriggeredStatus;
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
                self.statusLabel.text = PSPullLoadMoreIdleStatus;
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
            self.state = PSPullLoadMoreStateIdle;
        }
    }
}

- (void)pullLoadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) return;
    CGFloat contentHeight = MAX(scrollView.contentSize.height, scrollView.height);
    CGFloat yOffset = scrollView.contentOffset.y + scrollView.height;
    
    // We detect to see if the user dragged enough to trigger a refresh here
    if (yOffset >= (contentHeight + self.height) && self.state == PSPullLoadMoreStateIdle) {
        self.state = PSPullLoadMoreStateRefreshing;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(pullLoadMoreViewDidBeginRefreshing:)]) {
            [self.delegate pullLoadMoreViewDidBeginRefreshing:self];
        }
        
        if (!self.scrollView) return;
        
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.height, 0.0);
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
