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
reusableCards = _reusableCards,
visibleCards = _visibleCards,
cardKeysToRemove = _cardKeysToRemove,
rowHeight = _rowHeight,
collectionViewDelegate = _collectionViewDelegate,
collectionViewDataSource = _collectionViewDataSource;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.reusableCards = [NSMutableSet set];
        self.visibleCards = [NSMutableDictionary dictionary];
        self.cardKeysToRemove = [NSMutableArray array];
        self.rowHeight = 0.0;
    }
    return self;
}

- (void)dealloc {
    // clear delegates
    self.collectionViewDataSource = nil;
    self.collectionViewDelegate = nil;
    
    // release retains
    self.reusableCards = nil;
    self.visibleCards = nil;
    self.cardKeysToRemove = nil;
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
    [self.cardKeysToRemove removeAllObjects];
    [_visibleCards enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
        CardView *card = (CardView *)obj;
        NSString *cardKey = (NSString *)key;
        CGFloat cardTop = card.top - CARD_SPACING;
        CGFloat cardBottom = card.bottom + CARD_SPACING;
        if (cardBottom < visibleTop || cardTop > visibleBottom) {
            CardView *discardedCard = [_visibleCards objectForKey:cardKey];
            [self enqueueReusableCardView:discardedCard];
            [self.cardKeysToRemove addObject:cardKey];
            NSLog(@"### Removing card at index: %@ ###", cardKey);
        }
    }];
    [_visibleCards removeObjectsForKeys:self.cardKeysToRemove];
    
    // Add cells if necessary
    NSInteger cardHeight = (NSInteger)_rowHeight + (NSInteger)CARD_SPACING;
    NSInteger topIndex = (NSInteger)visibleTop / cardHeight;
    if (topIndex < 0) topIndex = 0;
    NSInteger bottomIndex = (NSInteger)visibleBottom / cardHeight;
    if (bottomIndex >= numCards) bottomIndex = numCards - 1;
    
    for (int i = topIndex; i <= bottomIndex; i++) {
        NSString *cardKey = [[self class] cardKeyForIndex:i];
        CardView *visibleCard = [_visibleCards objectForKey:cardKey];
        if (!visibleCard) {
            CardView *newCardView = [self.collectionViewDataSource collectionView:self cardAtIndex:i];
            [newCardView setNeedsLayout];
            [_visibleCards setObject:newCardView forKey:cardKey];
            newCardView.top = (i * _rowHeight) + ((i + 1) * CARD_SPACING);
            newCardView.left = ceilf((self.width - newCardView.width) / 2);
            [self addSubview:newCardView];
            NSLog(@"### Adding card at index: %@ ###", cardKey);
        }
    }
    
    //  NSLog(@"visible cards: %@", _visibleCards);
}

#pragma mark - Card DataSource
- (void)reloadCards {
    // Find out how many cards are in the data source
    NSInteger numCards = 0;
    if (self.collectionViewDataSource && [self.collectionViewDataSource respondsToSelector:@selector(numberOfCardsInCollectionView:)]) {
        numCards = [self.collectionViewDataSource numberOfCardsInCollectionView:self];
    }
    
    // Remove all existing cards
    for (CardView *cardView in _visibleCards) {
        [self enqueueReusableCardView:cardView];
    }
    [_visibleCards removeAllObjects];
    
    // Calculate expected total height
    CGFloat totalHeight = (_rowHeight * numCards) + ((numCards + 1) * CARD_SPACING);
    self.contentSize = CGSizeMake(self.width, totalHeight);
    self.contentOffset = CGPointZero; // go back to top
    
    CGFloat yOffset = self.contentOffset.y - (CARD_SPACING / 2);
    CGFloat visibleTop = yOffset;
    CGFloat visibleBottom = yOffset + self.height;
    
    NSInteger cardHeight = (NSInteger)_rowHeight + CARD_SPACING;
    
    NSInteger topIndex = (NSInteger)visibleTop / cardHeight;
    if (topIndex < 0) topIndex = 0;
    NSInteger bottomIndex = (NSInteger)visibleBottom / cardHeight;
    if (bottomIndex >= numCards) bottomIndex = numCards - 1;
    
    // Add initially visible cards
    NSInteger numVisible = bottomIndex + 1;
    if (numVisible > numCards) numVisible = numCards;
    
    for (int i = 0; i < numVisible; i++) {
        CardView *newCardView = [self.collectionViewDataSource collectionView:self cardAtIndex:i];
        [newCardView setNeedsLayout];
        [_visibleCards setObject:newCardView forKey:[[self class] cardKeyForIndex:i]];
        newCardView.top = (i * _rowHeight) + ((i + 1) * CARD_SPACING);
        newCardView.left = ceilf((self.width - newCardView.width) / 2);
        [self addSubview:newCardView];
    }
    
    [self setNeedsLayout];
}

+ (NSString *)cardKeyForIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"pscv_key_%d", index];
}

#pragma mark - Reusing Card Views
- (CardView *)dequeueReusableCardView {
    CardView *cardView = [self.reusableCards anyObject];
    if (cardView) {
        // Found a reusable card view, remove it from the set
        [cardView retain];
        [self.reusableCards removeObject:cardView];
        [cardView autorelease];
    } else {
        cardView = [[[CardView alloc] initWithFrame:CGRectZero] autorelease];
        
        // Setup gesture recognizer
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectCard:)] autorelease];
        [cardView addGestureRecognizer:gr];
    }
    
    return cardView;
}

- (void)enqueueReusableCardView:(CardView *)cardView {
    [self.reusableCards addObject:cardView];
    [cardView removeFromSuperview];
}

#pragma mark - Gesture Recognizer
- (void)didSelectCard:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"card tapped: %@", gestureRecognizer.view);
}

@end
