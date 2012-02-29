//
//  PSCollectionViewController.h
//  PSKit
//
//  Created by Peter on 2/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSCollectionView.h"
#import "PSPullRefreshView.h"

@interface PSCollectionViewController : PSBaseViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, PSPullRefreshViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) PSCollectionView *collectionView;
@property (nonatomic, retain) PSPullRefreshView *pullRefreshView;

- (void)setupPullRefresh;

@end
