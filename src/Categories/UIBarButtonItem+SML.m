//
//  UIBarButtonItem+SML.m
//  PhotoTime
//
//  Created by Peter Shih on 8/7/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "UIBarButtonItem+SML.h"
#import "PSStyleSheet.h"

@interface UIBarButtonItem (SML_Private)

+ (UIImage *)bgForBarButtonType:(BarButtonType)barButtonType pressed:(BOOL)pressed;
@end

@implementation UIBarButtonItem (SML)

+ (UIImage *)bgForBarButtonType:(BarButtonType)barButtonType pressed:(BOOL)pressed {
  UIImage *bg = nil;
  UIImage *bgPressed = nil;
  
  switch (barButtonType) {
    case BarButtonTypeNormal:
      bg = [[UIImage imageNamed:@"BarGrayButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"BarGrayButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeBlue:
      bg = [[UIImage imageNamed:@"BarBlueButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"BarBlueButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeRed:
      bg = [[UIImage imageNamed:@"BarRedButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"BarRedButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeGreen:
      bg = [[UIImage imageNamed:@"BarGreenButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"BarGreenButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeSilver:
      bg = [[UIImage imageNamed:@"BarSilverButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"BarSilverButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeBordered:
      bg = [[UIImage imageNamed:@"BarBorderedButton.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
      bgPressed = [[UIImage imageNamed:@"BarBorderedButtonPressed.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
      break;
    default:
      bg = [[UIImage imageNamed:@"BarGrayButton.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgPressed = [[UIImage imageNamed:@"BarGrayButtonPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
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
  UIBarButtonItem *navButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
  return navButton;
}

+ (UIBarButtonItem *)barButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType {
  return [[self class] barButtonWithTitle:title withTarget:target action:action width:width height:height buttonType:buttonType style:nil];
}

+ (UIBarButtonItem *)barButtonWithImage:(UIImage *)image withTarget:(id)target action:(SEL)action width:(CGFloat)width height:(CGFloat)height buttonType:(BarButtonType)buttonType {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(0, 0, width, height);
  [button setImage:image forState:UIControlStateNormal];
  [button setImage:image forState:UIControlStateHighlighted];
  
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:NO] forState:UIControlStateNormal];
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:YES] forState:UIControlStateHighlighted];
  [button setBackgroundImage:[[self class] bgForBarButtonType:buttonType pressed:YES] forState:UIControlStateSelected];
  
  [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *navButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
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
  UIImage *backImage = [[UIImage imageNamed:@"BarBackButton.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
  UIImage *backHighlightedImage = [[UIImage imageNamed:@"BarBackButtonPressed.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];  
  [back setBackgroundImage:backImage forState:UIControlStateNormal];
  [back setBackgroundImage:backHighlightedImage forState:UIControlStateHighlighted];
  [back addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:back] autorelease];
  return backButton;
}

@end
