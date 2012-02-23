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

static inline NSString * PSCollectionKeyForIndex(NSInteger index) {
    return [NSString stringWithFormat:@"%d", index];
}

static inline NSInteger PSCollectionIndexForKey(NSString *key) {
    return [key integerValue];
}

@implementation PSCollectionView

@synthesize
reuseableViews = _reuseableViews,
visibleViews = _visibleViews,
viewKeysToRemove = _viewKeysToRemove,
indexToRectMap = _indexToRectMap,
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
        self.indexToRectMap = [NSMutableDictionary dictionary];
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
    self.indexToRectMap = nil;
    [super dealloc];
}

#pragma mark - View
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self removeAndAddCellsIfNecessary];
}

- (void)removeAndAddCellsIfNecessary {
    static NSInteger topIndex = 0;
    static NSInteger bottomIndex = 0;
    
    NSInteger numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    
    // Find out what rows are visible
    CGRect visibleRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.width, self.height);
    
    // Remove all rows that are not inside the visible rect
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView *view = (UIView *)obj;
        CGRect viewRect = view.frame;
        if (CGRectIntersectsRect(visibleRect, viewRect) != 1) {
            [self.viewKeysToRemove addObject:key];
        }
    }];
    
    NSArray *keys = [self.visibleViews allKeys];                     
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^(id obj1, id obj2) {
    if ([obj1 integerValue] < [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    } else if ([obj1 integerValue] > [obj2 integerValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    } else {
        return (NSComparisonResult)NSOrderedSame;
    }
    }];
    
    if ([sortedKeys count] > 0) {
        topIndex = [[sortedKeys objectAtIndex:0] integerValue];
        bottomIndex = [[sortedKeys lastObject] integerValue];
//        NSLog(@"topIndex: %d bottomIndex: %d", topIndex, bottomIndex);
    } else {
        topIndex = 0;
        bottomIndex = 0;
    }
    
    for (NSString *key in self.viewKeysToRemove) {
        UIView *view = [self.visibleViews objectForKey:key];
        [view removeFromSuperview];
        [self.visibleViews removeObjectForKey:key];
    }
    [self.viewKeysToRemove removeAllObjects];
    
    // Add views
    for (NSInteger i = MAX(0, topIndex - 20); i < MIN(numViews, bottomIndex + 20); i++) {
        NSString *key = PSCollectionKeyForIndex(i);
        CGRect rect = CGRectFromString([self.indexToRectMap objectForKey:key]);
        
        // If view is within visible rect and is not already shown
        if (![self.visibleViews objectForKey:key] && (CGRectIntersectsRect(visibleRect, rect) == 1)) {
            // Only add views if not visible
            UIView *newView = [self.collectionViewDataSource collectionView:self viewAtIndex:i];
            newView.frame = CGRectFromString([self.indexToRectMap objectForKey:key]);
            [self addSubview:newView];
            
            // Setup gesture recognizer
            if ([newView.gestureRecognizers count] == 0) {
                UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectView:)] autorelease];
                [newView addGestureRecognizer:gr];
                newView.userInteractionEnabled = YES;
            }
            
            [self.visibleViews setObject:newView forKey:key];
            
            topIndex = (topIndex < i) ? topIndex : i;
            bottomIndex = (bottomIndex > i) ? bottomIndex : i;
        }
    }
}

#pragma mark - DataSource
- (void)reloadViews {
    static CGFloat margin = 8.0;
    
    NSInteger numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    
    // This is where we should layout the entire grid first
    
    // Reset all state
    [self.visibleViews removeAllObjects];
    [self.viewKeysToRemove removeAllObjects];
    [self.indexToRectMap removeAllObjects];
    
    // This array determines the last height offset on a column
    NSMutableArray *colOffsets = [NSMutableArray arrayWithCapacity:self.numCols];
    for (int i = 0; i < self.numCols; i++) {
        [colOffsets addObject:[NSNumber numberWithFloat:margin]];
    }
    
    // Calculate index to rect mapping
    CGFloat colWidth = floorf((self.width - margin * (self.numCols + 1)) / self.numCols);
    for (NSInteger i = 0; i < numViews; i++) {
        NSString *key = PSCollectionKeyForIndex(i);
        NSInteger col = i % self.numCols;
        CGFloat left = margin + (col * margin) + (col * colWidth);
        CGFloat top = [[colOffsets objectAtIndex:col] floatValue];
        CGSize size = [self.collectionViewDataSource sizeForViewAtIndex:i];
        if (CGSizeEqualToSize(CGSizeZero, size)) {
            // If size is unacceptable, default to square
            size = CGSizeMake(colWidth, colWidth);
        }
        CGFloat colHeight = floorf(size.height / (size.width / colWidth));
        
        if (top != top) {
            NSLog(@"nan");
        }
        
        CGRect viewRect = CGRectMake(left, top, colWidth, colHeight);
        
        // Add to index rect map
        [self.indexToRectMap setObject:NSStringFromCGRect(viewRect) forKey:key];
        
        // Update the last height offset for this column
        CGFloat test = top + colHeight + margin;
        
        if (test != test) {
            NSLog(@"nan");
        }
        [colOffsets replaceObjectAtIndex:col withObject:[NSNumber numberWithFloat:test]];
    }
    
    CGFloat totalHeight = 0.0;
    for (NSNumber *colHeight in colOffsets) {
        totalHeight = (totalHeight < [colHeight floatValue]) ? [colHeight floatValue] : totalHeight;
    }
    
    self.contentSize = CGSizeMake(self.width, totalHeight);
    self.contentOffset = CGPointZero;
    
    [self setNeedsLayout];
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
    NSLog(@"view tapped, no index here yet!: %@", gestureRecognizer.view);
    
    if (self.collectionViewDelegate && [self.collectionViewDelegate respondsToSelector:@selector(collectionView:didSelectView:atIndex:)]) {
        [self.collectionViewDelegate collectionView:self didSelectView:gestureRecognizer.view atIndex:0];
    }
}

@end
