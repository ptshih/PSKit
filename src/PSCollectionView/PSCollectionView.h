//
//  PSCollectionView.h
//  PSKit
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSCollectionViewDelegate, PSCollectionViewDataSource;

@interface PSCollectionView : UIScrollView <NSCoding, UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSMutableSet *reuseableViews;
@property (nonatomic, retain) NSMutableDictionary *visibleViews;
@property (nonatomic, retain) NSMutableArray *viewKeysToRemove;
@property (nonatomic, retain) NSMutableDictionary *indexToRectMap;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) NSInteger numCols;
@property (nonatomic, assign) id <PSCollectionViewDelegate> collectionViewDelegate;
@property (nonatomic, assign) id <PSCollectionViewDataSource> collectionViewDataSource;

#pragma mark - DataSource
- (void)reloadViews;

#pragma mark - Reusing Views
- (UIView *)dequeueReusableView;
- (void)enqueueReusableView:(UIView *)view;
- (void)removeAndAddCellsIfNecessary;

@end


@protocol PSCollectionViewDelegate <NSObject>
@optional
- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(UIView *)view atIndex:(NSInteger)index;

@end

@protocol PSCollectionViewDataSource <NSObject>

@required
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView;
- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index;
- (CGSize)sizeForViewAtIndex:(NSInteger)index;

@end