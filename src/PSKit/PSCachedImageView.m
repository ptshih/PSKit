//
//  PSCachedImageView.m
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCachedImageView.h"

@interface PSCachedImageView ()

@property (nonatomic, retain) NSOperationQueue *imageQueue;

@end

@implementation PSCachedImageView

@synthesize
imageQueue = _imageQueue,
URL = _URL,
originalURL = _originalURL,
thumbnailURL = _thumbnailURL,
loadingIndicator = _loadingIndicator;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageQueue = [[[NSOperationQueue alloc] init] autorelease];
        self.imageQueue.maxConcurrentOperationCount = 1;
        
        self.loadingIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        self.loadingIndicator.hidesWhenStopped = YES;
        self.loadingIndicator.frame = self.bounds;
        self.loadingIndicator.contentMode = UIViewContentModeCenter;
        [self.loadingIndicator startAnimating];
        [self addSubview:self.loadingIndicator];
    }
    return self;
}

- (void)dealloc {
    self.imageQueue = nil;
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
    [super prepareForReuse];
    [self.loadingIndicator startAnimating];
    self.thumbnailURL = nil;
    self.originalURL = nil;
    self.URL = nil;
}

- (void)loadImageWithURL:(NSURL *)URL {
    [self loadImageWithURL:URL cacheType:PSURLCacheTypePermanent];
}

- (void)loadImageWithURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType {
    self.URL = URL;
    
    [self.imageQueue cancelAllOperations];
    [self.imageQueue addOperationWithBlock:^{
        [[PSURLCache sharedCache] loadURL:self.URL cacheType:cacheType usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
            ASSERT_MAIN_THREAD;
            if (error) {
                [self.loadingIndicator stopAnimating];
                self.image = self.placeholderImage;
            } else {
                if ([self.URL isEqual:cachedURL]) {
                    [self.loadingIndicator stopAnimating];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        UIImage *image = [UIImage imageWithData:cachedData];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ASSERT_MAIN_THREAD;
                            self.image = image;
                        });
                    });
                }
            }
        }];
    }];
}

@end
