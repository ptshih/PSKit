//
//  PSCachedImageView.m
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCachedImageView.h"

@interface PSCachedImageView (Private)

- (void)setImageWithCachedImageData:(NSData *)imageData;

@end

@implementation PSCachedImageView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidCache:) name:kPSImageCacheDidCacheImage object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSImageCacheDidCacheImage object:nil];
  
  RELEASE_SAFELY(_url);
  [super dealloc];
}

- (void)loadImageWithURL:(NSURL *)url {
  if (!url) return;
  
  RELEASE_SAFELY(_url);
  _url = [url copy];
  
  NSData *imageData = [[PSImageCache sharedCache] cachedImageDataForURL:url showThumbnail:YES];
  [self setImageWithCachedImageData:imageData];
}

- (void)unloadImage {
  [[PSImageCache sharedCache] cancelDownloadForURL:_url];
  self.image = _placeholderImage;
  RELEASE_SAFELY(_url);
}

- (UIImage *)originalImage {
  return [[PSImageCache sharedCache] cachedImageForURL:_url showThumbnail:NO];
}

- (void)setImageWithCachedImageData:(NSData *)imageData {
  if (!imageData) return;
  [imageData retain];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    UIImage *cachedImage = [[UIImage alloc] initWithData:imageData];
    [imageData release];
    dispatch_async(dispatch_get_main_queue(), ^{
      if (cachedImage) {
        self.image = cachedImage;
        [cachedImage release];
      } else {
        self.image = _placeholderImage;
      }
    });
  });
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidCache:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSURL *url = [userInfo objectForKey:@"url"];
  
  if ([_url isEqual:url]) {
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"assets-library"]) {
      UIImage *image = [[PSImageCache sharedCache] cachedImageForURL:url showThumbnail:YES];
      self.image = image;
    } else {
      NSData *imageData = [[PSImageCache sharedCache] cachedImageDataForURL:url showThumbnail:YES];
      [self setImageWithCachedImageData:imageData];
    }
  }
}

@end