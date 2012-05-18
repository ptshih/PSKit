//
//  NSArray+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "NSArray+PSKit.h"


@implementation NSArray (PSKit)

+ (id)withObjectOrNil:(id)objectOrNil {
    return objectOrNil ? [self arrayWithObject:objectOrNil] : [self array];
}


- (id)objectAtIndexOrNil:(NSUInteger)index {
    return (index < self.count) ? [self objectAtIndex:index] : nil;
}


- (id)lastObjectOrNil {
    return (self.count ? self.lastObject : nil);
}

- (id)firstObject {
  if ([self count] > 0) {
    return [self objectAtIndex:0];
  } else {
    return nil;
  }
}

- (id)randomObject {
  if ([self count] > 0) {
    return [self objectAtIndex:arc4random() % [self count]];
  } else {
    return nil;
  }
}

@end
