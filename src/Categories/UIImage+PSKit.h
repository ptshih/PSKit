//
//  UIImage+PSKit.h
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (PSKit)

#pragma mark - Orientation
- (BOOL)isPortrait;
- (BOOL)isLandscape;
- (BOOL)isSquare;

- (UIImage *)imageWithFixedOrientation;

- (UIImage *)imageScaledAndRotated;

// UNTESTED BELOW

#pragma mark - Strechable
+ (UIImage *)stretchableImageNamed:(NSString *)name withLeftCapWidth:(NSInteger)leftCapWidth topCapWidth:(NSInteger)topCapWidth;

#pragma mark - Screen Scale
- (UIImage *)imageScaledForScreen;

#pragma mark - Screenshot
+ (UIImage *)imageFromView:(UIView*)view;
+ (UIImage *)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage *)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

#pragma mark - Scaling and Cropping
- (UIImage *)scaledImageWithinSize:(CGSize)withinSize;

- (CGSize)scaledSizeProportionalToSize:(CGSize)desiredSize;
- (CGSize)scaledSizeBoundedByWidth:(CGFloat)desiredWidth;
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)scaleProportionalToSize:(CGSize)desiredSize;
- (UIImage *)cropProportionalToSize:(CGSize)desiredSize;
- (UIImage *)cropProportionalToSize:(CGSize)desiredSize withRuleOfThirds:(BOOL)withRuleOfThirds;
- (UIImage *)scaledProportionalToSize:(CGSize)desiredSize;
- (UIImage *)scaledBoundedByWidth:(CGFloat)desiredWidth;

// This one SCALES based on content mode, DOES NOT CROP
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

@end
