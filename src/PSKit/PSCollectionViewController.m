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

@synthesize
items = _items,
collectionView = _collectionView,
pullRefreshView = _pullRefreshView;

@synthesize
shouldPullRefresh = _shouldPullRefresh;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        
        // Config
        self.shouldPullRefresh = NO;
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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubviews {
    [super setupSubviews];
    
    CGFloat visibleHeaderHeight = self.headerView.bottom;
    CGFloat visibleFooterHeight = self.view.height - self.footerView.top;
    CGRect frame = CGRectMake(0, visibleHeaderHeight, self.view.width, self.view.height - visibleHeaderHeight - visibleFooterHeight);
    self.collectionView = [[PSCollectionView alloc] initWithFrame:frame];
    [self.view addSubview:self.collectionView];
    self.collectionView.delegate = self;
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (isDeviceIPad()) {
        self.collectionView.numColsPortrait = 4;
        self.collectionView.numColsLandscape = 5;
    } else {
        self.collectionView.numColsPortrait = 2;
        self.collectionView.numColsLandscape = 3;
    }
    
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:self.collectionView.bounds];
    [PSStyleSheet applyStyle:@"emptyLabel" forLabel:loadingLabel];
    loadingLabel.text = @"Loading...";
    self.collectionView.loadingView = loadingLabel;
    
    if (self.shouldPullRefresh) {
        [self setupPullRefresh];
    }
}

- (void)updateSubviews {
    [super updateSubviews];
    CGFloat visibleHeaderHeight = self.headerView.bottom;
    CGFloat visibleFooterHeight = self.view.height - self.footerView.top;
    CGRect frame = CGRectMake(0, visibleHeaderHeight, self.view.width, self.view.height - visibleHeaderHeight - visibleFooterHeight);
    self.collectionView.frame = frame;
}

- (void)setupPullRefresh {
    if (self.pullRefreshView == nil) {
        self.pullRefreshView = [[PSPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0 - 48.0, self.collectionView.frame.size.width, 48.0) style:PSPullRefreshStyleBlack];
        self.pullRefreshView.scrollView = self.collectionView;
        self.pullRefreshView.delegate = self;
        [self.collectionView addSubview:self.pullRefreshView];		
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

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    [self.collectionView reloadData];
    self.collectionView.contentOffset = self.contentOffset;
    [self endRefresh];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
    [self.collectionView reloadData];
    self.collectionView.contentOffset = CGPointZero;
    [self endRefresh];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

#pragma mark - PSCollectionViewDelegate
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [self.items count];
}

- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    return nil;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    return 0.0;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
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
}

#pragma mark - PSPullRefreshViewDelegate
- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView {
    [self reloadDataSource];
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

@end
