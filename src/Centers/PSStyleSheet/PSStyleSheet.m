//
//  PSStyleSheet.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 8/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSStyleSheet.h"
#import "UIColor+SML.h"

static NSDictionary *_styles = nil;

@implementation PSStyleSheet

+ (void)initialize {
  NSString *styleSheetPath = [[NSBundle mainBundle] pathForResource:@"PSStyleSheet" ofType:@"plist"];
  assert(styleSheetPath != nil);
  
  NSDictionary *styleSheetDict = [NSDictionary dictionaryWithContentsOfFile:styleSheetPath];
  assert(styleSheetDict != nil);
  _styles = [styleSheetDict retain];
}

+ (void)setStyleSheet:(NSString *)styleSheet {
  if (_styles) [_styles release], _styles = nil;

  NSString *styleSheetPath = [[NSBundle mainBundle] pathForResource:styleSheet ofType:@"plist"];
  assert(styleSheetPath != nil);
  
  NSDictionary *styleSheetDict = [NSDictionary dictionaryWithContentsOfFile:styleSheetPath];
  assert(styleSheetDict != nil);
  _styles = [styleSheetDict retain];
}

#pragma mark - Fonts
+ (UIFont *)fontForStyle:(NSString *)style {
  UIFont *font = nil;
  font = [UIFont fontWithName:[[_styles objectForKey:style] objectForKey:@"fontName"] size:[[[_styles objectForKey:style] objectForKey:@"fontSize"] integerValue]];
  return font;
}

#pragma mark - Colors
+ (UIColor *)textColorForStyle:(NSString *)style {
  UIColor *color = nil;
  color = [UIColor colorWithHexString:[[_styles objectForKey:style] objectForKey:@"textColor"]];
  return color;
}

+ (UIColor *)shadowColorForStyle:(NSString *)style {
  UIColor *color = nil;
  color = [UIColor colorWithHexString:[[_styles objectForKey:style] objectForKey:@"shadowColor"]];
  return color;
}

#pragma mark - Offsets
+ (CGSize)shadowOffsetForStyle:(NSString *)style {
  CGSize offset = CGSizeZero;
  offset = CGSizeFromString([[_styles objectForKey:style] objectForKey:@"shadowOffset"]);
  return offset;
}

@end
