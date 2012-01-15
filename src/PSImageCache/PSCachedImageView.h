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
}

- (void)loadImageWithURL:(NSURL *)url;
- (void)unloadImage;

- (UIImage *)originalImage;

@end