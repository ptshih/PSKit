//
//  PSNavigationBar.m
//  MealTime
//
//  Created by Peter Shih on 10/6/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSNavigationBar.h"

@implementation PSNavigationBar

- (void)drawRect:(CGRect)rect  {
  UIImage *image = [UIImage imageNamed:@"PSNavigationBar.bundle/BackgroundNavigationBar.png"];
  [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

@end
