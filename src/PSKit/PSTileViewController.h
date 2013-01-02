//
//  PSTileViewController.h
//  PSKit
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "PSViewController.h"
#import "PSTileView.h"
#import "PSPullRefreshView.h"
#import "PSPullLoadMoreView.h"

@interface PSTileViewController : PSViewController <PSTileViewDelegate, PSTileViewDataSource, PSPullRefreshViewDelegate, PSPullLoadMoreViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *template;
@property (nonatomic, strong) PSTileView *tileView;
@property (nonatomic, strong) PSPullRefreshView *pullRefreshView;
@property (nonatomic, strong) PSPullLoadMoreView *pullLoadMoreView;

// Config
@property (nonatomic, assign) BOOL shouldPullRefresh;
@property (nonatomic, assign) BOOL shouldPullLoadMore;
@property (nonatomic, assign) PSPullRefreshStyle pullRefreshStyle;

@end
