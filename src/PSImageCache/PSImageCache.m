//
//  PSImageCache.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@implementation PSImageCache

@synthesize cachePath = _cachePath;

static inline NSString *PSImageCacheKeyWithURL(NSURL *url) {
  return [[NSString stringWithFormat:@"PSImageCache#%@", [url absoluteString]] stringWithPercentEscape];
}

static inline NSString *PSImageCacheThumbKeyWithURL(NSURL *url) {
  return [[NSString stringWithFormat:@"PSImageCacheThumb#%@", [url absoluteString]] stringWithPercentEscape];
}

+ (id)sharedCache {
  static id sharedCache;
  if (!sharedCache) {
    sharedCache = [[self alloc] init];
  }
  return sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    _buffer = [[NSCache alloc] init];
    [_buffer setName:@"PSImageCache"];
    [_buffer setDelegate:self];
//    [_buffer setTotalCostLimit:100];
    
    _opQueue = [[NSOperationQueue alloc] init];
    _opQueue.maxConcurrentOperationCount = 8;
    
    // Set to NSDocumentDirectory by default
    [self setupCachePathWithCacheDirectory:NSCachesDirectory];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_buffer);
  RELEASE_SAFELY(_cachePath);
  RELEASE_SAFELY(_opQueue);
  [super dealloc];
}

#pragma mark - Cache Setup and Directory
- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  self.cachePath = [[NSSearchPathForDirectoriesInDomains(cacheDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"PSImageCache"];
  
  BOOL isDir = NO;
  NSError *error;
  if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDir] && isDir == NO) {
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:&error];
  }
}

- (void)setCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  _cacheDirectory = cacheDirectory;
  
  // Change the cachePath to use the new directory
  [self setupCachePathWithCacheDirectory:cacheDirectory];
}

- (NSSearchPathDirectory)cacheDirectory {
  return _cacheDirectory;
}

#pragma mark - Set Cache
- (void)cacheImage:(UIImage *)image forURL:(NSURL *)url {
  if (!image || !url) return;
  
  // Convert UIImage -> NSData
  NSData *imageData = UIImagePNGRepresentation(image);
  
  [self cacheImageData:imageData forURL:url];
}

- (void)cacheImageData:(NSData *)imageData forURL:(NSURL *)url {
  if (!imageData || !url) return;
  
  
  NSString *cacheKey = PSImageCacheKeyWithURL(url);
  NSString *thumbKey = PSImageCacheThumbKeyWithURL(url);
  
  [imageData retain];
  [cacheKey retain];
  [thumbKey retain];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSData *thumbData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.5);
    
    if (!thumbData) return ;
    
    // In memory cache
    [_buffer setObject:imageData forKey:cacheKey cost:1];
    [_buffer setObject:thumbData forKey:thumbKey cost:0];
    
    // Disk cache
    [imageData writeToFile:[_cachePath stringByAppendingPathComponent:cacheKey] atomically:YES];
    [thumbData writeToFile:[_cachePath stringByAppendingPathComponent:thumbKey] atomically:YES];
    
    [imageData release];
    [cacheKey release];
    [thumbKey release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      VLog(@"Cached image with URL: %@", url);
      
      // Fire notification to inform image is cached and ready
      [[NSNotificationCenter defaultCenter] postNotificationName:kPSImageCacheDidCacheImage object:nil userInfo:[NSDictionary dictionaryWithObject:url forKey:@"url"]];
    });
  });
}

#pragma mark - Read Cache
- (UIImage *)cachedImageForURL:(NSURL *)url {
  if (!url) return nil;
  
  NSData *cachedImageData = [self cachedImageDataForURL:url];
  
  UIImage *cachedImage = nil;
  if (cachedImageData) {
    cachedImage = [UIImage imageWithData:cachedImageData];
  }
  
  return cachedImage;
}

- (NSData *)cachedImageDataForURL:(NSURL *)url {
  return [self cachedImageDataForURL:url showThumbnail:YES];
}

- (NSData *)cachedImageDataForURL:(NSURL *)url showThumbnail:(BOOL)showThumbnail {
  NSString *cacheKey = PSImageCacheKeyWithURL(url);
  NSString *thumbKey = PSImageCacheThumbKeyWithURL(url);
  NSData *imageData = [_buffer objectForKey:cacheKey];
  NSData *thumbData = [_buffer objectForKey:thumbKey];
  
  if (!imageData || !thumbData) {
    imageData = [NSData dataWithContentsOfFile:[_cachePath stringByAppendingPathComponent:cacheKey]];
    thumbData = [NSData dataWithContentsOfFile:[_cachePath stringByAppendingPathComponent:thumbKey]];
    if (!imageData || !thumbData) {
      // No imageData found in either memory or disk
      // Check URL Scheme
      NSString *scheme = [url scheme];
      if ([scheme isEqualToString:@"assets-library"]) {
        [self loadImageForAssetURL:url];
      } else {
        [self downloadImageForURL:url];
      }
    } else {
      [imageData retain];
      [thumbData retain];
      [cacheKey retain];
      [thumbKey retain];
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_buffer setObject:imageData forKey:cacheKey cost:1];
        [_buffer setObject:thumbData forKey:thumbKey cost:0];
        [imageData release];
        [cacheKey release];
        [thumbKey release];
      });
    }
  }
  
  return showThumbnail ? thumbData : imageData;
}

- (void)loadImageForAssetURL:(NSURL *)url {
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  
  [library assetForURL:url resultBlock:^(ALAsset *asset){
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    // Read out asset DATA
    long long assetSize = rep.size;
    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*assetSize);
    NSError *error = nil;
    [rep getBytes:buffer fromOffset:0 length:assetSize error:&error];
    if (error) {
      NSLog(@"Default Representation getBytes with error: %@", error);
    }
    NSData *assetData = [NSData dataWithBytesNoCopy:buffer length:assetSize freeWhenDone:YES];
    
    [self cacheImageData:assetData forURL:url];
    
  } failureBlock:^(NSError *error){
    
  }];
  
  [library release];
}

- (void)downloadImageForURL:(NSURL *)url {
  // Check to make sure url is not already pending
  for (AFHTTPRequestOperation *op in [_opQueue operations]) {
    if ([op.request.URL isEqual:url]) {
      return;
    }
  }
  
  // Download the image from url
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSInteger statusCode = [operation.response statusCode];
    if (statusCode == 200) {
      [self cacheImageData:operation.responseData forURL:operation.request.URL];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    // Something bad happened
  }];
  
  // Start the Request
  [_opQueue addOperation:op];
  [op release];
}

- (void)cancelDownloadForURL:(NSURL *)url {
  for (AFHTTPRequestOperation *op in [_opQueue operations]) {
    if ([op.request.URL isEqual:url]) {
      [op cancel];
    }
  }
}

#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
  VLog(@"NSCache evicting object");
}
   
#pragma mark Helpers
+ (NSString *)documentDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cachesDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end
