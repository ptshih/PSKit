//
//  PSPullLoadMoreView.h
//  PSKit
//
//  Created by Peter Shih on 10/29/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PSPullLoadMoreViewDelegate;

typedef enum {
    PSPullLoadMoreStyleWhite = 0,
    PSPullLoadMoreStyleBlack = 1
} PSPullLoadMoreStyle;

typedef enum {
    PSPullLoadMoreStateIdle = 0,
    PSPullLoadMoreStateRefreshing,
    PSPullLoadMoreStateDisabled
} PSPullLoadMoreState;


@interface PSPullLoadMoreView : UIView

@property (nonatomic, unsafe_unretained) id <PSPullLoadMoreViewDelegate> delegate;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) PSPullLoadMoreState state;
@property (nonatomic, assign) PSPullLoadMoreStyle style;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *statusLabel;

- (id)initWithFrame:(CGRect)frame style:(PSPullLoadMoreStyle)style;

- (void)pullLoadMoreScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)pullLoadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)startSpinning;
- (void)stopSpinning;

@end

// Delegate
@protocol PSPullLoadMoreViewDelegate <NSObject>

@optional
- (void)pullLoadMoreViewDidBeginRefreshing:(PSPullLoadMoreView *)pullLoadMoreView;

@end