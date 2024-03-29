//
//  UIImageView+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 5/19/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "UIImageView+PSKit.h"

@implementation UIImageView (PSKit)

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image {
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:image];
    }
    return self;
}

@end
