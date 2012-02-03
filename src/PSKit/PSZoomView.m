//
//  PSZoomView.m
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSZoomView.h"
#import "PSImageCache.h"

#define ZOOM_DURATION 0.2

@implementation PSZoomView

- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode {
  
  self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
  if (self) {
    // TODO: Get rid of status bar when zooming
    _shouldRotate = [image isLandscape];
    
    _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;
    [self addSubview:_backgroundView];
    
    _zoomedView = [[UIImageView alloc] initWithImage:image];
    _zoomedView.frame = self.bounds;
    _zoomedView.contentMode = contentMode;
    _zoomedView.clipsToBounds = YES;
    _zoomedView.userInteractionEnabled = YES;
    [self addSubview:_zoomedView];
    
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)] autorelease];
    [_zoomedView addGestureRecognizer:gr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidCache:) name:kPSImageCacheDidCacheImage object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSImageCacheDidCacheImage object:nil];
  
  RELEASE_SAFELY(_backgroundView);
  RELEASE_SAFELY(_zoomedView);
  [super dealloc];
}

- (void)loadFullResolutionWithURL:(NSURL *)url {
  UIImage *image = [[PSImageCache sharedCache] cachedImageForURL:url];
  if (image) {
    [_zoomedView setImage:image];
  }
}

- (void)showInRect:(CGRect)rect {
  self.frame = [[UIScreen mainScreen] bounds];
  _backgroundView.frame = self.bounds;
  
  _originalRect = rect;
  _zoomedView.frame = _originalRect;
  
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
  
  [[APP_DELEGATE window] addSubview:self];
  _zoomedView.userInteractionEnabled = NO;
  [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    _backgroundView.alpha = 1.0;
  } completion:^(BOOL finished) {
    // Rotate/Zoom image if necessary
    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    if (_shouldRotate) _zoomedView.transform = CGAffineTransformMakeRotation(0.5 * M_PI);
      _zoomedView.frame = self.bounds;
    } completion:^(BOOL finished){
      _zoomedView.userInteractionEnabled = YES;
    }];
  }];
}

- (void)dismiss {
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
  
  _zoomedView.userInteractionEnabled = NO;
  [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    if (_shouldRotate) _zoomedView.transform = CGAffineTransformIdentity;
    _zoomedView.frame = _originalRect;
  } completion:^(BOOL finished){
    [UIView animateWithDuration:ZOOM_DURATION delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
      _backgroundView.alpha = 0.0;
    } completion:^(BOOL finished){
      [self removeFromSuperview];
    }];
  }];
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidCache:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSURL *url = [userInfo objectForKey:@"url"];
  
  UIImage *image = [[PSImageCache sharedCache] cachedImageForURL:url];
  if (image) {
    [_zoomedView setImage:image];
  }
}

@end
