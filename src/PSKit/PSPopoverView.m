//
//  PSPopoverView.m
//  Phototime
//
//  Created by Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSPopoverView.h"

@implementation PSPopoverView

@synthesize
delegate = _delegate;

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        UIImageView *backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/PopoverPortrait"] stretchableImageWithLeftCapWidth:0 topCapHeight:170]] autorelease];
        [self addSubview:backgroundView];
        backgroundView.layer.masksToBounds = NO;
        backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
        backgroundView.layer.shadowOffset = CGSizeMake(0, 0);
        backgroundView.layer.shadowRadius = 8.0;
        backgroundView.layer.shadowOpacity = 1.0;
        backgroundView.userInteractionEnabled = YES;
        
        UIImageView *arrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PSKit.bundle/PopoverPortraitArrowUp"]] autorelease];
        [self addSubview:arrowView];
        
        backgroundView.frame = CGRectMake(8, 20 + 44 + 8, 304, 400);
        
        arrowView.center = self.center;
        arrowView.top = backgroundView.top - arrowView.height + 3.0;
        
        UILabel *titleLabel = [UILabel labelWithText:title style:@"popoverTitleLabel"];
        titleLabel.frame = CGRectMake(8, 8, backgroundView.width - 16, 24);
        [backgroundView addSubview:titleLabel];
        
        contentView.frame = CGRectMake(8, 8 + 8 + 24, backgroundView.width - 16, backgroundView.height - 16 - 8 - 24);
        contentView.layer.cornerRadius = 4.0;
        contentView.layer.masksToBounds = YES;
        [backgroundView addSubview:contentView];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
        gr.delegate = self;
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)show {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    self.frame = [[UIScreen mainScreen] bounds];
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
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(popoverViewDidDismiss:)]) {
            [self.delegate popoverViewDidDismiss:self];
        }
        
        [self removeFromSuperview];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  if ([touch.view isKindOfClass:[self class]]) {
    return YES;
  } else {
    return NO;
  }
}

@end
