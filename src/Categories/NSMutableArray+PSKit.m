//
//  NSMutableArray+PSKit.m
//  PSKit
//
//  Created by Peter on 2/17/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "NSMutableArray+PSKit.h"

@implementation NSMutableArray (PSKit)

- (void)reverse {
    NSInteger i = 0;
    NSInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:j];
        
        i++;
        j--;
    }
}

@end
