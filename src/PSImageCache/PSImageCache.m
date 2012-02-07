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

static inline NSString *PSImageCacheImageKeyWithURL(NSURL *url) {
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
    _memCache = [[NSCache alloc] init];
    [_memCache setName:@"PSImageCache"];
//    [_buffer setDelegate:self];
//    [_buffer setTotalCostLimit:100];
    
    _opQueue = [[NSOperationQueue alloc] init];
    _opQueue.maxConcurrentOperationCount = 8;
    
    // Set to NSDocumentDirectory by default
    [self setupCachePathWithCacheDirectory:NSCachesDirectory];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_memCache);
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
  [self cacheImageData:imageData forURL:url showThumbnail:NO];
}

- (void)cacheImageData:(NSData *)imageData forURL:(NSURL *)imageURL showThumbnail:(BOOL)showThumbnail {
  if (!imageData || !imageURL) return;
    NSURL *url = [[imageURL copy] autorelease];
    
  NSString *imageKey = PSImageCacheImageKeyWithURL(url);
  NSString *thumbKey = PSImageCacheThumbKeyWithURL(url);
  
  [imageData retain];
  [imageKey retain];
  [thumbKey retain];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    NSData *thumbData = nil;
    
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"assets-library"] && showThumbnail) {
      thumbData = imageData;
    } else {
      // Generate a thumbnail
      thumbData = UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.25);
      
      [imageData writeToFile:[_cachePath stringByAppendingPathComponent:imageKey] atomically:YES];
    }
    
    if (!thumbData) return;
    
    // In memory cache
    [_memCache setObject:thumbData forKey:thumbKey cost:0];
    
    // Disk cache
    [thumbData writeToFile:[_cachePath stringByAppendingPathComponent:thumbKey] atomically:YES];
    
    [imageData release];
    [imageKey release];
    [thumbKey release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      VLog(@"Cached image with URL: %@", url);
      
      // Fire notification to inform image is cached and ready
      NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:url, @"url", [NSNumber numberWithBool:showThumbnail], @"showThumbnail", nil];
      [[NSNotificationCenter defaultCenter] postNotificationName:kPSImageCacheDidCacheImage object:url userInfo:userInfo];
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
  NSString *imageKey = PSImageCacheImageKeyWithURL(url);
  
  // Read image from disk
  NSData *imageData = [NSData dataWithContentsOfFile:[_cachePath stringByAppendingPathComponent:imageKey]];
  
  if (!imageData) {
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"assets-library"]) {
      [self loadImageForAssetURL:url showThumbnail:NO];
    } else {
      [self downloadImageForURL:url showThumbnail:NO];
    }
  }
  
  return imageData;
}

- (UIImage *)cachedThumbnailForURL:(NSURL *)url {
  if (!url) return nil;
  
  NSData *cachedThumbnailData = [self cachedThumbnailDataForURL:url];
  
  UIImage *cachedThumbnail = nil;
  if (cachedThumbnailData) {
    cachedThumbnail = [UIImage imageWithData:cachedThumbnailData];
  }
  
  return cachedThumbnail;
}

- (NSData *)cachedThumbnailDataForURL:(NSURL *)url {
  // read thumbnail from memory
  NSString *thumbKey = PSImageCacheThumbKeyWithURL(url);
  NSData *thumbData = [_memCache objectForKey:thumbKey];
  
  if (!thumbData) {
    thumbData = [NSData dataWithContentsOfFile:[_cachePath stringByAppendingPathComponent:thumbKey]];
    
    if (!thumbData) {
      NSString *scheme = [url scheme];
      if ([scheme isEqualToString:@"assets-library"]) {
        [self loadImageForAssetURL:url showThumbnail:YES];
      } else {
        [self downloadImageForURL:url showThumbnail:YES];
      }
    } else {
      [_memCache setObject:thumbData forKey:thumbKey];
    }
  }
  
  return thumbData;
}

- (void)loadImageForAssetURL:(NSURL *)url {
  [self loadImageForAssetURL:url showThumbnail:NO];
}

- (void)loadImageForAssetURL:(NSURL *)url showThumbnail:(BOOL)showThumbnail {
  NSLog(@"loading asset url: %@", url);

  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  
  [library assetForURL:url resultBlock:^(ALAsset *asset){
    
    // Read out asset DATA
//    long long assetSize = rep.size;
//    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*assetSize);
//    NSError *error = nil;
//    [rep getBytes:buffer fromOffset:0 length:assetSize error:&error];
//    if (error) {
//      NSLog(@"Default Representation getBytes with error: %@", error);
//    }
//    NSData *assetData = [NSData dataWithBytesNoCopy:buffer length:assetSize freeWhenDone:YES];
    
//    [self cacheImageData:assetData forURL:url];
    
    UIImage *image = nil;
    if (showThumbnail) {
      image = [UIImage imageWithCGImage:asset.thumbnail];
    } else {
      ALAssetRepresentation *rep = [asset defaultRepresentation];
      image = [UIImage imageWithCGImage:rep.fullScreenImage];
    }
    [self cacheImageData:UIImageJPEGRepresentation(image, 1.0) forURL:url showThumbnail:showThumbnail];
    
  } failureBlock:^(NSError *error){
    
  }];
  
  [library release];
}

- (void)downloadImageForURL:(NSURL *)url {
  [self downloadImageForURL:url showThumbnail:NO];
}

- (void)downloadImageForURL:(NSURL *)url showThumbnail:(BOOL)showThumbnail {
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
      [self cacheImageData:operation.responseData forURL:operation.request.URL showThumbnail:showThumbnail];
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
