//
//  PSLayoutManager.m
//  PSKit
//
//  Created by Peter on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSLayoutManager.h"

@implementation PSLayoutManager

+ (id)defaultManager {
    static id defaultManager;
    if (!defaultManager) {
        defaultManager = [[self alloc] init];
    }
    return defaultManager;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


@end
