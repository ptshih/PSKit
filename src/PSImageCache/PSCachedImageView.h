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

@interface PSCachedImageView : PSImageView {
  NSURL *_url;
}

@property (nonatomic, copy) NSURL *url;

- (void)loadImageWithURL:(NSURL *)URL;
- (void)loadThumbnailWithURL:(NSURL *)URL;
- (void)unloadImage;

- (UIImage *)originalImage;

- (void)prepareForReuse;

@end