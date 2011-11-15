//
//  UIBarButtonItem+SML.m
//  PhotoTime
//
//  Created by Peter Shih on 8/7/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "UIBarButtonItem+SML.h"
#import "PSStyleSheet.h"

@implementation UIBarButtonItem (SML)

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
  
  UIImage *bg = nil;
  UIImage *bgHighlighted = nil;
  switch (buttonType) {
    case BarButtonTypeNormal:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeBlue:
      bg = [[UIImage imageNamed:@"navbar_blue_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_blue_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeRed:
      bg = [[UIImage imageNamed:@"navbar_red_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_red_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeGreen:
      bg = [[UIImage imageNamed:@"navbar_green_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_green_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeSilver:
      bg = [[UIImage imageNamed:@"navbar_focus_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_focus_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeGray:
      bg = [[UIImage imageNamed:@"btn_bar_gray.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
      bgHighlighted = [[UIImage imageNamed:@"btn_bar_gray_highlighted.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:14];
      break;
    default:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
  }
  
  [button setBackgroundImage:bg forState:UIControlStateNormal];
  [button setBackgroundImage:bgHighlighted forState:UIControlStateHighlighted];
  [button setBackgroundImage:bgHighlighted forState:UIControlStateSelected];
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
  
  UIImage *bg = nil;
  UIImage *bgHighlighted = nil;
  switch (buttonType) {
    case BarButtonTypeNormal:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeBlue:
      bg = [[UIImage imageNamed:@"navbar_blue_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_blue_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeRed:
      bg = [[UIImage imageNamed:@"navbar_red_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_red_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeGreen:
      bg = [[UIImage imageNamed:@"navbar_green_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_green_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    case BarButtonTypeSilver:
      bg = [[UIImage imageNamed:@"navbar_focus_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_focus_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
    default:
      bg = [[UIImage imageNamed:@"navbar_normal_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      bgHighlighted = [[UIImage imageNamed:@"navbar_normal_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0];
      break;
  }
  
  [button setBackgroundImage:bg forState:UIControlStateNormal];
  [button setBackgroundImage:bgHighlighted forState:UIControlStateHighlighted];
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
  UIImage *backImage = [[UIImage imageNamed:@"navbar_back_button.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];
  UIImage *backHighlightedImage = [[UIImage imageNamed:@"navbar_back_highlighted_button.png"] stretchableImageWithLeftCapWidth:19 topCapHeight:0];  
  [back setBackgroundImage:backImage forState:UIControlStateNormal];
  [back setBackgroundImage:backHighlightedImage forState:UIControlStateHighlighted];
  [back addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:back] autorelease];
  return backButton;
}

@end
