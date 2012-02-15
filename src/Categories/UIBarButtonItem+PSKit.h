//
//  UIBarButtonItem+PSKit.h
//  Linsanity
//
//  Created by Peter Shih on 8/7/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
  BarButtonTypeNormal = 0,
  BarButtonTypeBlue = 1,
  BarButtonTypeRed = 2,
  BarButtonTypeGreen = 3,
  BarButtonTypeSilver = 4,
  BarButtonTypeBordered = 5,
  BarButtonTypeNone = 6
};
typedef uint32_t BarButtonType;

@interface UIBarButtonItem (PSKit)

+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType style:(NSString *)style;
+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType;
+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType;
+ (UIBarButtonItem *)navBackButtonWithTarget:(id)target action:(SEL)action;

@end
