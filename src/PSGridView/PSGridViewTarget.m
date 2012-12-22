//
//  PSGridViewTarget.m
//  Grid
//
//  Created by Peter Shih on 12/20/12.
//
//

#import "PSGridViewTarget.h"

#define TARGET_BG_COLOR RGBACOLOR(0.0, 255.0, 0, 0.5)

@interface PSGridViewTarget ()

// Touch
@property (nonatomic, assign) CGPoint originalTouchPoint;
@property (nonatomic, assign) BOOL touchDidMove;

@end

@implementation PSGridViewTarget

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        self.backgroundColor = TARGET_BG_COLOR;
        
        self.touchDidMove = NO;
    }
    return self;
}

#pragma mark - Cell Actions

- (void)editTarget {
    [UIActionSheet actionSheetWithTitle:@"Add/Edit Content" message:nil destructiveButtonTitle:nil buttons:@[@"Link", @"Remove"] showInView:self onDismiss:^(int buttonIndex, NSString *textInput) {
        switch (buttonIndex) {
            case 0: {
                [UIAlertView alertViewWithTitle:@"Enter Link" style:UIAlertViewStylePlainTextInput message:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Ok"] onDismiss:^(int buttonIndex, NSString *textInput){
                    NSLog(@"%@", textInput);
                    
                    if (textInput.length > 0) {
                        NSDictionary *action = @{@"type" : @"link", @"href": textInput};
                        self.action = action;
                    }
                } onCancel:^{
                }];
                break;
            }
            case 1: {
                [self removeTarget];
                break;
            }
            default:
                break;
        }
    } onCancel:^{
        
    }];
}

- (void)removeTarget {
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.targets removeObject:self];
    }];
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.originalTouchPoint = [touch locationInView:self.parentView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.parentView];
    
    if ((fabsf(self.originalTouchPoint.x - touchPoint.x) > 32.0) || (fabsf(self.originalTouchPoint.y - touchPoint.y) > 32.0)) {
        self.touchDidMove = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
//    CGPoint touchPoint = [touch locationInView:self.parentView];
    
    // If touch moved too far, cancel it
    if (!self.touchDidMove) {
        if (touch.tapCount == 1) {
            [self editTarget];
        } else {
            NSLog(@"long press");
        }
    }
    
    self.touchDidMove = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    self.touchDidMove = NO;
}



@end
