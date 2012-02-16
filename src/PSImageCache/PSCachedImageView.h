//
//  PSCachedImageView.h
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageView.h"
#import "PSImageCache.h"

@interface PSCachedImageView : PSImageView

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSURL *originalURL;
@property (nonatomic, copy) NSURL *thumbnailURL;

- (void)loadImageWithURL:(NSURL *)URL;
- (void)prepareForReuse;

@end