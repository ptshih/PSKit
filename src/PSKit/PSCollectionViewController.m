//
//  PSCollectionViewController.m
//  PSKit
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionViewController.h"

@interface PSCollectionViewController ()

- (void)setupPullRefresh;

@end

@implementation PSCollectionViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        
        // Config
        self.shouldShowNullView = YES;
        self.shouldPullRefresh = NO;
        self.shouldPullLoadMore = NO;
        self.pullRefreshStyle = PSPullRefreshStyleBlack;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.collectionView.delegate = nil;
    self.collectionView.collectionViewDelegate = nil;
    self.collectionView.collectionViewDataSource = nil;
    
    self.pullRefreshView.delegate = nil;
}

- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.collectionViewDelegate = nil;
    self.collectionView.collectionViewDataSource = nil;
    
    self.pullRefreshView.delegate = nil;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubviews {
    [super setupSubviews];

    self.collectionView = [[PSCollectionView alloc] initWithFrame:self.contentView.bounds];
    self.collectionView.delegate = self;
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.contentView addSubview:self.collectionView];
    
    if (isDeviceIPad()) {
        self.collectionView.numColsPortrait = 3;
        self.collectionView.numColsLandscape = 4;
    } else {
        self.collectionView.numColsPortrait = 1;
        self.collectionView.numColsLandscape = 2;
    }
    
    if (self.shouldPullRefresh) {
        [self setupPullRefresh];
    }
    
    if (self.shouldPullLoadMore) {
        [self setupPullLoadMore];
    }
}

- (void)setupPullRefresh {
    if (self.pullRefreshView == nil) {
        self.pullRefreshView = [[PSPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0 - 48.0, self.collectionView.frame.size.width, 48.0) style:self.pullRefreshStyle];
        self.pullRefreshView.scrollView = self.collectionView;
        self.pullRefreshView.delegate = self;
        [self.collectionView addSubview:self.pullRefreshView];
        
        UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.pullRefreshView.height, self.pullRefreshView.width, 8.0) image:[[UIImage imageNamed:@"DropShadow"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pullRefreshView addSubview:ds];
    }
}

- (void)setupPullLoadMore {
    if (self.pullLoadMoreView == nil) {
        self.pullLoadMoreView = [[PSPullLoadMoreView alloc] initWithFrame:CGRectMake(0.0, self.collectionView.height, self.collectionView.frame.size.width, 48.0) style:self.pullRefreshStyle];
        self.pullLoadMoreView.scrollView = self.collectionView;
        self.pullLoadMoreView.delegate = self;
        [self.collectionView addSubview:self.pullLoadMoreView];
        
        UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, -8.0, self.pullLoadMoreView.width, 8.0) image:[[UIImage imageNamed:@"DropShadowInverted"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
        ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.pullLoadMoreView addSubview:ds];
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
    [super dataSourceDidLoad];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.collectionView reloadData];
        self.collectionView.contentOffset = self.contentOffset;
        
        if (self.collectionView.contentSize.height < self.collectionView.height) {
            self.pullLoadMoreView.state = PSPullLoadMoreStateDisabled;
            self.pullLoadMoreView.hidden = YES;
        } else {
            self.pullLoadMoreView.state = PSPullLoadMoreStateIdle;
            self.pullLoadMoreView.top = self.collectionView.contentSize.height;
            self.pullLoadMoreView.hidden = NO;
        }
    }];
    
    [self endRefresh];
}

- (void)dataSourceDidLoadMore {
    [super dataSourceDidLoadMore];
    [self.collectionView reloadData];
    
    if (self.collectionView.contentSize.height < self.collectionView.height) {
        self.pullLoadMoreView.state = PSPullLoadMoreStateDisabled;
        self.pullLoadMoreView.hidden = YES;
    } else {
        self.pullLoadMoreView.state = PSPullLoadMoreStateIdle;
        self.pullLoadMoreView.top = self.collectionView.contentSize.height;
        self.pullLoadMoreView.hidden = NO;
    }
    
    [self endLoadMore];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointZero;

    if (self.collectionView.contentSize.height < self.collectionView.height) {
        self.pullLoadMoreView.state = PSPullLoadMoreStateDisabled;
        self.pullLoadMoreView.hidden = YES;
    } else {
        self.pullLoadMoreView.state = PSPullLoadMoreStateIdle;
        self.pullLoadMoreView.top = self.collectionView.contentSize.height;
        self.pullLoadMoreView.hidden = NO;
    }
    
    [self endRefresh];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

#pragma mark - PSCollectionViewDelegate

- (Class)collectionView:(PSCollectionView *)collectionView cellClassForRowAtIndex:(NSInteger)index {
    return [PSCollectionViewCell class];
}

- (NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView {
    return [self.items count];
}

- (UIView *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index {
    return nil;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index {
    return 0.0;
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
