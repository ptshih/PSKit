//
//  PSCachedImageView.h
//  PSKit
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageCache.h"

@interface PSCachedImageView : PSImageView {
  NSURL *_url;
  CGSize _thumbnailSize;
  UIImage *_originalImage;
  UIImage *_thumbnailImage;
}

- (UIImage *)originalImage;

- (void)loadImageWithURL:(NSURL *)url shouldDownload:(BOOL)shouldDownload thumbnailWithSize:(CGSize)thumbnailSize;
- (void)loadImageWithURL:(NSURL *)url shouldDownload:(BOOL)shouldDownload;
- (void)loadImageWithURL:(NSURL *)url;
- (void)unloadImage;

@end