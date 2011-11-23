//
//  UIScreen+PSKit.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "UIScreen+PSKit.h"


@implementation UIScreen (PSKit)

+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view {
  UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *) view : [view window];
  return [view convertRect:[window convertRect:rect fromWindow:nil] fromView:nil];
}

@end
