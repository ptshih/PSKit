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
originalURL = _originalURL,
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
    self.originalURL = nil;
    self.thumbnailURL = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.thumbnailURL = nil;
    self.originalURL = nil;
    self.url = nil;
    self.image = nil;
}

- (void)loadImageWithURL:(NSURL *)URL {
    [self loadImageWithURL:URL cacheType:PSImageCacheTypePermanent];
}

- (void)loadImageWithURL:(NSURL *)URL cacheType:(PSImageCacheType)cacheType {
    self.url = URL;
    
    [[PSImageCache sharedCache] loadImageDataWithURL:self.url cacheType:cacheType completionBlock:^(NSData *imageData) {
        self.image = [UIImage imageWithData:imageData];
    } failureBlock:^(NSError *error) {
        self.image = self.placeholderImage;
    }];
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidCache:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSURL *url = [userInfo objectForKey:@"url"];
    
    if ([url isEqual:self.url]) {
        [[PSImageCache sharedCache] loadImageDataWithURL:self.url cacheType:PSImageCacheTypePermanent completionBlock:^(NSData *imageData) {
            self.image = [UIImage imageWithData:imageData];
        } failureBlock:^(NSError *error) {
            self.image = self.placeholderImage;
        }];
    }
}

@end