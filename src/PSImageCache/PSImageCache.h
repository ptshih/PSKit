//
//  PSImageCache.h
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPSImageCacheDidCacheImage @"kPSImageCacheDidCacheImage"

typedef enum {
    PSImageCacheTypeSession = 1,
    PSImageCacheTypePermanent = 2
} PSImageCacheType;

@interface PSImageCache : PSObject

@property (nonatomic, retain) NSString *cacheBasePath;

// Singleton access
+ (id)sharedCache;

// Write to Cache
- (void)cacheImageData:(NSData *)imageData URL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType;

// Read from Cache (block style)
// Blocks are called on the main thread
- (void)loadImageDataWithURL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType completionBlock:(void (^)(NSData *imageData, NSURL *cachedURL))completionBlock failureBlock:(void (^)(NSError *error))failureBlock;

// Purge Cache
- (void)purgeSessionCache;
- (void)purgeCacheWithCacheType:(PSImageCacheType)cacheType;


@end
