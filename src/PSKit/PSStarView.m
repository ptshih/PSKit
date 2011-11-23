//
//  PSStarView.m
//  MealTime
//
//  Created by Peter Shih on 10/6/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSStarView.h"

#define STAR_SIZE 20.0
#define NUM_STARS 5

static UIImage *_silverStar = nil;
static UIImage *_goldStar = nil;
static UIImage *_halfStar = nil;

@implementation PSStarView

@synthesize rating = _rating;

+ (void)initialize {
  _silverStar = [[UIImage imageNamed:@"icon_star_silver.png"] retain];
  _goldStar = [[UIImage imageNamed:@"icon_star_gold.png"] retain];
  _halfStar = [[UIImage imageNamed:@"icon_star_half.png"] retain];
}

- (id)initWithFrame:(CGRect)frame rating:(CGFloat)rating {
  self = [super initWithFrame:frame];
  if (self) {
    // Frame is ignored
    self.frame = CGRectMake(0, 0, STAR_SIZE * NUM_STARS, STAR_SIZE);
    _rating = rating;
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)setRating:(CGFloat)rating {
  _rating = rating;
  
  [self removeSubviews];
  
  // Add the stars
  for (int i = 0; i < NUM_STARS; i++) {
    UIImageView *star = nil;
    if (rating > i) {
      if (rating < i + 1) {
        // half star
        star = [[[UIImageView alloc] initWithImage:_halfStar] autorelease];
      } else {
        // full star
        star = [[[UIImageView alloc] initWithImage:_goldStar] autorelease];
      }
    } else {
      star = [[[UIImageView alloc] initWithImage:_silverStar] autorelease];
    }
    star.top = 0;
    star.left = i * STAR_SIZE;
    [self addSubview:star];
  }
  
  [self setNeedsLayout];
}

#pragma mark - Layout
- (void)layoutSubviews {
  [super layoutSubviews];
}

@end
