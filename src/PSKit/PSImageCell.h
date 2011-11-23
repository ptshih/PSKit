//
//  PSImageCell.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 2/25/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSURLCacheImageView.h"

@interface PSImageCell : PSCell {
  PSURLCacheImageView *_psImageView;
}

- (void)loadImage;

@end
