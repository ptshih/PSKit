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

@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) UIColor *loadingColor;
@property (nonatomic, assign) BOOL shouldResize;
@property (nonatomic, assign) BOOL shouldAnimate;

- (void)prepareForReuse;

@end
