//
//  PSObject.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSObject.h"


@implementation PSObject

- (id)init {
  self = [super init];
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
