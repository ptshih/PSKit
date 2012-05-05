//
//  PSCachedImageView.h
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageView.h"

@interface PSCachedImageView : PSImageView

@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, copy) NSURL *originalURL;
@property (nonatomic, copy) NSURL *thumbnailURL;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;

- (void)loadImageWithURL:(NSURL *)URL;
- (void)loadImageWithURL:(NSURL *)URL cacheType:(PSURLCacheType)cacheType;

@end
