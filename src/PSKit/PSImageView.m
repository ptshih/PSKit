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
shouldScale = _shouldScale,
shouldAnimate = _shouldAnimate;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.shouldScale = NO;
    self.shouldAnimate = NO;
    self.placeholderImage = nil;
    
    self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.loadingIndicator.hidesWhenStopped = YES;
    self.loadingIndicator.frame = self.bounds;
    self.loadingIndicator.contentMode = UIViewContentModeCenter;
    [self.loadingIndicator startAnimating];
    [self addSubview:self.loadingIndicator];
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFill;
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
  if (image && image != _placeholderImage) {
    // RETINA
    [self.loadingIndicator stopAnimating];
//    UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation];
    UIImage *newImage = [image imageScaledForScreen];
    if (_shouldAnimate) {
      [super setImage:newImage];
      [self animateImageFade:newImage];
    } else {
      [super setImage:newImage];
    }
  } else if (image == _placeholderImage && _placeholderImage) {
    [super setImage:image];
    [self.loadingIndicator stopAnimating];
  } else {
    [super setImage:image];
    [self.loadingIndicator startAnimating];
  }
//  [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, image.size.width, image.size.height)];
}

- (void)animateImageFade:(UIImage *)image {  
//  CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
//  fade.duration = 0.2;
//  fade.fromValue = [NSNumber numberWithFloat:0.0];
//  fade.toValue = [NSNumber numberWithFloat:1.0];
//  [self.layer addAnimation:fade forKey:@"opacity"];

  self.alpha = 0.0;
  [UIView beginAnimations:@"psImageViewFade" context:nil];
  [UIView setAnimationDuration:0.2];
  self.alpha = 1.0;
  [UIView commitAnimations];
}

@end
