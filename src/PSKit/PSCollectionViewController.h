//
//  PSCollectionViewController.h
//  PSKit
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"
#import "PSCollectionView.h"
#import "PSPullRefreshView.h"

@interface PSCollectionViewController : PSViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, PSPullRefreshViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PSCollectionView *collectionView;
@property (nonatomic, strong) PSPullRefreshView *pullRefreshView;

// Config
@property (nonatomic, assign) BOOL shouldPullRefresh;
@property (nonatomic, assign) PSPullRefreshStyle pullRefreshStyle;

@end
