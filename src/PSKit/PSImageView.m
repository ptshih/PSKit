//
//  PSImageView.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageView.h"

@implementation PSImageView

@synthesize
placeholderImage = _placeholderImage,
shouldResize = _shouldResize,
shouldAnimate = _shouldAnimate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholderImage = nil;
        
        self.shouldResize = NO;
        self.shouldAnimate = NO;
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        self.backgroundColor = RGBACOLOR(230, 230, 230, 1.0);
    }
    return self;
}

- (void)dealloc {
    self.placeholderImage = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.image = self.placeholderImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setImage:(UIImage *)image {
    ASSERT_MAIN_THREAD;
    if (image && ![image isEqual:self.placeholderImage]) {
        self.backgroundColor = [UIColor clearColor];
        // Only animate on Retina screens
        if (self.shouldAnimate && [UIScreen mainScreen].scale > 1.0) {
            self.alpha = 0.0;
            [super setImage:image];
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.alpha = 1.0; 
            } completion:NULL];
        } else {
            [super setImage:image];
        }
    } else {
        self.backgroundColor = RGBACOLOR(230, 230, 230, 1.0);
        [super setImage:self.placeholderImage];
    }
}

@end
