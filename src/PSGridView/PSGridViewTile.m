//
//  PSGridViewTile.m
//  Grid
//
//  Created by Peter Shih on 12/19/12.
//
//

#import "PSGridViewTile.h"

@implementation PSGridViewTile

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = YES;
    }
    return self;
}

@end
