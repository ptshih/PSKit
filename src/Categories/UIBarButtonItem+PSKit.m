//
//  UIBarButtonItem+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 8/7/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "UIBarButtonItem+PSKit.h"
#import "PSStyleSheet.h"

@interface UIBarButtonItem (PSKit_Private)

+ (UIImage *)bgForBarButtonType:(BarButtonType)barButtonType pressed:(BOOL)pressed;
@end

@implementation UIBarButtonItem (PSKit)

+ (UIImage *)bgForBarButtonType:(BarButtonType)barButtonType pressed:(BOOL)pressed {
  UIImage *bg = nil;
  UIImage *bgPressed = nil;
  
  switch (barButtonType) {
    case BarButtonTypeNormal:
      bg = [[UIImage imageNamed:@"PSKit.bundle/BarGrayButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"PSKit.bundle/BarGrayButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeBlue:
      bg = [[UIImage imageNamed:@"PSKit.bundle/BarBlueButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"PSKit.bundle/BarBlueButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeRed:
      bg = [[UIImage imageNamed:@"PSKit.bundle/BarRedButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"PSKit.bundle/BarRedButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeGreen:
      bg = [[UIImage imageNamed:@"PSKit.bundle/BarGreenButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"PSKit.bundle/BarGreenButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeSilver:
      bg = [[UIImage imageNamed:@"PSKit.bundle/BarSilverButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"PSKit.bundle/BarSilverButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeBordered:
      bg = [[UIImage imageNamed:@"PSKit.bundle/BarBorderedButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
      bgPressed = [[UIImage imageNamed:@"PSKit.bundle/BarBorderedButtonPressed.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
      break;
    case BarButtonTypeNone:
      break;
    default:
      break;
  }
  
  return pressed ? bgPressed : bg;
}

+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType style:(NSString *)style {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, width, height);
  [button setTitle:title forState:UIControlStateNormal];
  
  if (style) {
    [button.titleLabel setFont:[PSStyleSheet fontForStyle:style]];
    [button setTitleColor:[PSStyleSheet textColorForStyle:style] forState:UIControlStateNormal];
    [button.titleLabel setShadowColor:[PSStyleSheet shadowColorForStyle:style]];
    [button.titleLabel setShadowOffset:[PSStyleSheet shadowOffsetForStyle:style]];
  } else {
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
    button.titleLabel.shadowColor = [UIColor blackColor];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1);
  }
  
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:NO] forState:UIControlStateNormal];
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:YES] forState:UIControlStateHighlighted];
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:YES] forState:UIControlStateSelected];
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithCustomView:button];
  return navButton;
}

+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType {
  return [[self class] barButtonWithTitle:title withTarget:target action:action width:width height:height buttonType:buttonType style:nil];
}

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, width, height);
  [button setImage:image forState:UIControlStateNormal];
  [button setImage:highlightedImage forState:UIControlStateHighlighted];
  
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:NO] forState:UIControlStateNormal];
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:YES] forState:UIControlStateHighlighted];
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:YES] forState:UIControlStateSelected];
  
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithCustomView:button];
  return navButton;
}

+ (UIBarButtonItem *)navBackButtonWithTarget:(id)target action:(SEL)action {
  UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
  back.frame = CGRectMake(0, 0, 60, 44 - 14);
  [back setTitle:@"Back" forState:UIControlStateNormal];
  [back setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
  back.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0];
  back.titleLabel.shadowColor = [UIColor blackColor];
  back.titleLabel.shadowOffset = CGSizeMake(0, -1);
  UIImage *backImage = [[UIImage imageNamed:@"PSKit.bundle/BarBackButton.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
  UIImage *backHighlightedImage = [[UIImage imageNamed:@"PSKit.bundle/BarBackButtonPressed.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];  
  [back setBackgroundImage:backImage forState:UIControlStateNormal];
  [back setBackgroundImage:backHighlightedImage forState:UIControlStateHighlighted];
  [back addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:back];
  return backButton;
}

@end
