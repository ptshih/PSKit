//
//  UILabel+PSKit.h
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UILabel (PSKit)

#pragma mark - Variable Sizing
- (CGSize)sizeForLabelInWidth:(CGFloat)width;
+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode;

+ (UILabel *)labelWithText:(NSString *)text style:(NSString *)style;

@end
