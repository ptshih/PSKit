//
//  PSImageCache.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageCache.h"

@implementation PSImageCache

@synthesize cachePath = _cachePath;

static inline NSString *PSImageCacheKeyWithURL(NSURL *url) {
  return [[NSString stringWithFormat:@"PSImageCache#%@", [url absoluteString]] stringWithPercentEscape];
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
  __block NSString *blockCacheKey = [cacheKey copy];
  __block NSData *blockImageData = [imageData copy];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
    // In memory cache
    [_buffer setObject:blockImageData forKey:blockCacheKey cost:1];
    
    // Disk cache
    [blockImageData writeToFile:[_cachePath stringByAppendingPathComponent:blockCacheKey] atomically:YES];
    [blockImageData release];
    [blockCacheKey release];
    
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
  NSString *cacheKey = PSImageCacheKeyWithURL(url);
  NSData *imageData = [_buffer objectForKey:cacheKey];
  
  if (!imageData) {
    imageData = [NSData dataWithContentsOfFile:[_cachePath stringByAppendingPathComponent:cacheKey]];
    if (!imageData) {
      [self downloadImageForURL:url];
    } else {
      __block NSData *blockImageData = [imageData copy];
      __block NSString *blockCacheKey = [cacheKey copy];
      
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [_buffer setObject:blockImageData forKey:blockCacheKey cost:1];
        [blockImageData release];
        [blockCacheKey release];
      });
    }
  }
  
  return imageData;
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
