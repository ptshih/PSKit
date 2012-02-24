//
//  PSGalleryView.h
//  PSKit
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSGalleryViewDelegate, PSGalleryViewDataSource;

@interface PSGalleryView : UIScrollView <NSCoding, UIGestureRecognizerDelegate>

@property (nonatomic, retain) NSMutableSet *reuseableViews;
@property (nonatomic, retain) NSMutableDictionary *visibleViews;
@property (nonatomic, retain) NSMutableArray *viewKeysToRemove;
@property (nonatomic, assign) CGFloat rowHeight;
@property (nonatomic, assign) NSInteger numCols;
@property (nonatomic, assign) id <PSGalleryViewDelegate> galleryViewDelegate;
@property (nonatomic, assign) id <PSGalleryViewDataSource> galleryViewDataSource;

#pragma mark - DataSource
- (void)reloadViews;

#pragma mark - Reusing Views
- (UIView *)dequeueReusableView;
- (void)enqueueReusableView:(UIView *)view;
- (void)removeAndAddCellsIfNecessary;


+ (NSString *)viewKeyForIndex:(NSInteger)index;

@end


@protocol PSGalleryViewDelegate <NSObject>
@optional
- (void)galleryView:(PSGalleryView *)galleryView didSelectViewAtIndex:(NSInteger)index;

@end

@protocol PSGalleryViewDataSource <NSObject>

@required
- (NSInteger)numberOfViewsInGalleryView:(PSGalleryView *)galleryView;
- (UIView *)galleryView:(PSGalleryView *)galleryView viewAtIndex:(NSInteger)index;

@end
