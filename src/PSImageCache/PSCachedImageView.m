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
thumbnailURL = _thumbnailURL,
loadingIndicator = _loadingIndicator;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.loadingIndicator.hidesWhenStopped = YES;
        self.loadingIndicator.frame = self.bounds;
        self.loadingIndicator.contentMode = UIViewContentModeCenter;
        [self.loadingIndicator startAnimating];
        [self addSubview:self.loadingIndicator];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidCache:) name:kPSImageCacheDidCacheImage object:nil];
    }
    return self;
}

- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.URL = nil;
    self.originalURL = nil;
    self.thumbnailURL = nil;
    self.loadingIndicator = nil;
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.loadingIndicator.frame = self.bounds;
}

- (void)prepareForReuse {
    [self.loadingIndicator startAnimating];
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
            [self.loadingIndicator stopAnimating];
            self.image = [UIImage imageWithData:imageData];
        }
    } failureBlock:^(NSError *error) {
        [self.loadingIndicator stopAnimating];
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