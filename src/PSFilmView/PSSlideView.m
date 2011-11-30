//
//  PSSlideView.m
//  Rolodex
//
//  Created by Peter Shih on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSSlideView.h"

@implementation PSSlideView

@synthesize slideContentView = _slideContentView;
@synthesize state = _state;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _state = PSSlideViewStateNormal;
    self.alwaysBounceVertical = YES;
    self.autoresizingMask = ~UIViewAutoresizingNone;
    
    _slideContentView = [[UIView alloc] initWithFrame:frame];
    [self addSubview:_slideContentView];
  }
  return self;
}

- (void)dealloc {
  // Views
  RELEASE_SAFELY(_slideContentView);
  [super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.contentSize = _slideContentView.bounds.size;
}

@end
