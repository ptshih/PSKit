//
//  PSRandomSortDescriptor.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/2/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSRandomSortDescriptor.h"


@implementation PSRandomSortDescriptor

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2 {
  NSUInteger ran=(arc4random() % 3);
  switch (ran) {
    case 0:
      return NSOrderedSame;
      break;
    case 1:
      return NSOrderedDescending;
    default:
      return NSOrderedAscending;
      break;
  }  
}


@end
