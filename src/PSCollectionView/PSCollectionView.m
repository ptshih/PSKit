//
//  PSCollectionView.m
//  PSKit
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSCollectionView.h"
#import "UIView+PSKit.h"

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
        self.numCols = 0;
        self.alwaysBounceVertical = YES;
        
//        [self addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
    return self;
}

- (void)dealloc {
//    [self removeObserver:self forKeyPath:@"contentOffset"];
    
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

#pragma mark - KVO
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if ([object isEqual:self]) {
//        [self removeAndAddCellsIfNecessary];
//    }
//}

#pragma mark - View
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self removeAndAddCellsIfNecessary];
}

- (void)removeAndAddCellsIfNecessary {
    static NSInteger topIndex = 0;
    static NSInteger bottomIndex = 0;
    
    NSInteger numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    
    if (numViews == 0) return;
    
    // Find out what rows are visible
    CGRect visibleRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.width, self.height);
    
    // Remove all rows that are not inside the visible rect
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView *view = (UIView *)obj;
        CGRect viewRect = view.frame;
        if (!CGRectIntersectsRect(visibleRect, viewRect)) {
            [self enqueueReusableView:view];
            [self.viewKeysToRemove addObject:key];
        }
    }];
    
    [self.visibleViews removeObjectsForKeys:self.viewKeysToRemove];
    [self.viewKeysToRemove removeAllObjects];
    
    if ([self.visibleViews count] == 0) {
        topIndex = 0;
        bottomIndex = numViews;
    } else {
        NSArray *sortedKeys = [[self.visibleViews allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
            if ([obj1 integerValue] < [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            } else if ([obj1 integerValue] > [obj2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }];
        topIndex = [[sortedKeys objectAtIndex:0] integerValue];
        bottomIndex = [[sortedKeys lastObject] integerValue];
        
        topIndex = MAX(0, topIndex - 20);
        bottomIndex = MIN(numViews, bottomIndex + 20);
    }
//    NSLog(@"topIndex: %d, bottomIndex: %d", topIndex, bottomIndex);
    
    // Add views
    for (NSInteger i = topIndex; i < bottomIndex; i++) {
        NSString *key = PSCollectionKeyForIndex(i);
        CGRect rect = CGRectFromString([self.indexToRectMap objectForKey:key]);
        
        // If view is within visible rect and is not already shown
        if (![self.visibleViews objectForKey:key] && CGRectIntersectsRect(visibleRect, rect)) {
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
        }
    }
}

#pragma mark - DataSource
- (void)reloadViews {
    static CGFloat margin = 8.0;
    
    NSInteger numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    
    // This is where we should layout the entire grid first
    
    // Reset all state
    [self.visibleViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        UIView *view = (UIView *)obj;
        [self enqueueReusableView:view];
    }];
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
        
        // Find the shortest column
        __block NSInteger col = 0;
        __block CGFloat h = 0.0;
        [colOffsets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == 0) {
                col = idx;
                h = [obj floatValue];
            } else if (h > [obj floatValue]) {
                col = idx;
            }
        }];
        
//        NSInteger col = i % self.numCols;
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
    if ([view respondsToSelector:@selector(prepareForReuse)]) {
        [view performSelector:@selector(prepareForReuse)];
    }
    view.frame = CGRectZero;
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
