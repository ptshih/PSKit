//
//  PSTileView.h
//  PSKit
//
//  Created by Peter Shih on 12/3/12.
//
//

#import <UIKit/UIKit.h>

#import "PSTileViewCell.h"

#define kPSTileViewDidRelayoutNotification @"kPSTileViewDidRelayoutNotification"

@protocol PSTileViewDelegate, PSTileViewDataSource;

@interface PSTileView : UIScrollView

@property (nonatomic, unsafe_unretained) id <PSTileViewDelegate> tileViewDelegate;
@property (nonatomic, unsafe_unretained) id <PSTileViewDataSource> tileViewDataSource;

#pragma mark - Public Methods

/**
 Reloads the collection view
 This is similar to UITableView reloadData)
 */
- (void)reloadData;

/**
 Dequeues a reusable view that was previously initialized
 This is similar to UITableView dequeueReusableCellWithIdentifier
 */
- (PSTileViewCell *)dequeueReusableCellForClass:(Class)cellClass;

@end

#pragma mark - Delegate

@protocol PSTileViewDelegate <NSObject>

@optional
- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index;

- (void)tileView:(PSTileView *)tileView didReloadTemplateWithMap:(NSMutableDictionary *)indexToRectMap;

@end

#pragma mark - DataSource

@protocol PSTileViewDataSource <NSObject>

@required
- (NSInteger)numberOfTilesInTileView:(PSTileView *)tileView;
- (NSMutableArray *)templateForTileView:(PSTileView *)tileView;
- (PSTileViewCell *)tileView:(PSTileView *)tileView cellForItemAtIndex:(NSInteger)index;

@end
