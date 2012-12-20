//
//  PSGridViewTarget.m
//  Grid
//
//  Created by Peter Shih on 12/20/12.
//
//

#import "PSGridViewTarget.h"

#define TARGET_BG_COLOR RGBACOLOR(0.0, 255.0, 0, 0.5)

@implementation PSGridViewTarget

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.backgroundColor = TARGET_BG_COLOR;
    }
    return self;
}


@end
