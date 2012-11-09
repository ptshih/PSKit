//
//  PSNullView.m
//  PSKit
//
//  Created by Peter Shih on 4/9/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSErrorView.h"

@implementation PSErrorView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
        
        self.messageLabel = [UILabel labelWithStyle:@"errorViewMessageLabel"];
        self.messageLabel.autoresizingMask = ~UIViewAutoresizingNone;
        self.messageLabel.frame = self.bounds;
        [self addSubview:self.messageLabel];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        gr.numberOfTapsRequired = 1;
        [self addGestureRecognizer:gr];
    }
    return self;
}


- (void)showWithMessage:(NSString *)message inRect:(CGRect)rect {
    self.messageLabel.text = message;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    self.frame = rect;
    [[APP_DELEGATE window] addSubview:self];
    self.alpha = 0.0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)dismiss {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorViewDidDismiss:)]) {
            [self.delegate errorViewDidDismiss:self];
        }
        
        [self removeFromSuperview];
    }];
}

@end
