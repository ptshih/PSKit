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
  
  RELEASE_SAFELY(_originalImage);
  RELEASE_SAFELY(_thumbnailImage);
  RELEASE_SAFELY(_url);
  [super dealloc];
}

- (UIImage *)originalImage {
  return _originalImage;
}

- (void)loadImageWithURL:(NSURL *)url {
  [self loadImageWithURL:url shouldDownload:YES thumbnailWithSize:CGSizeZero];
}

- (void)loadImageWithURL:(NSURL *)url shouldDownload:(BOOL)shouldDownload {
  [self loadImageWithURL:url shouldDownload:shouldDownload thumbnailWithSize:CGSizeZero];
}

- (void)loadImageWithURL:(NSURL *)url shouldDownload:(BOOL)shouldDownload thumbnailWithSize:(CGSize)thumbnailSize {
  if (!url) return;
  
  RELEASE_SAFELY(_url);
  _url = [url copy];
  
  _thumbnailSize = thumbnailSize;
  
  NSData *imageData = [[PSImageCache sharedCache] cachedImageDataForURL:url];
  [self setImageWithCachedImageData:imageData];
}

- (void)unloadImage {
  [[PSImageCache sharedCache] cancelDownloadForURL:_url];
  self.image = _placeholderImage;
  RELEASE_SAFELY(_originalImage);
  RELEASE_SAFELY(_thumbnailImage);
  RELEASE_SAFELY(_url);
}

- (void)setImageWithCachedImageData:(NSData *)imageData {
  if (!imageData) return;
  __block BOOL showThumbnail = !CGSizeEqualToSize(_thumbnailSize, CGSizeZero);
  __block NSData *blockImageData = [imageData copy];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    _originalImage = [[UIImage alloc] initWithData:blockImageData];
    [blockImageData release];

    if (showThumbnail) {
      _thumbnailImage = [[_originalImage scaledImageWithinSize:_thumbnailSize] retain];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (_originalImage) {
        if (showThumbnail) {
          self.image = _thumbnailImage;
        } else {
          self.image = _originalImage;
        }
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
    NSData *imageData = [[PSImageCache sharedCache] cachedImageDataForURL:url];
    [self setImageWithCachedImageData:imageData];
  }
}

@end