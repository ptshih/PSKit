//
//  PSPullRefreshView.h
//  PSKit
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PSPullRefreshViewDelegate;

typedef enum {
    PSPullRefreshStyleWhite = 0,
    PSPullRefreshStyleBlack = 1
} PSPullRefreshStyle;

typedef enum {
    PSPullRefreshStateIdle = 0,
    PSPullRefreshStateRefreshing
} PSPullRefreshState;

@interface PSPullRefreshView : UIView

@property (nonatomic, assign) id <PSPullRefreshViewDelegate> delegate;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) PSPullRefreshState state;
@property (nonatomic, assign) PSPullRefreshStyle style;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *statusLabel;

- (id)initWithFrame:(CGRect)frame style:(PSPullRefreshStyle)style;

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
