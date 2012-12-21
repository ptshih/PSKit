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

#pragma mark - Cell Actions

- (void)editTarget {
    
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    if (touch.tapCount == 1) {
        [self editTarget];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}



@end
