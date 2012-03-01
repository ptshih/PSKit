//
//  UIImage+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "UIImage+PSKit.h"
#import <QuartzCore/QuartzCore.h>
#define kEncodingKey @"UIImage"

@implementation UIImage (PSKit)

#pragma mark - Orientation
- (BOOL)isPortrait {
  return self.size.width < self.size.height;
}

- (BOOL)isLandscape {
  return self.size.width > self.size.height;
}

- (BOOL)isSquare {
  return self.size.width == self.size.height;
}

- (UIImage *)imageWithFixedOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)imageScaledAndRotated {
    int kMaxResolution = 720; // Or whatever
    
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

#pragma mark - Strechable
+ (UIImage *)stretchableImageNamed:(NSString *)name withLeftCapWidth:(NSInteger)leftCapWidth topCapWidth:(NSInteger)topCapWidth; {
  return [[UIImage imageNamed:name] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapWidth];
}

#pragma mark - Screen Scale
- (UIImage *)imageScaledForScreen {
  CGFloat s = 1.0f;
  if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
    s = [[UIScreen mainScreen] scale];
  }
  return [UIImage imageWithCGImage:self.CGImage scale:s orientation:self.imageOrientation];
}

#pragma mark - Screenshot
// Helper
+ (void)beginImageContextWithSize:(CGSize)size {
  if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    if ([[UIScreen mainScreen] scale] == 2.0) {
      UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
    } else {
      UIGraphicsBeginImageContext(size);
    }
  } else {
    UIGraphicsBeginImageContext(size);
  }
}

+ (UIImage *)imageFromView:(UIView*)view {
  [self beginImageContextWithSize:[view bounds].size];
  BOOL hidden = [view isHidden];
  [view setHidden:NO];
  [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  [view setHidden:hidden];
  return image;
}

+ (UIImage *)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize {
  UIImage *image = [self imageFromView:view];
  if ([view bounds].size.width != newSize.width ||
      [view bounds].size.height != newSize.height) {
    image = [self imageWithImage:image scaledToSize:newSize];
  }
  return image;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
  [self beginImageContextWithSize:newSize];
  [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

#pragma mark - Scaling and Cropping
- (UIImage *)scaledImageWithinSize:(CGSize)withinSize {
  UIImage *image = self;
  
  CGImageRef scaledImageRef = CreateCGImageWithinSize(self.CGImage, withinSize, self.imageOrientation);
  if (scaledImageRef) {
    image = [UIImage imageWithCGImage:scaledImageRef];
    CFRelease(scaledImageRef);
  }
  
  return image;
}

- (CGSize)scaledSizeProportionalToSize:(CGSize)desiredSize {
  if(self.size.width > self.size.height) {
    // Landscape
    desiredSize = CGSizeMake((self.size.width / self.size.height) * desiredSize.height, desiredSize.height);
  } else {
    // Portrait
    desiredSize = CGSizeMake(desiredSize.width, (self.size.height / self.size.width) * desiredSize.width);
  }
  
  return desiredSize;
}

- (CGSize)scaledSizeBoundedByWidth:(CGFloat)desiredWidth {
  CGSize desiredSize;
  if(self.size.width > self.size.height) {
    // Landscape
    desiredSize = CGSizeMake(desiredWidth, (self.size.width / (self.size.width / desiredWidth)));
  } else {
    // Portrait
    desiredSize = CGSizeMake(desiredWidth, (self.size.height / self.size.width) * desiredWidth);
  }
  
  return desiredSize;
}

- (UIImage *)scaleToSize:(CGSize)desiredSize {
  CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
  CGContextRef ctx = CGBitmapContextCreate(NULL, desiredSize.width, desiredSize.height, 8, 0, colorSpaceRef, kCGImageAlphaPremultipliedLast);
  CGContextClearRect(ctx, CGRectMake(0, 0, desiredSize.width, desiredSize.height));
  
  if(self.imageOrientation == UIImageOrientationRight) {
    CGContextRotateCTM(ctx, -M_PI_2);
    CGContextTranslateCTM(ctx, -desiredSize.height, 0.0f);
    CGContextDrawImage(ctx, CGRectMake(0, 0, desiredSize.height, desiredSize.width), self.CGImage);
  } else {
    CGContextDrawImage(ctx, CGRectMake(0, 0, desiredSize.width, desiredSize.height), self.CGImage);
  }
  
  CGImageRef scaledImage = CGBitmapContextCreateImage(ctx);
  
  CGColorSpaceRelease(colorSpaceRef);
  CGContextRelease(ctx);
  
  UIImage *image = [UIImage imageWithCGImage:scaledImage];
  
  CGImageRelease(scaledImage);
  
  return image;
}

/**
 This just scales
 */
- (UIImage *)scaleProportionalToSize:(CGSize)desiredSize {
  if(self.size.width > self.size.height) {
    // Landscape
    desiredSize = CGSizeMake((self.size.width / self.size.height) * desiredSize.height, desiredSize.height);
  } else {
    // Portrait
    desiredSize = CGSizeMake(desiredSize.width, (self.size.height / self.size.width) * desiredSize.width);
  }
  
  return [self scaleToSize:desiredSize];
}

/**
 Crops an image by first scaling the image (if it is smaller than the desired size)
 so that the resulting crop will fully fill to the desired size.
 
 The resulting crop will be in the absolute center of the original image
 
 Example:
 I want an image that will fit into 320x480 but the image I am given is 200x200
 The code will first scale the image to fit the largest dimension of the desired size (480x480 in this case)
 Then it will crop 80 pixels offset from the left and right resulting in an image that is 320x480
 */
- (UIImage *)cropProportionalToSize:(CGSize)desiredSize {
  return [self cropProportionalToSize:desiredSize withRuleOfThirds:NO];
}

- (UIImage *)cropProportionalToSize:(CGSize)desiredSize withRuleOfThirds:(BOOL)withRuleOfThirds {
  CGFloat desiredWidth = desiredSize.width;
  CGFloat desiredHeight = desiredSize.height;
  CGFloat maxDimension = (desiredWidth > desiredHeight) ? desiredWidth : desiredHeight;
  
  if (self.size.width > self.size.height) {
    // Landscape
    self = [self scaleProportionalToSize:CGSizeMake(INT_MAX, maxDimension)];
  } else if (self.size.width < self.size.height) {
    // Portrait
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, INT_MAX)];
  } else {
    // Square
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, maxDimension)];
  }
  
  CGFloat leftMargin = ceil((self.size.width - desiredWidth) / 2);
  CGFloat topMargin = 0.0;
  if (withRuleOfThirds) {
    topMargin = ceil((self.size.height / 3) / 2);
  } else {
    topMargin = ceil((self.size.height - desiredHeight) / 2);
  }
  
  CGRect desiredRect = CGRectMake(leftMargin, topMargin, desiredWidth, desiredHeight);
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], desiredRect);
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return croppedImage;
}

- (UIImage *)scaledProportionalToSize:(CGSize)desiredSize {
  CGFloat desiredWidth = desiredSize.width;
  CGFloat desiredHeight = desiredSize.height;
  CGFloat maxDimension = (desiredWidth > desiredHeight) ? desiredWidth : desiredHeight;
  
  if (self.size.width > self.size.height) {
    // Landscape
    self = [self scaleProportionalToSize:CGSizeMake(INT_MAX, maxDimension)];
  } else if (self.size.width < self.size.height) {
    // Portrait
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, INT_MAX)];
  } else {
    // Square
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, maxDimension)];
  }
  return self;
}

- (UIImage *)scaledBoundedByWidth:(CGFloat)desiredWidth {
  CGSize desiredSize = [self scaledSizeBoundedByWidth:desiredWidth];
  
  CGFloat leftMargin = ceil((self.size.width - desiredSize.width) / 2);
  CGFloat topMargin = ceil((self.size.height - desiredSize.height) / 2);
  
  CGRect desiredRect = CGRectMake(leftMargin, topMargin, desiredSize.width, desiredSize.height);
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], desiredRect);
  UIImage *scaledImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return scaledImage; 
  
}

#pragma mark - Trevor

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality {
  CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
  CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
  CGImageRef imageRef = self.CGImage;
  
  // Build a context that's the same dimensions as the new size
  CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                              newRect.size.width,
                                              newRect.size.height,
                                              CGImageGetBitsPerComponent(imageRef),
                                              0,
                                              CGImageGetColorSpace(imageRef),
                                              CGImageGetBitmapInfo(imageRef));
  
  // Rotate and/or flip the image if required by its orientation
  CGContextConcatCTM(bitmap, transform);
  
  // Set the quality level to use when rescaling
  CGContextSetInterpolationQuality(bitmap, quality);
  
  // Draw into the context; this scales the image
  CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
  
  // Get the resized image from the context and a UIImage
  CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
  UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
  
  // Clean up
  CGContextRelease(bitmap);
  CGImageRelease(newImageRef);
  
  return newImage;
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  switch (self.imageOrientation) {
    case UIImageOrientationDown:           // EXIF = 3
    case UIImageOrientationDownMirrored:   // EXIF = 4
      transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
    case UIImageOrientationLeft:           // EXIF = 6
    case UIImageOrientationLeftMirrored:   // EXIF = 5
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:          // EXIF = 8
    case UIImageOrientationRightMirrored:  // EXIF = 7
      transform = CGAffineTransformTranslate(transform, 0, newSize.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    default:
      break;
  }
  
  switch (self.imageOrientation) {
    case UIImageOrientationUpMirrored:     // EXIF = 2
    case UIImageOrientationDownMirrored:   // EXIF = 4
      transform = CGAffineTransformTranslate(transform, newSize.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    case UIImageOrientationLeftMirrored:   // EXIF = 5
    case UIImageOrientationRightMirrored:  // EXIF = 7
      transform = CGAffineTransformTranslate(transform, newSize.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    default:
      break;
  }
  
  return transform;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality {
  BOOL drawTransposed;
  
  switch (self.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      drawTransposed = YES;
      break;
      
    default:
      drawTransposed = NO;
  }
  
  return [self resizedImage:newSize
                  transform:[self transformForOrientation:newSize]
             drawTransposed:drawTransposed
       interpolationQuality:quality];
}

// Resizes the image according to the given content mode, taking into account the image's orientation
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality {
  CGFloat horizontalRatio = bounds.width / self.size.width;
  CGFloat verticalRatio = bounds.height / self.size.height;
  CGFloat ratio;
  
  switch (contentMode) {
    case UIViewContentModeScaleAspectFill:
      ratio = MAX(horizontalRatio, verticalRatio);
      break;
      
    case UIViewContentModeScaleAspectFit:
      ratio = MIN(horizontalRatio, verticalRatio);
      break;
      
    default:
      [NSException raise:NSInvalidArgumentException format:@"Unsupported content mode: %d", contentMode];
  }
  
  CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
  
  return [self resizedImage:newSize interpolationQuality:quality];
}

@end
