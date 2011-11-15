//
//  PSURLCacheImageView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSURLCacheImageView.h"

@implementation PSURLCacheImageView

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
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath shouldDownload:download withDelegate:nil];
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
  UIImage *image = [userInfo objectForKey:@"image"];
  
  if ([urlPath isEqualToString:_urlPath]) {
    if (image) {
      if (image && ![image isEqual:self.image]) {
        self.image = image;
      } else {
        self.image = _placeholderImage;
      }
    }
  }
}

#pragma mark - PSImageCacheDelegate
//- (void)imageCacheDidLoad:(UIImage *)image forURLPath:(NSString *)urlPath {
//  if (image && [urlPath isEqualToString:_urlPath]) {
//    if (image && ![image isEqual:self.image]) {
//      self.image = image;
//    } else {
//      self.image = _placeholderImage;
//    }
//  }
//}

@end