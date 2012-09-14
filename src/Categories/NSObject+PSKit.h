//
//  NSObject+PSKit.h
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (PSKit)

- (BOOL)notNull;

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
