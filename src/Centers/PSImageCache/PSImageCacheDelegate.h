//
//  PSImageCacheDelegate.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSImageCacheDelegate <NSObject>

@optional
- (void)imageCacheDidLoad:(UIImage *)image forURLPath:(NSString *)urlPath;

@end
