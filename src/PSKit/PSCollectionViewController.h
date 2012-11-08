//
//  PSCollectionViewController.h
//  PSKit
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSViewController.h"
#import "PSCollectionView.h"
#import "PSPullRefreshView.h"
#import "PSPullLoadMoreView.h"

@interface PSCollectionViewController : PSViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, PSPullRefreshViewDelegate, PSPullLoadMoreViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PSCollectionView *collectionView;
@property (nonatomic, strong) PSPullRefreshView *pullRefreshView;
@property (nonatomic, strong) PSPullLoadMoreView *pullLoadMoreView;

// Config
@property (nonatomic, assign) BOOL shouldPullRefresh;
@property (nonatomic, assign) BOOL shouldPullLoadMore;
@property (nonatomic, assign) PSPullRefreshStyle pullRefreshStyle;

@end
