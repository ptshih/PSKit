//
//  PSImageCache.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageCacheDelegate.h"
#import "PSObject.h"

@class ASIHTTPRequest;
@class PSNetworkQueue;

@interface PSImageCache : PSObject <NSCacheDelegate> {
  NSCache *_buffer;
  NSString *_cachePath;
  NSSearchPathDirectory _cacheDirectory;
  PSNetworkQueue *_requestQueue;
}

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, assign) NSSearchPathDirectory cacheDirectory;

+ (id)sharedCache;
- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory;

// Image Cache
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath;
- (UIImage *)imageForURLPath:(NSString *)urlPath shouldDownload:(BOOL)shouldDownload withDelegate:(id)delegate;
- (BOOL)hasImageForURLPath:(NSString *)urlPath;
- (void)cacheImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate;

// Remote Request
- (BOOL)downloadImageForURLPath:(NSString *)urlPath withDelegate:(id)delegate;
- (void)downloadImageRequestFinished:(ASIHTTPRequest *)request;
- (void)downloadImageRequestFailed:(ASIHTTPRequest *)request;

- (void)cancelDownloadForURLPath:(NSString *)urlPath;

// Helpers
+ (NSString *)documentDirectory;
+ (NSString *)cachesDirectory;

@end
