//
//  UILabel+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "UILabel+PSKit.h"

@implementation UILabel (PSKit)

#pragma mark - Variable Sizing
- (CGSize)sizeForLabelInWidth:(CGFloat)width {
    return [UILabel sizeForText:self.text width:width font:self.font numberOfLines:self.numberOfLines lineBreakMode:self.lineBreakMode];
}

+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode {
  
  if (numberOfLines == 0) numberOfLines = INT_MAX;
  
  CGFloat lineHeight = [@"A" sizeWithFont:font].height;
  return [text sizeWithFont:font constrainedToSize:CGSizeMake(width, numberOfLines*lineHeight) lineBreakMode:lineBreakMode];
}

+ (UILabel *)labelWithText:(NSString *)text style:(NSString *)style {
  UILabel *l = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
  [PSStyleSheet applyStyle:style forLabel:l];
  l.text = text;
  return l;
}

@end
