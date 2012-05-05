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
@property(nonatomic, assign) CGFloat left;
@property(nonatomic, assign) CGFloat top;
@property(nonatomic, assign, readonly) CGFloat right;
@property(nonatomic, assign, readonly) CGFloat bottom;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;

@property(nonatomic, assign, readonly) CGFloat screenX;
@property(nonatomic, assign, readonly) CGFloat screenY;

@property(nonatomic, assign, readonly) CGFloat screenViewX;
@property(nonatomic, assign, readonly) CGFloat screenViewY;

- (UIScrollView*)findFirstScrollView;

- (UIView*)firstViewOfClass:(Class)cls;

- (UIView*)firstParentOfClass:(Class)cls;

- (UIView*)findChildWithDescendant:(UIView*)descendant;

- (void)removeSubviews;

- (CAGradientLayer *)addGradientLayerWithFrame:(CGRect)frame colors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint;

- (void)flipViewForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end
