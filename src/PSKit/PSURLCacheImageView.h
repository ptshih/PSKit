//
//  PSURLCacheImageView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageCache.h"

@interface PSURLCacheImageView : PSImageView {
  NSString *_urlPath;
}

@property (nonatomic, copy) NSString *urlPath;

- (void)loadImageAndDownload:(BOOL)download;
- (void)unloadImage;

// Image cache loaded from notification
- (void)imageCacheDidLoad:(NSNotification *)notification;

@end