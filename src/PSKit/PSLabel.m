//
//  PSLabel.m
//  PSKit
//
//  Created by Peter Shih on 6/23/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import "PSLabel.h"
#import "PSStyleSheet.h"

@implementation PSLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

+ (PSLabel *)labelWithStyle:(NSString *)style {
    PSLabel *l = [[PSLabel alloc] initWithFrame:CGRectZero];
    l.style = style;
    return l;
}

- (void)setStyle:(NSString *)style {
    _style = style;
    
    [PSStyleSheet applyStyle:style forLabel:self];
}

@end

