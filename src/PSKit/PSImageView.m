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
        self.shouldResize = NO;
        self.shouldAnimate = NO;
        
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        
        self.backgroundColor = RGBACOLOR(200, 200, 200, 1.0);
    }
    return self;
}

- (void)dealloc {
    self.placeholderImage = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.image = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setImage:(UIImage *)image {
    if (image && ![image isEqual:self.placeholderImage]) {
        if (self.shouldAnimate) {
            [super setImage:image];
            [self animateImageFade:image];
        } else {
            [super setImage:image];
        }
    } else {
        [super setImage:image];
    }
}

- (void)animateImageFade:(UIImage *)image {  
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.removedOnCompletion = YES;
    fade.duration = 0.2;
    fade.fromValue = [NSNumber numberWithFloat:0.0];
    fade.toValue = [NSNumber numberWithFloat:1.0];
    [self.layer addAnimation:fade forKey:@"opacity"];
}

@end
