//
//  PSCachedImageView.m
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCachedImageView.h"

@implementation PSCachedImageView

@synthesize urlPath = _urlPath;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidLoad:) name:kPSImageCacheDidCacheImage object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSImageCacheDidCacheImage object:nil];

  RELEASE_SAFELY(_urlPath);
  [super dealloc];
}

- (void)loadImageAndDownload:(BOOL)download {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath shouldDownload:download];
    if (image) { 
      self.image = image;
    } else {
      self.image = nil;
    }
  } else {
    self.image = _placeholderImage;
  }
}

- (void)unloadImage {
  self.image = _placeholderImage;
  self.urlPath = nil;
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidLoad:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *urlPath = [userInfo objectForKey:@"urlPath"];
  
  if ([urlPath isEqualToString:_urlPath]) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:urlPath shouldDownload:NO];
    if (image) {
      if (image && ![image isEqual:self.image]) {
        self.image = image;
      } else {
        self.image = _placeholderImage;
      }
    }
  }
}

@end