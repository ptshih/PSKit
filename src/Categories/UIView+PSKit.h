//
//  UIView+PSKit.h
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (PSKit)

#pragma mark - Additions
@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic,readonly) CGFloat right;
@property(nonatomic,readonly) CGFloat bottom;

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

@property(nonatomic,readonly) CGFloat screenX;
@property(nonatomic,readonly) CGFloat screenY;

@property(nonatomic,readonly) CGFloat screenViewX;
@property(nonatomic,readonly) CGFloat screenViewY;

- (UIScrollView*)findFirstScrollView;

- (UIView*)firstViewOfClass:(Class)cls;

- (UIView*)firstParentOfClass:(Class)cls;

- (UIView*)findChildWithDescendant:(UIView*)descendant;

- (void)removeSubviews;

- (CAGradientLayer *)addGradientLayerWithFrame:(CGRect)frame colors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)flipViewForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
