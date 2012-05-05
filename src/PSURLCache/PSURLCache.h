//
//  PSURLCache.h
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPSURLCacheDidIdle @"kPSURLCacheDidIdle"
#define kPSURLCacheDidCache @"PSURLCacheDidCache"

typedef enum {
    PSURLCacheTypeSession = 1,
    PSURLCacheTypePermanent = 2
} PSURLCacheType;

typedef enum {
    PSURLCachePriorityLow = 1,
    PSURLCachePriorityHigh = 2
} PSURLCachePriority;

@interface PSURLCache : NSObject

// Singleton access
+ (id)sharedCache;

// Queue
- (void)resume;
- (void)suspend;

// Write to Cache
- (void)cacheData:(NSData *)data URL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType;

// Read from Cache (block style)
// Blocks are called on the main thread
- (void)loadURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error))completionBlock;

- (void)loadRequest:(NSMutableURLRequest *)request cacheType:(PSURLCacheType)cacheType cachePriority:(PSURLCachePriority)cachePriority usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error))completionBlock;

// Read from cache only
- (NSData *)dataForCachedURL:(NSURL *)cachedURL cacheType:(PSURLCacheType)cacheType;

/**
 completionBlock is always called on the mainQueue
 */
- (void)loadRequest:(NSMutableURLRequest *)request cacheType:(PSURLCacheType)cacheType usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error))completionBlock;

// Purge Cache
- (void)removeCacheForURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType;
- (void)purgeCacheWithCacheType:(PSURLCacheType)cacheType;


@end
