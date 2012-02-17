//
//  PSImageView.h
//  PSKit
//
//  Created by Peter Shih on 3/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface PSImageView : UIImageView

- (void)animateImageFade:(UIImage *)image;

@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) UIImage *placeholderImage;
@property (nonatomic, assign) BOOL shouldResize;
@property (nonatomic, assign) BOOL shouldAnimate;

@end
