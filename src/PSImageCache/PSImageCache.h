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
  NSCache *_buffer;
  NSString *_cachePath;
  NSSearchPathDirectory _cacheDirectory;
  NSOperationQueue *_opQueue;
}

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, assign) NSSearchPathDirectory cacheDirectory;

+ (id)sharedCache;
- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory;

// Image Cache
- (void)cacheImage:(UIImage *)image forURLPath:(NSString *)urlPath;
- (void)cacheImageData:(NSData *)imageData forURLPath:(NSString *)urlPath;
- (UIImage *)imageForURLPath:(NSString *)urlPath shouldDownload:(BOOL)shouldDownload;
- (BOOL)hasImageForURLPath:(NSString *)urlPath;
- (void)cacheImageForURLPath:(NSString *)urlPath;

// Remote Request
- (BOOL)downloadImageForURLPath:(NSString *)urlPath;

- (void)cancelDownloadForURLPath:(NSString *)urlPath;

// Helpers
+ (NSString *)documentDirectory;
+ (NSString *)cachesDirectory;

@end
