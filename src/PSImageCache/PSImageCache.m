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
cacheBasePath = _cacheBasePath;

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
        self.cacheBasePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] 
                              stringByAppendingPathComponent:NSStringFromClass([self class])];
    }
    return self;
}

- (void)dealloc {
    self.cacheBasePath = nil;
    [super dealloc];
}

#pragma mark - Cache
// Write to Cache
- (void)cacheImageData:(NSData *)imageData URL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType {
    if (!imageData || !URL) return;
    
    NSURL *cachedURL = [[URL copy] autorelease];
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    [imageData writeToFile:cachePath atomically:YES];
    
    // Broadcast to all observers that 'cachedURL' has been cached
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:cachedURL forKey:@"url"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPSImageCacheDidCacheImage object:nil userInfo:userInfo];
}

// Read from Cache
- (void)loadImageDataWithURL:(NSURL *)URL 
                   cacheType:(PSImageCacheType)cacheType 
             completionBlock:(void (^)(NSData *imageData))completionBlock 
                failureBlock:(void (^)(NSError *error))failureBlock {
    if (!URL) failureBlock(nil);
    
    NSURL *cachedURL = [[URL copy] autorelease];
    NSString *cachePath = [self cachePathForURL:cachedURL cacheType:cacheType];
    NSData *imageData = [NSData dataWithContentsOfFile:cachePath];
    
    if (imageData) {
        completionBlock(imageData);
    } else {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [NSURLConnection sendAsynchronousRequest:request 
                                           queue:[NSOperationQueue mainQueue] 
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   if (data && !error) {
                                       [self cacheImageData:data URL:URL cacheType:cacheType];
                                       completionBlock(data);
                                   } else {
                                       failureBlock(error);
                                   }
                               }];
    }
}

#pragma mark - Cache Path
- (NSString *)cacheDirectoryPathForCacheType:(PSImageCacheType)cacheType {
    NSString *cacheDirectoryPath = nil;
    
    switch (cacheType) {
        case PSImageCacheTypeSession:
            cacheDirectoryPath = [self.cacheBasePath stringByAppendingPathComponent:@"SessionCache"];
            break;
        case PSImageCacheTypePermanent:
            cacheDirectoryPath = [self.cacheBasePath stringByAppendingPathComponent:@"PermanentCache"];
            break;
        default:
            cacheDirectoryPath = [self.cacheBasePath stringByAppendingPathComponent:@"SessionCache"];
            break;
    }
    
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
- (void)purgeSessionCache {
    [self purgeCacheWithCacheType:PSImageCacheTypeSession];
}

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
