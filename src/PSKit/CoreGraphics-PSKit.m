//
//  CoreGraphics-PSKit.m
//  OSnap
//
//  Created by Peter Shih on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CoreGraphics-PSKit.h"

CGImageRef CreateCGImageWithinSize(CGImageRef imageRef, CGSize withinSize, UIImageOrientation imageOrientation) {
  CGAffineTransform transform = CGAffineTransformIdentity;  
  
  CGFloat originalWidth = CGImageGetWidth(imageRef);
  CGFloat originalHeight = CGImageGetHeight(imageRef);
  
  CGSize newSize = CGSizeMake(originalWidth, originalHeight);
  CGFloat widthScale = withinSize.width / originalWidth;
  CGFloat heightScale = withinSize.height / originalHeight;
  CGFloat scale = MIN(widthScale, heightScale);
  
  if (scale < 1.0) {
    newSize.width = floor(originalWidth * scale);
    newSize.height = floor(originalHeight * scale);
  }
  
  CGFloat oldWidth = 0.0;
  BOOL shouldRotateDuringTranslate = NO;
  CGSize originalSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));  
  switch (imageOrientation) {  
    case UIImageOrientationUp: //EXIF = 1  
      transform = CGAffineTransformIdentity;  
      break;  
      
    case UIImageOrientationUpMirrored: //EXIF = 2  
      transform = CGAffineTransformMakeTranslation(originalSize.width, 0.0);  
      transform = CGAffineTransformScale(transform, -1.0, 1.0);  
      break;  
      
    case UIImageOrientationDown: //EXIF = 3  
      transform = CGAffineTransformMakeTranslation(originalSize.width, originalSize.height);  
      transform = CGAffineTransformRotate(transform, M_PI);  
      break;  
      
    case UIImageOrientationDownMirrored: //EXIF = 4  
      transform = CGAffineTransformMakeTranslation(0.0, originalSize.height);  
      transform = CGAffineTransformScale(transform, 1.0, -1.0);  
      break;  
      
    case UIImageOrientationLeftMirrored: //EXIF = 5  
      shouldRotateDuringTranslate = YES;
      oldWidth = newSize.width;
      newSize.width = newSize.height;
      newSize.height = oldWidth;
      transform = CGAffineTransformMakeScale(-1.0, 1.0);  
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
      break;  
      
    case UIImageOrientationLeft: //EXIF = 6  
      shouldRotateDuringTranslate = YES;
      oldWidth = newSize.width;
      newSize.width = newSize.height;
      newSize.height = oldWidth;
      transform = CGAffineTransformMakeTranslation(originalSize.height, 0.0);  
      transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
      break;  
      
    case UIImageOrientationRightMirrored: //EXIF = 7  
      shouldRotateDuringTranslate = YES;
      oldWidth = newSize.width;
      newSize.width = newSize.height;
      newSize.height = oldWidth;
      transform = CGAffineTransformMakeTranslation(originalSize.height, originalSize.width);  
      transform = CGAffineTransformScale(transform, -1.0, 1.0);  
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
      break;  
      
    case UIImageOrientationRight: //EXIF = 8  
      shouldRotateDuringTranslate = YES;
      oldWidth = newSize.width;
      newSize.width = newSize.height;
      newSize.height = oldWidth;
      transform = CGAffineTransformMakeTranslation(0.0, originalSize.width);  
      transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
      break;  
      
    default:
      NSLog(@"Error: Invalid image orientation: %d", imageOrientation);
      break;
  }  
  
  NSUInteger bitsPerComponent = 8;
  CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
  CGImageAlphaInfo alphaInfo = kCGImageAlphaNoneSkipFirst;
  NSUInteger bytesPerPixel = 4;
  NSUInteger bytesPerRow = newSize.width * bytesPerPixel;
  CGContextRef context = CGBitmapContextCreate(NULL, newSize.width, newSize.height, bitsPerComponent, bytesPerRow, colorspace, alphaInfo);
  CGColorSpaceRelease(colorspace);
  
  CGImageRef scaledImage = NULL;
  if (context) {
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -newSize.height);  
    
    CGContextScaleCTM(context, scale, -scale);  
    
    CGFloat translateAmount = shouldRotateDuringTranslate ? -originalWidth : -originalHeight;
    CGContextTranslateCTM(context, 0, translateAmount);
    
    CGContextConcatCTM(context, transform);  
    
    CGRect drawInRect = CGRectMake(0, 0, originalWidth, originalHeight);
    
    CGContextDrawImage(context, drawInRect, imageRef);
    
    scaledImage = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
  } else {
    NSLog(@"Failed to create context!");
  }
  
  return scaledImage;
}