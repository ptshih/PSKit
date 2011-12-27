//
//  PSZoomView.m
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSZoomView.h"

@implementation PSZoomView

- (id)initWithImage:(UIImage *)image frame:(CGRect)frame {
  self = [super initWithFrame:APP_BOUNDS];
  if (self) {
    _originalRect = frame;
    _shouldRotate = [image isLandscape];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;
    [self addSubview:_backgroundView];
    
    _zoomedView = [[UIImageView alloc] initWithImage:image];
    _zoomedView.frame = frame;
    _zoomedView.contentMode = UIViewContentModeScaleAspectFit;
    _zoomedView.userInteractionEnabled = YES;
    [self addSubview:_zoomedView];
    
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
    [_zoomedView addGestureRecognizer:gr];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_backgroundView);
  RELEASE_SAFELY(_zoomedView);
  [super dealloc];
}

- (void)show {
  [[APP_DELEGATE window] addSubview:self];
  _zoomedView.userInteractionEnabled = NO;
  [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    _backgroundView.alpha = 1.0;
  } completion:^(BOOL finished) {
    // Rotate/Zoom image if necessary
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    if (_shouldRotate) _zoomedView.transform = CGAffineTransformMakeRotation(0.5 * M_PI);
      _zoomedView.frame = self.bounds;
    } completion:^(BOOL finished){
      _zoomedView.userInteractionEnabled = YES;
    }];
  }];
}

- (void)dismiss {
  _zoomedView.userInteractionEnabled = NO;
  [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    if (_shouldRotate) _zoomedView.transform = CGAffineTransformIdentity;
    _zoomedView.frame = _originalRect;
  } completion:^(BOOL finished){
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
      _backgroundView.alpha = 0.0;
    } completion:^(BOOL finished){
      [self removeFromSuperview];
    }];
  }];
}

@end
