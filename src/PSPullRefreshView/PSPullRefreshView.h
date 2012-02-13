//
//  PSPullRefreshView.h
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PSPullRefreshViewDelegate;

typedef enum {
    PSPullRefreshStateIdle = 0,
    PSPullRefreshStateRefreshing
} PSPullRefreshState;

@interface PSPullRefreshView : UIView

@property (nonatomic, assign) id <PSPullRefreshViewDelegate> delegate;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) PSPullRefreshState state;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *statusLabel;

- (void)pullRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pullRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)startSpinning;
- (void)stopSpinning;

@end

// Delegate
@protocol PSPullRefreshViewDelegate <NSObject>

@optional
- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView;

@end
