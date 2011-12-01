//
//  PSImageArrayView.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/17/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSCachedImageView.h"

@interface PSImageArrayView : PSCachedImageView {
  NSArray *_urlPathArray;
  NSMutableArray *_images;
  
  NSTimer *_animateTimer;
  NSInteger _animateIndex;
}

@property (nonatomic, retain) NSArray *urlPathArray;

- (void)loadImageArray;
- (void)unloadImageArray;

- (void)prepareImageArray;
- (void)animateImages;

- (void)resumeAnimations;
- (void)pauseAnimations;
- (void)pauseLayer:(CALayer*)layer;
- (void)resumeLayer:(CALayer*)layer;

@end
