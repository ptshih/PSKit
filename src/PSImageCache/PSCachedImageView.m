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
URL = _URL,
originalURL = _originalURL,
thumbnailURL = _thumbnailURL;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidCache:) name:kPSImageCacheDidCacheImage object:nil];
    }
    return self;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.URL = nil;
    self.originalURL = nil;
    self.thumbnailURL = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.thumbnailURL = nil;
    self.originalURL = nil;
    self.URL = nil;
    self.image = nil;
}

- (void)loadImageWithURL:(NSURL *)URL {
    [self loadImageWithURL:URL cacheType:PSImageCacheTypePermanent];
}

- (void)loadImageWithURL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType {
    self.URL = URL;
    
    [[PSImageCache sharedCache] loadImageDataWithURL:self.URL cacheType:cacheType completionBlock:^(NSData *imageData, NSURL *cachedURL) {
        if ([self.URL isEqual:cachedURL]) {
            self.image = [UIImage imageWithData:imageData];
        }
    } failureBlock:^(NSError *error) {
        self.image = self.placeholderImage;
    }];
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidCache:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSURL *URL = [userInfo objectForKey:@"url"];
    
    if ([URL isEqual:self.URL]) {
        [[PSImageCache sharedCache] loadImageDataWithURL:self.URL cacheType:PSImageCacheTypePermanent completionBlock:^(NSData *imageData, NSURL *cachedURL) {
            if ([self.URL isEqual:cachedURL]) {
                self.image = [UIImage imageWithData:imageData];
            }
        } failureBlock:^(NSError *error) {
            self.image = self.placeholderImage;
        }];
    }
}

@end