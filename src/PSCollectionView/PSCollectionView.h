//
//  PSCollectionView.h
//  Rolodex
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardView.h"

@protocol PSCollectionViewDelegate, PSCollectionViewDataSource;

@interface PSCollectionView : UIScrollView <NSCoding, UIGestureRecognizerDelegate> {
  NSMutableSet *_reusableCards;
  NSMutableDictionary *_visibleCards;
  
  CGFloat _rowHeight;
  
  NSInteger _topIndex;
  NSInteger _bottomIndex;
  
  id <PSCollectionViewDelegate> _collectionViewDelegate;
  id <PSCollectionViewDataSource> _collectionViewDataSource;
}

@property (nonatomic, assign) CGFloat rowHeight;

@property (nonatomic, assign) id <PSCollectionViewDelegate> collectionViewDelegate;
@property (nonatomic, assign) id <PSCollectionViewDataSource> collectionViewDataSource;

#pragma mark - Card DataSource
- (void)reloadCards;

#pragma mark - Reusing Card Views
- (CardView *)dequeueReusableCardView;
- (void)enqueueReusableCardView:(CardView *)cardView;
- (void)updateCells;


+ (NSString *)cardKeyForIndex:(NSInteger)index;

@end


@protocol PSCollectionViewDelegate <NSObject>
@optional
- (void)collectionView:(PSCollectionView *)collectionView didSelectCardAtIndex:(NSInteger)index;

@end

@protocol PSCollectionViewDataSource <NSObject>

@required
- (NSInteger)numberOfCardsInCollectionView:(PSCollectionView *)collectionView;
- (CardView *)collectionView:(PSCollectionView *)collectionView cardAtIndex:(NSInteger)index;

@end