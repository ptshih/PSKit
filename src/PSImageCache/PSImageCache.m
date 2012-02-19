//
//  PSImageCache.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageCache.h"

typedef void (^PSImageCacheNetworkBlock)(void);

// This encodes a given URL into a file system safe string
static inline NSString * FSImageCacheImageKeyWithURL(NSURL *URL) {
    // NOTE: If the URL is extremely long, the path becomes too long for the file system to handle and it fails
    NSString *imageKey = [NSString stringWithFormat:@"FSImageCache#%@", [URL absoluteString]];
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)imageKey,
                                                               NULL,
                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                               kCFStringEncodingUTF8);
}

@interface PSImageCache ()

// Retrieves the corresponding directory for a cache type
- (NSString *)cacheDirectoryPathForCacheType:(PSImageCacheType)cacheType;

// Retrieves a file system path for a given URL and cache type
- (NSString *)cachePathForURL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType;

@end


@implementation PSImageCache

@synthesize
networkQueue = _networkQueue,
pendingOperations = _pendingOperations;

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
        self.networkQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.networkQueue.maxConcurrentOperationCount = 4;
        
        self.pendingOperations = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(resume) 
                                                     name:kPSImageCacheDidIdle 
                                                   object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSImageCacheDidIdle object:self];
    self.networkQueue = nil;
    self.pendingOperations = nil;
    [super dealloc];
}

#pragma mark - Queue
- (void)resume {    
    // Reverse the order of pending operations before adding them back into the queue
    NSInteger i = 0;
    NSInteger j = [self.pendingOperations count] - 1;
    while (i < j) {
        [self.pendingOperations exchangeObjectAtIndex:i withObjectAtIndex:j];
        i++;
        j--;
    }
    
    [self.pendingOperations enumerateObjectsUsingBlock:^(id networkBlock, NSUInteger idx, BOOL *stop) {
        [self.networkQueue addOperationWithBlock:networkBlock];
    }];
    [self.pendingOperations removeAllObjects];
    [self.networkQueue setSuspended:NO];
}

- (void)suspend {
    [self.networkQueue setSuspended:YES];
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification 
                                                             notificationWithName:kPSImageCacheDidIdle object:self] 
                                               postingStyle:NSPostWhenIdle];
}

#pragma mark - Cache
// Write to Cache
- (void)cacheImageData:(NSData *)imageData URL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType {
    if (!imageData || !URL) return;
    
    NSURL *cachedURL = [[URL copy] autorelease];
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    [imageData writeToFile:cachePath atomically:YES];
    
    // Broadcast to all observers that 'cachedURL' has been cached
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:cachedURL forKey:@"url"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kPSImageCacheDidCacheImage object:nil userInfo:userInfo];
}

// Read from Cache
- (void)loadImageDataWithURL:(NSURL *)URL 
                   cacheType:(PSImageCacheType)cacheType 
             completionBlock:(void (^)(NSData *imageData, NSURL *cachedURL))completionBlock 
                failureBlock:(void (^)(NSError *error))failureBlock {
    if (!URL) failureBlock(nil);
    
    NSURL *cachedURL = [[URL copy] autorelease];
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    NSData *imageData = [NSData dataWithContentsOfFile:cachePath];
    
    if (imageData) {
        completionBlock(imageData, cachedURL);
    } else {
        PSImageCacheNetworkBlock networkBlock = ^(void){
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
            [NSURLConnection sendAsynchronousRequest:request 
                                               queue:[NSOperationQueue mainQueue] 
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if (data && !error) {
                                           [self cacheImageData:data URL:URL cacheType:cacheType];
                                           completionBlock(data, cachedURL);
                                       } else {
                                           failureBlock(error);
                                       }
                                   }];
        };
             
        // Queue up a network request
        if (self.networkQueue.isSuspended) {
            [self.pendingOperations addObject:Block_copy(networkBlock)];
            Block_release(networkBlock);
        } else {
            [self.networkQueue addOperationWithBlock:networkBlock];
        }
    }
}

#pragma mark - Cache Path
- (NSString *)cacheDirectoryPathForCacheType:(PSImageCacheType)cacheType {
    NSString *cacheBaseDirectory = (cacheType == PSImageCacheTypeSession) ? NSTemporaryDirectory() : (NSString *)[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    
    NSString *cacheDirectoryPath = [cacheBaseDirectory stringByAppendingPathComponent:NSStringFromClass([self class])];
    
    // Creates directory if necessary
    BOOL isDir = NO;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectoryPath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectoryPath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:&error];
    }
    
    return cacheDirectoryPath;
}

- (NSString *)cachePathForURL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType {
    NSString *cacheDirectoryPath = [self cacheDirectoryPathForCacheType:cacheType];
    
    NSString *imageKey = FSImageCacheImageKeyWithURL(URL);
    NSString *cachePath = [cacheDirectoryPath stringByAppendingPathComponent:imageKey];
    
    return cachePath;
}

#pragma mark - Purge Cache
- (void)purgeCacheWithCacheType:(PSImageCacheType)cacheType {
    NSString *cacheDirectoryPath = [self cacheDirectoryPathForCacheType:cacheType];
    
    // Removes and recreates directory
    BOOL isDir = NO;
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDirectoryPath isDirectory:&isDir] && isDir == YES) {
        [[NSFileManager defaultManager] removeItemAtPath:cacheDirectoryPath error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectoryPath 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:&error];
    }
}

@end
