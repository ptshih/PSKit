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
loadingIndicator = _loadingIndicator,
placeholderImage = _placeholderImage,
shouldResize = _shouldResize,
shouldAnimate = _shouldAnimate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.shouldResize = NO;
        self.shouldAnimate = NO;
        
        self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.loadingIndicator.hidesWhenStopped = YES;
        self.loadingIndicator.frame = self.bounds;
        self.loadingIndicator.contentMode = UIViewContentModeCenter;
        [self.loadingIndicator startAnimating];
        [self addSubview:self.loadingIndicator];
        
        self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.contentScaleFactor = [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)dealloc {
    self.loadingIndicator = nil;
    self.placeholderImage = nil;
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.loadingIndicator.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
    [self.loadingIndicator stopAnimating];
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
    
    //    self.alpha = 0.0;
    //    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
    //        self.alpha = 1.0;
    //    } completion:^(BOOL finished){
    //    }];
}

@end
