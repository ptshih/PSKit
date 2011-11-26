//
//  PSCollectionView.m
//  Rolodex
//
//  Created by Peter Shih on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCollectionView.h"

#define CARD_SPACING 10.0

@implementation PSCollectionView

@synthesize rowHeight = _rowHeight;
@synthesize collectionViewDelegate = _collectionViewDelegate;
@synthesize collectionViewDataSource = _collectionViewDataSource;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _reusableCards = [[NSMutableSet alloc] initWithCapacity:1];
    _visibleCards = [[NSMutableDictionary alloc] initWithCapacity:1];
    
    _rowHeight = 0.0;
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_reusableCards);
  RELEASE_SAFELY(_visibleCards);
  [super dealloc];
}

#pragma mark - View
- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self updateCells];
}

- (void)updateCells {
  NSInteger numCards = [self.collectionViewDataSource numberOfCardsInCollectionView:self];
  
  CGFloat yOffset = self.contentOffset.y - (CARD_SPACING / 2);
  CGFloat visibleTop = yOffset;
  CGFloat visibleBottom = yOffset + self.height;
  NSInteger cardHeight = (NSInteger)_rowHeight + (NSInteger)CARD_SPACING;
  
  NSInteger topIndex = (NSInteger)visibleTop / cardHeight;
  if (topIndex < 0) topIndex = 0;
  NSInteger bottomIndex = (NSInteger)visibleBottom / cardHeight;
  if (bottomIndex >= numCards) bottomIndex = numCards - 1;
  
//  NSLog(@"visibleTop: %f, visibleBottom: %f, topIndex: %d, bottomIndex: %d, yOffset: %f", visibleTop, visibleBottom, topIndex, bottomIndex, yOffset);
  
  // Add new cell that just scrolled onto the screen
  if (topIndex < _topIndex) {
    NSString *cardKey = [[self class] cardKeyForIndex:topIndex];
    CardView *newCardView = [self.collectionViewDataSource collectionView:self cardAtIndex:topIndex];
    [_visibleCards setObject:newCardView forKey:cardKey];
    newCardView.top = (topIndex * _rowHeight) + ((topIndex + 1) * CARD_SPACING);
    newCardView.left = ceilf((self.width - newCardView.width) / 2);
    [self addSubview:newCardView];
    NSLog(@"add top card");
  }
  
  if (bottomIndex > _bottomIndex) {
    NSString *cardKey = [[self class] cardKeyForIndex:bottomIndex];
    CardView *newCardView = [self.collectionViewDataSource collectionView:self cardAtIndex:bottomIndex];
    [_visibleCards setObject:newCardView forKey:cardKey];
    newCardView.top = (bottomIndex * _rowHeight) + ((bottomIndex + 1) * CARD_SPACING);
    newCardView.left = floorf((self.width - newCardView.width) / 2);
    [self addSubview:newCardView];
    NSLog(@"add bottom card");
  }

  // Remove cells scrolled off top of the screen
  if (topIndex > _topIndex) {
    NSString *cardKey = [[self class] cardKeyForIndex:_topIndex];
    CardView *discardedCard = [_visibleCards objectForKey:cardKey];
    [self enqueueReusableCardView:discardedCard];
    [discardedCard removeFromSuperview];
    [_visibleCards removeObjectForKey:cardKey];
    NSLog(@"remove top card");
  }
  
  // Remove cells scrolled off bottom of the screen
  if (bottomIndex < _bottomIndex) {
    NSString *cardKey = [[self class] cardKeyForIndex:_bottomIndex];
    CardView *discardedCard = [_visibleCards objectForKey:cardKey];
    [self enqueueReusableCardView:discardedCard];
    [discardedCard removeFromSuperview];
    [_visibleCards removeObjectForKey:cardKey];
    NSLog(@"remove bottom card");
  }

  _topIndex = topIndex;
  _bottomIndex = bottomIndex;
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
    [cardView removeFromSuperview];
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
  
  _topIndex = topIndex;
  _bottomIndex = bottomIndex;
  
  for (int i = 0; i < numVisible; i++) {
    CardView *newCardView = [self.collectionViewDataSource collectionView:self cardAtIndex:i];
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
  CardView *cardView = [_reusableCards anyObject];
  if (cardView) {
    // Found a reusable card view, remove it from the set
    [cardView retain];
    [_reusableCards removeObject:cardView];
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
  [_reusableCards addObject:cardView];
}

#pragma mark - Gesture Recognizer
- (void)didSelectCard:(UITapGestureRecognizer *)gestureRecognizer {
  NSLog(@"card tapped: %@", gestureRecognizer.view);
}

@end
