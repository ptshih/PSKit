//
//  PSURLCache.m
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSURLCache.h"

typedef void (^PSURLCacheNetworkBlock)(void);

// This encodes a given URL into a file system safe string
static inline NSString * PSURLCacheKeyWithURL(NSURL *URL) {
    // NOTE: If the URL is extremely long, the path becomes too long for the file system to handle and it fails
    return [[URL absoluteString] stringFromMD5Hash];
    //    return [(NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
    //                                                               (CFStringRef)[URL absoluteString],
    //                                                               NULL,
    //                                                               (CFStringRef)@"!*'();:@&=+$,/?%#[]",
    //                                                               kCFStringEncodingUTF8) autorelease];
}


@interface PSURLCache ()

@property (nonatomic, strong) NSOperationQueue *priorityQueue;
@property (nonatomic, strong) NSOperationQueue *networkQueue;
@property (nonatomic, strong) NSMutableSet *pendingURLs;
@property (nonatomic, strong) NSMutableArray *pendingOperations;

// Retrieves the corresponding directory for a cache type
- (NSString *)cacheDirectoryPathForCacheType:(PSURLCacheType)cacheType;

// Retrieves a file system path for a given URL and cache type
- (NSString *)cachePathForURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType;

@end


@implementation PSURLCache

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
        self.noCache = NO;
        
        self.priorityQueue = [[NSOperationQueue alloc] init];
        self.priorityQueue.maxConcurrentOperationCount = 1;
        
        self.networkQueue = [[NSOperationQueue alloc] init];
        self.networkQueue.maxConcurrentOperationCount = 4;
        
        self.pendingURLs = [NSMutableSet set];
        self.pendingOperations = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resume) name:kPSURLCacheDidIdle object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSURLCacheDidIdle object:self];
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
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:kPSURLCacheDidIdle object:self] postingStyle:NSPostWhenIdle];
}

#pragma mark - Cache
// Write to Cache
- (void)cacheData:(NSData *)data URL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType {
    if (!data || !URL) return;
    
    NSURL *cachedURL = [URL copy];
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    [data writeToFile:cachePath atomically:YES];
}

// Read from Cache
- (void)loadURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error))completionBlock {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    // Configure request
    request.timeoutInterval = 15; // 15 seconds
    
    [self loadRequest:request cacheType:cacheType usingCache:usingCache completionBlock:completionBlock];
}

- (void)loadRequest:(NSMutableURLRequest *)request cacheType:(PSURLCacheType)cacheType usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *, NSURL *, BOOL, NSError *))completionBlock {
    [self loadRequest:request cacheType:cacheType cachePriority:PSURLCachePriorityLow usingCache:usingCache completionBlock:completionBlock];
}

- (void)loadRequest:(NSMutableURLRequest *)request cacheType:(PSURLCacheType)cacheType cachePriority:(PSURLCachePriority)cachePriority usingCache:(BOOL)usingCache completionBlock:(void (^)(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error))completionBlock {
    ASSERT_MAIN_THREAD;
    
    if (!request || !request.URL) {
        NSError *error = [NSError errorWithDomain:@"PSURLCacheErrorDomain" code:500 userInfo:nil];
        completionBlock(nil, nil, NO, error);
        return;
    }
    
    NSURL *cachedURL = [request.URL copy];
    
    if ([self.pendingURLs containsObject:PSURLCacheKeyWithURL(cachedURL)]) {
        return;
    } else {
        [self.pendingURLs addObject:PSURLCacheKeyWithURL(cachedURL)];
    }
    
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    NSData *data = [NSData dataWithContentsOfFile:cachePath];
    
    if (data && usingCache && !self.noCache) {
        [self.pendingURLs removeObject:PSURLCacheKeyWithURL(cachedURL)];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[cachedURL copy], @"cachedURL", [NSNumber numberWithInteger:cacheType], @"cacheType", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPSURLCacheDidCache object:self userInfo:userInfo];
        
        // This is a hack to force data to be loaded one UI cycle later so that the view is properly oriented before data is loaded
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            completionBlock(data, cachedURL, YES, nil);
        }];
    } else {
        BLOCK_SELF;
        
        PSURLCacheNetworkBlock networkBlock = ^(void) {
            ASSERT_NOT_MAIN_THREAD;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:nil];
            
            DLog(@"### Request: %@", request.URL.absoluteString);
            DLog(@"### Request: %d remaining in low priority queue", self.networkQueue.operationCount);
            
            NSError *error = nil;
            NSHTTPURLResponse *response = nil;
            NSData *cachedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            
            // Handle HTTP response codes
            if ([response isKindOfClass:[NSHTTPURLResponse class]] && response.statusCode != 200) {
                error = [NSError errorWithDomain:@"PSURLCacheErrorDomain" code:response.statusCode userInfo:nil];
            }
            
            // Cache data if exists
            if (cachedData && !error) {
                [blockSelf cacheData:cachedData URL:cachedURL cacheType:cacheType];
            }
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                ASSERT_MAIN_THREAD;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:nil];
                
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[cachedURL copy], @"cachedURL", [NSNumber numberWithInteger:cacheType], @"cacheType", nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kPSURLCacheDidCache object:self userInfo:userInfo];
                
                completionBlock(cachedData, cachedURL, NO, error);
                
                [self.pendingURLs removeObject:PSURLCacheKeyWithURL(cachedURL)];
            }];
        };
             
        // Queue up a network request
        if (cachePriority == PSURLCachePriorityHigh) {
             [self.priorityQueue addOperationWithBlock:networkBlock];
        } else {
            if (self.networkQueue.isSuspended) {
                [self.pendingOperations addObject:[networkBlock copy]];
            } else {
                [self.networkQueue addOperationWithBlock:networkBlock];
            }
        }
    }
}

- (NSData *)dataForCachedURL:(NSURL *)cachedURL cacheType:(PSURLCacheType)cacheType {
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    NSData *data = [NSData dataWithContentsOfFile:cachePath];
    return data;
}

#pragma mark - Cache Path
- (NSString *)cacheDirectoryPathForCacheType:(PSURLCacheType)cacheType {
    NSString *cacheBaseDirectory = (cacheType == PSURLCacheTypeSession) ? NSTemporaryDirectory() : (NSString *)[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    
    NSString *cacheDirectoryPath = [cacheBaseDirectory stringByAppendingPathComponent:NSStringFromClass([self class])];
    
    // Creates directory if necessary
    BOOL isDir = NO;
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectoryPath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return cacheDirectoryPath;
}

- (NSString *)cachePathForURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType {
    NSString *cacheDirectoryPath = [self cacheDirectoryPathForCacheType:cacheType];
    
    NSString *cacheKey = PSURLCacheKeyWithURL(URL);
    NSString *cachePath = [cacheDirectoryPath stringByAppendingPathComponent:cacheKey];
    
    return cachePath;
}

#pragma mark - Purge Cache
- (void)removeCacheForURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType {
    NSURL *cachedURL = [URL copy];
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
}

- (void)purgeCacheWithCacheType:(PSURLCacheType)cacheType {
    NSString *cacheDirectoryPath = [self cacheDirectoryPathForCacheType:cacheType];
    
    // Removes and recreates directory
    BOOL isDir = NO;
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheDirectoryPath isDirectory:&isDir] && isDir == YES) {
        [[NSFileManager defaultManager] removeItemAtPath:cacheDirectoryPath error:&error];
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

@end
