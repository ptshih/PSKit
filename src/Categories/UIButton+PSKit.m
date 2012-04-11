//
//  UIButton+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "UIButton+PSKit.h"

@implementation UIButton (PSKit)

+ (UIButton *)buttonWithFrame:(CGRect)frame andStyle:(NSString *)style target:(id)target action:(SEL)action {
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  btn.frame = frame;
  
  if (style) {
      [PSStyleSheet applyStyle:style forButton:btn];
  }
  
  if (target && action) {
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  }
  
	return btn;
}

+ (UIButton *)buttonWithStyle:(NSString *)style {
  return [UIButton buttonWithFrame:CGRectZero andStyle:style target:nil action:nil];
}

@end
