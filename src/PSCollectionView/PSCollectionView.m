//
//  PSCollectionView.m
//  PSKit
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSCollectionView.h"
#import "UIView+PSKit.h"

#define VIEW_SPACING 8.0

static NSString *PSVisibleKeyForRow(NSInteger row) {
    return [NSString stringWithFormat:@"%d", row];
}

@implementation PSCollectionView

@synthesize
reuseableViews = _reuseableViews,
visibleViews = _visibleViews,
viewKeysToRemove = _viewKeysToRemove,
rowHeight = _rowHeight,
numCols = _numCols,
collectionViewDelegate = _collectionViewDelegate,
collectionViewDataSource = _collectionViewDataSource;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.reuseableViews = [NSMutableSet set];
        self.visibleViews = [NSMutableDictionary dictionary];
        self.viewKeysToRemove = [NSMutableArray array];
        self.rowHeight = 0.0;
        self.numCols = 0;
        self.scrollEnabled = YES;
        self.bounces = YES;
    }
    return self;
}

- (void)dealloc {
    // clear delegates
    self.collectionViewDataSource = nil;
    self.collectionViewDelegate = nil;
    
    // release retains
    self.reuseableViews = nil;
    self.visibleViews = nil;
    self.viewKeysToRemove = nil;
    [super dealloc];
}

#pragma mark - View
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self removeAndAddCellsIfNecessary];
}

- (void)removeAndAddCellsIfNecessary {
    static CGFloat margin = 8.0;
    
    NSInteger numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    NSInteger numRows = ceil((CGFloat)numViews / (CGFloat)self.numCols);
    
    // Find out what rows are visible
    CGFloat yOffset = self.contentOffset.y - margin; // subtract top margin
    NSInteger visibleRowTop = floor(yOffset / (self.rowHeight + margin));
    visibleRowTop = MAX(0, visibleRowTop);
    NSInteger visibleRowBottom = floor((yOffset + self.height) / (self.rowHeight + margin));
    visibleRowBottom = MIN(visibleRowBottom, numRows - 1);
    
//    NSLog(@"visible rows top: %d, bottom: %d", visibleRowTop, visibleRowBottom);
    
    // Remove cells if they are off screen
    for (NSInteger i = 0; i < visibleRowTop; i++) {
        // remove all rows above visibleRowTop
        NSString *key = PSVisibleKeyForRow(i);
        NSMutableArray *visibleViews = [self.visibleViews objectForKey:key];
        if (visibleViews) {
            NSLog(@"Removing row: %d", i);
            [visibleViews enumerateObjectsUsingBlock:^(UIView *discardedView, NSUInteger idx, BOOL *stop) {
                [self enqueueReusableView:discardedView];
            }];
            [visibleViews removeAllObjects];
            [self.visibleViews removeObjectForKey:key];
        }
    }
    
    for (NSInteger i = visibleRowBottom + 1; i < numRows; i++) {
        // remove all rows below visibleRowBottom
        NSString *key = PSVisibleKeyForRow(i);
        NSMutableArray *visibleViews = [self.visibleViews objectForKey:key];
        if (visibleViews) {
            NSLog(@"Removing row: %d", i);
            [visibleViews enumerateObjectsUsingBlock:^(UIView *discardedView, NSUInteger idx, BOOL *stop) {
                [self enqueueReusableView:discardedView];
            }];
            [visibleViews removeAllObjects];
            [self.visibleViews removeObjectForKey:key];
        }
    }
    
    // Add cells if necessary
    for (NSInteger i = visibleRowTop; i <= visibleRowBottom; i++) {
        // add cells for all rows within visible range
        NSString *key = PSVisibleKeyForRow(i);
        NSMutableArray *visibleViews = [self.visibleViews objectForKey:key];
        if (!visibleViews) {
            NSLog(@"Adding row: %d", i);
            visibleViews = [NSMutableArray array];
            // This row has no views, let's fill it
            for (NSInteger j = 0; j < self.numCols; j++) {
                NSInteger k = (i * self.numCols) + j;
                
                // If we ran out of views, stop populating
                if (k == numViews) break;
                
                UIView *newView = [self.collectionViewDataSource collectionView:self viewAtIndex:k];
                // Setup gesture recognizer
                if ([newView.gestureRecognizers count] == 0) {
                    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectView:)] autorelease];
                    [newView addGestureRecognizer:gr];
                    newView.userInteractionEnabled = YES;
                }
                
                // Set Frame
                newView.top = margin + (i * margin) + (i * self.rowHeight);
                newView.left = margin + (j * margin) + (j * 96.0);
                [newView setNeedsLayout];
                [self addSubview:newView];
                
                // Add
                [visibleViews addObject:newView];
            }
            [self.visibleViews setObject:visibleViews forKey:key];
        }
    }
}

#pragma mark - DataSource
- (void)reloadViews {
    static CGFloat margin = 8.0;
    
    BLOCK_SELF;
    
    // Remove all existing views
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSMutableArray *row = (NSMutableArray *)obj;
        [row enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [blockSelf enqueueReusableView:obj];
        }];
        [row removeAllObjects];
    }];
    [self.visibleViews removeAllObjects];
    
    // Find out how many views are in the data source
    NSInteger numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    NSInteger numRows = ceil((CGFloat)numViews / (CGFloat)self.numCols);

    // Calculate expected total height
    CGFloat totalHeight = (self.rowHeight * numRows) + (margin * numRows) + margin;
    self.contentSize = CGSizeMake(self.width, totalHeight);
    self.contentOffset = CGPointZero; // go back to top
    
    [self setNeedsLayout];
}

+ (NSString *)viewKeyForIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"pscv_key_%d", index];
}

#pragma mark - Reusing Views
- (UIView *)dequeueReusableView {
    UIView *view = [self.reuseableViews anyObject];
    if (view) {
        // Found a reusable view, remove it from the set
        [view retain];
        [self.reuseableViews removeObject:view];
        [view autorelease];
    }
    
    return view;
}

- (void)enqueueReusableView:(UIView *)view {
    [self.reuseableViews addObject:view];
    [view removeFromSuperview];
}

#pragma mark - Gesture Recognizer
- (void)didSelectView:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"view tapped: %@", gestureRecognizer.view);
}

@end
