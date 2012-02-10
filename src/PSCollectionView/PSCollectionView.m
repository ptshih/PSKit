//
//  PSCollectionView.m
//  PSKit
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSCollectionView.h"

#define CARD_SPACING 10.0

@implementation PSCollectionView

@synthesize
reuseableViews = _reuseableViews,
visibleViews = _visibleViews,
viewKeysToRemove = _viewKeysToRemove,
rowHeight = _rowHeight,
collectionViewDelegate = _collectionViewDelegate,
collectionViewDataSource = _collectionViewDataSource;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.reuseableViews = [NSMutableSet set];
        self.visibleViews = [NSMutableDictionary dictionary];
        self.viewKeysToRemove = [NSMutableArray array];
        self.rowHeight = 0.0;
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
    NSInteger numCards = [self.collectionViewDataSource numberOfCardsInCollectionView:self];
    
    CGFloat yOffset = self.contentOffset.y - (CARD_SPACING / 2);
    CGFloat visibleTop = yOffset;
    CGFloat visibleBottom = yOffset + self.height;
    
    // Remove cells if they are off screen
    [self.viewKeysToRemove removeAllObjects];
    [_visibleViews enumerateKeysAndObjectsUsingBlock:^(NSString *key, UIView *view, BOOL *stop){
        CGFloat top = view.top - CARD_SPACING;
        CGFloat bottom = view.bottom + CARD_SPACING;
        if (bottom < visibleTop || top > visibleBottom) {
            UIView *discardedView = [self.visibleViews objectForKey:key];
            [self enqueueReusableView:discardedView];
            [self.viewKeysToRemove addObject:key];
            NSLog(@"### Removing view at index: %@ ###", key);
        }
    }];
    [self.visibleViews removeObjectsForKeys:self.viewKeysToRemove];
    
    // Add cells if necessary
    NSInteger cardHeight = (NSInteger)_rowHeight + (NSInteger)CARD_SPACING;
    NSInteger topIndex = (NSInteger)visibleTop / cardHeight;
    if (topIndex < 0) topIndex = 0;
    NSInteger bottomIndex = (NSInteger)visibleBottom / cardHeight;
    if (bottomIndex >= numCards) bottomIndex = numCards - 1;
    
    for (int i = topIndex; i <= bottomIndex; i++) {
        NSString *viewKey = [[self class] viewKeyForIndex:i];
        UIView *visibleView = [self.visibleViews objectForKey:viewKey];
        if (!visibleView) {
            UIView *newView = [self.collectionViewDataSource collectionView:self viewAtIndex:i];
            [newView setNeedsLayout];
            [self.visibleViews setObject:newView forKey:viewKey];
            newView.top = (i * self.rowHeight) + ((i + 1) * CARD_SPACING);
            newView.left = ceilf((self.width - newView.width) / 2);
            [self addSubview:newView];
            NSLog(@"### Adding card at index: %@ ###", viewKey);
        }
    }
    
    //  NSLog(@"visible cards: %@", _visibleCards);
}

#pragma mark - Card DataSource
- (void)reloadViews {
    // Find out how many views are in the data source
    NSInteger numViews = 0;
    if (self.collectionViewDataSource && [self.collectionViewDataSource respondsToSelector:@selector(numberOfCardsInCollectionView:)]) {
        numViews = [self.collectionViewDataSource numberOfViewsInCollectionView:self];
    }
    
    // Remove all existing cards
    for (UIView *view in self.visibleViews) {
        [self enqueueReusableView:view];
    }
    [self.visibleViews removeAllObjects];
    
    // Calculate expected total height
    CGFloat totalHeight = (self.rowHeight * numViews) + ((numViews + 1) * CARD_SPACING);
    self.contentSize = CGSizeMake(self.width, totalHeight);
    self.contentOffset = CGPointZero; // go back to top
    
    CGFloat yOffset = self.contentOffset.y - (CARD_SPACING / 2);
    CGFloat visibleTop = yOffset;
    CGFloat visibleBottom = yOffset + self.height;
    
    NSInteger viewHeight = (NSInteger)self.rowHeight + CARD_SPACING;
    
    NSInteger topIndex = (NSInteger)visibleTop / viewHeight;
    if (topIndex < 0) topIndex = 0;
    NSInteger bottomIndex = (NSInteger)visibleBottom / viewHeight;
    if (bottomIndex >= numViews) bottomIndex = numViews - 1;
    
    // Add initially visible cards
    NSInteger numVisible = bottomIndex + 1;
    if (numVisible > numViews) numVisible = numViews;
    
    for (int i = 0; i < numVisible; i++) {
        UIView *newView = [self.collectionViewDataSource collectionView:self viewAtIndex:i];
        [newView setNeedsLayout];
        [self.visibleViews setObject:newView forKey:[[self class] viewKeyForIndex:i]];
        newView.top = (i * self.rowHeight) + ((i + 1) * CARD_SPACING);
        newView.left = ceilf((self.width - newView.width) / 2);
        [self addSubview:newView];
    }
    
    [self setNeedsLayout];
}

+ (NSString *)viewKeyForIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"pscv_key_%d", index];
}

#pragma mark - Reusing Card Views
- (UIView *)dequeueReusableView {
    UIView *view = [self.reuseableViews anyObject];
    if (view) {
        // Found a reusable card view, remove it from the set
        [view retain];
        [self.reuseableViews removeObject:view];
        [view autorelease];
    } else {
        view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        
        // Setup gesture recognizer
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectView:)] autorelease];
        [view addGestureRecognizer:gr];
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
