//
//  PSView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/26/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSView.h"

@implementation PSView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    VLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)dealloc {
  VLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

@end
