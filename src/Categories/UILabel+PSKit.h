//
//  UILabel+PSKit.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel (PSKit)

#pragma mark - Variable Sizing
+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode;

+ (UILabel *)labelWithText:(NSString *)text style:(NSString *)style;

@end
