//
//  PSImageView.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageView.h"

@implementation PSImageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.placeholderImage = nil;
        
        self.shouldResize = NO;
        self.shouldAnimate = NO;
        
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        self.loadingColor = RGBACOLOR(220, 220, 220, 1.0);
        self.backgroundColor = self.loadingColor;
        self.bgColor = [UIColor clearColor];
    }
    return self;
}


- (void)prepareForReuse {
    self.image = self.placeholderImage;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    ASSERT_MAIN_THREAD;
    _loadingColor = loadingColor;
    self.backgroundColor = loadingColor;
}

- (void)setImage:(UIImage *)image {
    ASSERT_MAIN_THREAD;
    if (image && ![image isEqual:self.placeholderImage]) {
        self.backgroundColor = self.bgColor;
        // Only animate on Retina screens
        if (self.shouldAnimate) {
            self.alpha = 0.0;
            [super setImage:image];
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.alpha = 1.0; 
            } completion:NULL];
        } else {
            [super setImage:image];
        }
    } else {
        self.backgroundColor = self.loadingColor;
        [super setImage:self.placeholderImage];
    }
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage {
    _placeholderImage = placeholderImage;
    [super setImage:placeholderImage];
}

@end
