//
//  PSCachedImageView.m
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCachedImageView.h"

static NSOperationQueue *__loadQueue = nil;

@interface PSCachedImageView ()

@property (nonatomic, strong) NSOperationQueue *imageQueue;

@end

@implementation PSCachedImageView

+ (void)initialize {
    __loadQueue = [[NSOperationQueue alloc] init];
    __loadQueue.maxConcurrentOperationCount = 1;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageQueue = [[NSOperationQueue alloc] init];
        self.imageQueue.maxConcurrentOperationCount = 1;
        
        self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.loadingIndicator.hidesWhenStopped = YES;
        self.loadingIndicator.frame = self.bounds;
        self.loadingIndicator.contentMode = UIViewContentModeCenter;
        [self.loadingIndicator startAnimating];
        [self addSubview:self.loadingIndicator];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)loadImage:(UIImage *)image {
    [self.loadingIndicator stopAnimating];
    self.image = image;
}

- (void)loadImageWithURL:(NSURL *)URL {
    [self loadImageWithURL:URL cacheType:PSURLCacheTypePermanent];
}

- (void)loadImageWithURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType {
    self.URL = URL;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageDidLoad:) name:kPSURLCacheDidCache object:[PSURLCache sharedCache]];
    
    [[PSURLCache sharedCache] loadURL:self.URL cacheType:cacheType usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        ASSERT_MAIN_THREAD;
        if (error) {
            [self.loadingIndicator stopAnimating];
            DLog(@"eror loading image: %@", cachedURL);
            self.image = self.placeholderImage;
        } else {
            // use notification
        }
    }];
}

- (void)imageDidLoad:(NSNotification *)notification {
    NSURL *cachedURL = [notification.userInfo objectForKey:@"cachedURL"];
    PSURLCacheType cacheType = [[notification.userInfo objectForKey:@"cacheType"] integerValue];
    
    if ([self.URL isEqual:cachedURL]) {
//        DLog(@"local URL: %@, remote URL: %@", self.URL, cachedURL);
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *cachedData = [[PSURLCache sharedCache] dataForCachedURL:cachedURL cacheType:cacheType];
            UIImage *image = [UIImage imageWithData:cachedData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [__loadQueue addOperationWithBlock:^{
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        ASSERT_MAIN_THREAD;
                        if ([self.URL isEqual:cachedURL]) {
                            [self.loadingIndicator stopAnimating];
                            self.image = image;
                        }
                    }];
                }];
            });
        });
    }
}

@end
