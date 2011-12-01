//
//  PSImageArrayView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/17/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageArrayView.h"
#import "PSImageCache.h"

@implementation PSImageArrayView

@synthesize urlPathArray = _urlPathArray;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _animateIndex = 0;
    _shouldScale = NO;
    _images = [[NSMutableArray alloc] init];

    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)dealloc {
  _animateIndex = 0;
  self.image = nil;
  [self.layer removeAllAnimations];
  RELEASE_SAFELY(_urlPathArray);
  RELEASE_SAFELY(_images);
  INVALIDATE_TIMER(_animateTimer);
  
  [super dealloc];
}

#pragma mark Array of Images
- (void)loadImageArray {
  // Download all images
  for (NSString *urlPath in _urlPathArray) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:urlPath shouldDownload:YES];
    if (image && ![_images containsObject:image]) {
      [_images addObject:image];
      [self prepareImageArray];
    }
  }
}

- (void)unloadImageArray {
  _animateIndex = 0;
  [_images removeAllObjects];
  INVALIDATE_TIMER(_animateTimer);
  self.image = nil;
}

- (void)prepareImageArray {
  if ([_images count] == 1) {
    [self setImage:[_images objectAtIndex:0]];
  } else if ([_images count] > 1 && !_animateTimer) {
    _animateTimer = [[[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0] interval:9.0 target:self selector:@selector(animateImages) userInfo:nil repeats:YES] autorelease];
    [[NSRunLoop currentRunLoop] addTimer:_animateTimer forMode:NSDefaultRunLoopMode];
  }
}

- (void)animateImages {
  if (![_animateTimer isValid]) return;  
  CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
  crossFade.duration = 3.0;
  crossFade.fromValue = (id)[[_images objectAtIndex:_animateIndex] CGImage];
  
  _animateIndex++;
  if (_animateIndex == [_images count]) {
    _animateIndex = 0;
  }
  
  crossFade.toValue = (id)[[_images objectAtIndex:(_animateIndex)] CGImage];
  [self.layer addAnimation:crossFade forKey:@"animateContents"];
  
  [self setImage:[_images objectAtIndex:_animateIndex]];
}

- (void)resumeAnimations {
  [self resumeLayer:self.layer];
}

- (void)pauseAnimations {
  [self pauseLayer:self.layer];
}

- (void)pauseLayer:(CALayer*)layer {
  if (layer.speed == 0.0) return;
  
  CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
  layer.speed = 0.0;
  layer.timeOffset = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer {
  if (layer.speed == 1.0) return;
  
  CFTimeInterval pausedTime = [layer timeOffset];
  layer.speed = 1.0;
  layer.timeOffset = 0.0;
  layer.beginTime = 0.0;
  CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
  layer.beginTime = timeSincePause;
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidLoad:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *urlPath = [userInfo objectForKey:@"urlPath"];
  UIImage *image = [userInfo objectForKey:@"image"];
  
  if (image && [_urlPathArray containsObject:urlPath] && ![_images containsObject:image]) {
    [_images addObject:image];
    [self prepareImageArray];
  }
}

#pragma mark - PSImageCacheDelegate
//- (void)imageCacheDidLoad:(UIImage *)image forURLPath:(NSString *)urlPath {
//  if (image && [_urlPathArray containsObject:urlPath]) {
//    [_images addObject:image];
//    [self prepareImageArray];
//  }
//}


@end
