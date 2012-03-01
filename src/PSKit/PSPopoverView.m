//
//  PSPopoverView.m
//  Phototime
//
//  Created by Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSPopoverView.h"

#define MARGIN 8.0

@implementation PSPopoverView

@synthesize
overlayView = _overlayView,
contentView = _contentView,
delegate = _delegate;

- (id)initWithTitle:(NSString *)title contentView:(UIView *)contentView {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.overlayView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.overlayView.backgroundColor = [UIColor blackColor];
        self.overlayView.alpha = 0.5;
        self.overlayView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
        gr.delegate = self;
        [self.overlayView addGestureRecognizer:gr];
        [self addSubview:self.overlayView];
        
        UIImageView *backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/PopoverPortrait"] stretchableImageWithLeftCapWidth:0 topCapHeight:170]] autorelease];
        [self addSubview:backgroundView];
//        backgroundView.layer.masksToBounds = NO;
//        backgroundView.layer.shadowColor = [[UIColor blackColor] CGColor];
//        backgroundView.layer.shadowOffset = CGSizeMake(0, 0);
//        backgroundView.layer.shadowRadius = 8.0;
//        backgroundView.layer.shadowOpacity = 1.0;
//        backgroundView.layer.shouldRasterize = YES;
//        backgroundView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        backgroundView.userInteractionEnabled = YES;
        
        UIImageView *arrowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PSKit.bundle/PopoverPortraitArrowUp"]] autorelease];
        [self addSubview:arrowView];
        
        backgroundView.frame = CGRectMake(MARGIN, 20 + 44 + MARGIN, self.width - MARGIN * 2, contentView.height + 24.0 + MARGIN * 3);
        
        arrowView.center = self.center;
        arrowView.top = backgroundView.top - arrowView.height + 2.0;
        
        UILabel *titleLabel = [UILabel labelWithText:title style:@"popoverTitleLabel"];
        titleLabel.frame = CGRectMake(MARGIN, MARGIN, backgroundView.width - MARGIN * 2, 24);
        [backgroundView addSubview:titleLabel];
        
        self.contentView = contentView;
        self.contentView.left = MARGIN;
        self.contentView.top = titleLabel.bottom + MARGIN;
        self.contentView.layer.cornerRadius = 4.0;
        self.contentView.layer.masksToBounds = YES;
        [backgroundView addSubview:self.contentView];
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
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished){
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)dismiss {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
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
  if ([touch.view isEqual:self.overlayView]) {
    return YES;
  } else {
    return NO;
  }
}

@end
