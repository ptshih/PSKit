//
//  PSLabel.m
//  Satsuma
//
//  Created by Peter Shih on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSLabel.h"
#import "PSStyleSheet.h"

@implementation PSLabel

@synthesize
style = _style;

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

