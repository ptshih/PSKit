//
//  UIButton+PSKit.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIButton (PSKit)

+ (UIButton *)buttonWithFrame:(CGRect)frame andStyle:(NSString *)style target:(id)target action:(SEL)action;
+ (UIButton *)buttonWithStyle:(NSString *)style;

@end
