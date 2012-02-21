//
//  PSURLCache.h
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kPSURLCacheDidIdle @"kPSURLCacheDidIdle"

typedef enum {
    PSURLCacheTypeSession = 1,
    PSURLCacheTypePermanent = 2
} PSURLCacheType;

@interface PSURLCache : PSObject

@property (nonatomic, retain) NSOperationQueue *networkQueue;
@property (nonatomic, retain) NSMutableArray *pendingOperations;

// Singleton access
+ (id)sharedCache;

// Queue
- (void)resume;
- (void)suspend;

// Write to Cache
- (void)cacheData:(NSData *)data URL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType;

// Read from Cache (block style)
// Blocks are called on the main thread
- (void)loadURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL))completionBlock failureBlock:(void (^)(NSError *error))failureBlock;

- (void)loadRequest:(NSMutableURLRequest *)request cacheType:(PSURLCacheType)cacheType usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL))completionBlock failureBlock:(void (^)(NSError *error))failureBlock;

// Purge Cache
- (void)purgeCacheWithCacheType:(PSURLCacheType)cacheType;


@end
