//
//  PSImageCache.h
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define kPSImageCacheDidCacheImage @"PSImageCacheDidCacheImage"

@interface PSImageCache : PSObject <NSCacheDelegate> {
  NSCache *_memCache;
  NSString *_cachePath;
  NSSearchPathDirectory _cacheDirectory;
  NSOperationQueue *_opQueue;
}

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, assign) NSSearchPathDirectory cacheDirectory;

+ (id)sharedCache;
- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory;

/**
 This tries to retrieve the image with a given URL from the cache
 */
- (UIImage *)cachedImageForURL:(NSURL *)url;
- (NSData *)cachedImageDataForURL:(NSURL *)url;
- (UIImage *)cachedThumbnailForURL:(NSURL *)url;
- (NSData *)cachedThumbnailDataForURL:(NSURL *)url;

/**
 This caches a UIImage keyed to a URL
 */
- (void)cacheImage:(UIImage *)image forURL:(NSURL *)url;
- (void)cacheImageData:(NSData *)imageData forURL:(NSURL *)url;
- (void)cacheImageData:(NSData *)imageData forURL:(NSURL *)imageURL showThumbnail:(BOOL)showThumbnail;


// Remote Request
- (void)downloadImageForURL:(NSURL *)url;
- (void)downloadImageForURL:(NSURL *)url showThumbnail:(BOOL)showThumbnail;
- (void)cancelDownloadForURL:(NSURL *)url;

// Asset Library
- (void)loadImageForAssetURL:(NSURL *)url;
- (void)loadImageForAssetURL:(NSURL *)url showThumbnail:(BOOL)showThumbnail;

// Helpers
+ (NSString *)documentDirectory;
+ (NSString *)cachesDirectory;

@end
