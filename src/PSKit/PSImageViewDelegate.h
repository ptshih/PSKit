//
//  PSImageViewDelegate.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/19/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol PSImageViewDelegate <NSObject>
@optional
- (void)imageDidLoad:(UIImage *)image;
@end
