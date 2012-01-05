//
//  PSImageView.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageView.h"

@implementation PSImageView

@synthesize placeholderImage = _placeholderImage;
@synthesize shouldScale = _shouldScale;
@synthesize shouldAnimate = _shouldAnimate;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _shouldScale = NO;
    _shouldAnimate = NO;
    _placeholderImage = nil;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _loadingIndicator.hidesWhenStopped = YES;
    _loadingIndicator.frame = self.bounds;
    _loadingIndicator.contentMode = UIViewContentModeCenter;
    [_loadingIndicator startAnimating];
    [self addSubview:_loadingIndicator];
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFill;
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_loadingIndicator);
  RELEASE_SAFELY(_placeholderImage);
  [super dealloc];
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  _loadingIndicator.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
  if (image && image != _placeholderImage) {
    // RETINA
    [_loadingIndicator stopAnimating];
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
    [_loadingIndicator stopAnimating];
  } else {
    [super setImage:image];
    [_loadingIndicator startAnimating];
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
