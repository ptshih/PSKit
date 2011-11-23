//
//  PSImageCache.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageCacheDelegate.h"
#import "AFNetworking.h"

@interface PSImageCache : PSObject <NSCacheDelegate> {
  NSCache *_buffer;
  NSString *_cachePath;
  NSSearchPathDirectory _cacheDirectory;
  NSOperationQueue *_requestQueue;
}

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, assign) NSSearchPathDirectory cacheDirectory;

+ (id)sharedCache;
- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory;

// Image Cache
- (void)cacheImage:(UIImage *)image forURLPath:(NSString *)urlPath;
- (void)cacheImageData:(NSData *)imageData forURLPath:(NSString *)urlPath;
- (UIImage *)imageForURLPath:(NSString *)urlPath shouldDownload:(BOOL)shouldDownload withDelegate:(id)delegate;
- (BOOL)hasImageForURLPath:(NSString *)urlPath;
- (void)cacheImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate;

// Remote Request
- (BOOL)downloadImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate;

- (void)cancelDownloadForURLPath:(NSString *)urlPath;

// Helpers
+ (NSString *)documentDirectory;
+ (NSString *)cachesDirectory;

@end
