//
//  PSTileViewController.m
//  PSKit
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "PSTileViewController.h"

@interface PSTileViewController ()

@end

@implementation PSTileViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        self.template = [NSMutableArray array];
        
        // Config
        self.shouldShowNullView = YES;
        self.shouldPullRefresh = NO;
        self.shouldPullLoadMore = NO;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tileViewDidRelayout:) name:kPSTileViewDidRelayoutNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.tileView.delegate = nil;
    self.tileView.tileViewDelegate = nil;
    self.tileView.tileViewDataSource = nil;
}

- (void)dealloc {
    self.tileView.delegate = nil;
    self.tileView.tileViewDelegate = nil;
    self.tileView.tileViewDataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tileView = [[PSTileView alloc] initWithFrame:self.contentView.bounds];
    self.tileView.delegate = self;
    self.tileView.tileViewDelegate = self;
    self.tileView.tileViewDataSource = self;
    self.tileView.backgroundColor = [UIColor clearColor];
    self.tileView.autoresizingMask = ~UIViewAutoresizingNone;
    
    [self.contentView addSubview:self.tileView];
    
    if (self.shouldPullRefresh) {
        [self setupPullRefresh];
    }
    
    if (self.shouldPullLoadMore) {
        [self setupPullLoadMore];
    }
}

- (void)setupPullRefresh {
    if (self.pullRefreshView == nil) {
        self.pullRefreshView = [[PSPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0 - 48.0, self.tileView.frame.size.width, 48.0) style:self.pullRefreshStyle];
        self.pullRefreshView.scrollView = self.tileView;
        self.pullRefreshView.delegate = self;
        [self.tileView addSubview:self.pullRefreshView];
        
        UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.pullRefreshView.height, self.pullRefreshView.width, 8.0) image:[[UIImage imageNamed:@"DropShadow"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pullRefreshView addSubview:ds];
    }
}

- (void)setupPullLoadMore {
    if (self.pullLoadMoreView == nil) {
        self.pullLoadMoreView = [[PSPullLoadMoreView alloc] initWithFrame:CGRectMake(0.0, self.tileView.height, self.tileView.frame.size.width, 48.0) style:self.pullRefreshStyle];
        self.pullLoadMoreView.scrollView = self.tileView;
        self.pullLoadMoreView.delegate = self;
        [self.tileView addSubview:self.pullLoadMoreView];
        
        UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, -8.0, self.pullLoadMoreView.width, 8.0) image:[[UIImage imageNamed:@"DropShadowInverted"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pullLoadMoreView addSubview:ds];
    }
}

- (void)tileViewDidRelayout:(NSNotification *)notification {
    if (self.pullLoadMoreView) {
        self.pullLoadMoreView.top = self.tileView.contentSize.height;
    }
}

#pragma mark - State Machine

- (void)loadDataSource {
    [super loadDataSource];
    [self beginRefresh];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    [self beginRefresh];
    self.contentOffset = CGPointZero;
}

- (void)loadMoreDataSource {
    [super loadMoreDataSource];
    [self beginLoadMore];
}

- (void)dataSourceDidLoad {
    [self.tileView reloadData];
    self.tileView.contentOffset = self.contentOffset;
    
    if (self.tileView.contentSize.height < self.tileView.height) {
        self.pullLoadMoreView.state = PSPullLoadMoreStateDisabled;
        self.pullLoadMoreView.hidden = YES;
    } else {
        self.pullLoadMoreView.state = PSPullLoadMoreStateIdle;
        self.pullLoadMoreView.top = self.tileView.contentSize.height;
        self.pullLoadMoreView.hidden = NO;
    }
    
    [super dataSourceDidLoad];
}

- (void)dataSourceDidLoadMore {
    [self.tileView reloadData];
    
    if (self.tileView.contentSize.height < self.tileView.height) {
        self.pullLoadMoreView.state = PSPullLoadMoreStateDisabled;
        self.pullLoadMoreView.hidden = YES;
    } else {
        self.pullLoadMoreView.state = PSPullLoadMoreStateIdle;
        self.pullLoadMoreView.top = self.tileView.contentSize.height;
        self.pullLoadMoreView.hidden = NO;
    }
    
    [super dataSourceDidLoadMore];
}

- (void)dataSourceDidError {
    [self.tileView reloadData];
    self.tileView.contentOffset = CGPointZero;
    
    if (self.tileView.contentSize.height < self.tileView.height) {
        self.pullLoadMoreView.state = PSPullLoadMoreStateDisabled;
        self.pullLoadMoreView.hidden = YES;
    } else {
        self.pullLoadMoreView.state = PSPullLoadMoreStateIdle;
        self.pullLoadMoreView.top = self.tileView.contentSize.height;
        self.pullLoadMoreView.hidden = NO;
    }
    
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

#pragma mark - PSTileViewDelegate

- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index {
    
}

#pragma mark - PSTileViewDataSource

- (NSInteger)numberOfTilesInTileView:(PSTileView *)tileView {
    return [self.items count];
}

- (NSMutableArray *)templateForTileView:(PSTileView *)tileView {
    return [NSMutableArray array];
}

- (PSTileViewCell *)tileView:(PSTileView *)tileView cellForItemAtIndex:(NSInteger)index {
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
    if (self.pullLoadMoreView) {
        [self.pullLoadMoreView pullLoadMoreScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (![[PSReachabilityCenter defaultCenter] isNetworkReachableViaWiFi]) {
        [[PSURLCache sharedCache] suspend];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidScroll:scrollView];
    }
    if (self.pullLoadMoreView) {
        [self.pullLoadMoreView pullLoadMoreScrollViewDidScroll:scrollView];
    }
}

#pragma mark - PSPullRefreshViewDelegate

- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView {
    [self reloadDataSource];
}

#pragma mark - PSPullLoadMoreViewDelegate

- (void)pullLoadMoreViewDidBeginRefreshing:(PSPullLoadMoreView *)pullLoadMoreView {
    [self loadMoreDataSource];
}

#pragma mark - Refresh

- (void)beginRefresh {
    [super beginRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateRefreshing];
}

- (void)endRefresh {
    [super endRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateIdle];
}

#pragma mark - Load More

- (void)beginLoadMore {
    [super beginLoadMore];
    [self.pullLoadMoreView setState:PSPullLoadMoreStateRefreshing];
}

- (void)endLoadMore {
    [super endLoadMore];
    [self.pullLoadMoreView setState:PSPullLoadMoreStateIdle];
}

@end
