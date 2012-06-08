//
//  UIView+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "UIView+PSKit.h"

@implementation UIView (PSKit)

#pragma mark - Additions
- (CGFloat)left {
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}

- (CGFloat)top {
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}

- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}

- (CGFloat)screenX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
    x += view.left;
  }
  return x;
}

- (CGFloat)screenY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;
    //    if ([view isKindOfClass:[UIScrollView class]]) {
    //      UIScrollView* scrollView = (UIScrollView*)view;
    //      y += scrollView.contentOffset.y;
    //    }
  }
  return y;
}

- (CGFloat)screenViewX {
  CGFloat x = 0;
  for (UIView* view = self; view; view = view.superview) {
    x += view.left;
    
    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      x -= scrollView.contentOffset.x;
    }
  }
  
  return x;
}

- (CGFloat)screenViewY {
  CGFloat y = 0;
  for (UIView* view = self; view; view = view.superview) {
    y += view.top;
    
    if ([view isKindOfClass:[UIScrollView class]]) {
      UIScrollView* scrollView = (UIScrollView*)view;
      y -= scrollView.contentOffset.y;
    }
  }
  return y;
}

- (UIScrollView*)findFirstScrollView {
  if ([self isKindOfClass:[UIScrollView class]])
    return (UIScrollView*)self;
  
  for (UIView* child in self.subviews) {
    UIScrollView* it = [child findFirstScrollView];
    if (it)
      return it;
  }
  
  return nil;
}

- (UIView*)firstViewOfClass:(Class)cls {
  if ([self isKindOfClass:cls])
    return self;
  
  for (UIView* child in self.subviews) {
    UIView* it = [child firstViewOfClass:cls];
    if (it)
      return it;
  }
  
  return nil;
}

- (UIView*)firstParentOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else if (self.superview) {
    return [self.superview firstParentOfClass:cls];
  } else {
    return nil;
  }
}

- (UIView*)findChildWithDescendant:(UIView*)descendant {
  for (UIView* view = descendant; view && view != self; view = view.superview) {
    if (view.superview == self) {
      return view;
    }
  }
  
  return nil;
}

- (void)removeSubviews {
  while (self.subviews.count) {
    UIView* child = self.subviews.lastObject;
    [child removeFromSuperview];
  }
}

#pragma mark - Gradient Layer
- (CAGradientLayer *)addGradientLayerWithFrame:(CGRect)frame colors:(NSArray *)colors locations:(NSArray *)locations startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
// Horizontal
//  [gradientLayer setStartPoint:CGPointMake(0.0, 0.5)];
//  [gradientLayer setEndPoint:CGPointMake(1.0, 0.5)];
  
  CAGradientLayer *gradient = [CAGradientLayer layer];
  gradient.frame = frame;
  gradient.colors = colors;
  gradient.locations = locations;
  gradient.startPoint = startPoint;
  gradient.endPoint = endPoint;
  [self.layer addSublayer:gradient];
  
  return gradient;
}

- (void)flipViewForInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle = 0.0;
//    CGPoint origin = CGPointZero;
    CGRect newFrame = self.window.bounds;
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI; 
            newFrame.size.height -= statusBarSize.height;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = - M_PI / 2.0f;
            newFrame.origin.x += statusBarSize.width;
            newFrame.size.width -= statusBarSize.width; 
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI / 2.0f;
            newFrame.size.width -= statusBarSize.width;
            break;
        default: // as UIInterfaceOrientationPortrait
            angle = 0.0;
            newFrame.origin.y += statusBarSize.height;
            newFrame.size.height -= statusBarSize.height;
            break;
    } 
    
    self.transform = CGAffineTransformMakeRotation(angle);
    self.frame = newFrame;
    
}

- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}

@end
