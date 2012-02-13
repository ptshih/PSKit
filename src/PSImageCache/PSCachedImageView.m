//
//  PSCachedImageView.m
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCachedImageView.h"

@interface PSCachedImageView (Private)

- (void)setImageWithCachedImageData:(NSData *)imageData;

@end

@implementation PSCachedImageView

@synthesize
url = _url,
sourceURL = _sourceURL,
thumbnailURL = _thumbnailURL;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidCache:) name:kPSImageCacheDidCacheImage object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.url = nil;
    self.sourceURL = nil;
    self.thumbnailURL = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.thumbnailURL = nil;
    self.sourceURL = nil;
    self.url = nil;
    self.image = nil;
}

- (void)loadImageWithURL:(NSURL *)URL {
    self.url = URL;
    NSData *imageData = [[PSImageCache sharedCache] cachedImageDataForURL:self.url];
    [self setImageWithCachedImageData:imageData];
}

- (void)loadThumbnailWithURL:(NSURL *)URL {
    self.url = URL;
    NSData *imageData = [[PSImageCache sharedCache] cachedThumbnailDataForURL:self.url];
    [self setImageWithCachedImageData:imageData];
}

- (void)unloadImage {
    [[PSImageCache sharedCache] cancelDownloadForURL:self.url];
    self.image = self.placeholderImage;
}

- (UIImage *)originalImage {
    return [[PSImageCache sharedCache] cachedImageForURL:self.url];
}

- (void)setImageWithCachedImageData:(NSData *)imageData {
    if (!imageData) return;
    [imageData retain];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *cachedImage = [[UIImage alloc] initWithData:imageData];
        [imageData release];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (cachedImage) {
                self.image = cachedImage;
                [cachedImage release];
            } else {
                self.image = self.placeholderImage;
            }
        });
    });
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidCache:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSURL *url = [userInfo objectForKey:@"url"];
    BOOL showThumbnail = [[userInfo objectForKey:@"showThumbnail"] boolValue];
    
    if ([url isEqual:self.url]) {
        NSData *imageData = nil;
        if (showThumbnail) {
            imageData = [[PSImageCache sharedCache] cachedThumbnailDataForURL:url];
        } else {
            imageData = [[PSImageCache sharedCache] cachedImageDataForURL:url];
        }
        [self setImageWithCachedImageData:imageData];
    }
}

@end