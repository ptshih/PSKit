//
//  NSArray+PSKit.h
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSArray (PSKit)

+ (id)withObjectOrNil:(id)objectOrNil;
- (id)objectAtIndexOrNil:(NSUInteger)index;
- (id)lastObjectOrNil;

- (id)firstObject;
- (id)randomObject;

- (NSString *)stringWithLengthAndCount:(NSInteger)length;

@end
