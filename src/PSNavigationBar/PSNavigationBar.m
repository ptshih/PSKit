//
//  PSNavigationBar.m
//  MealTime
//
//  Created by Peter Shih on 10/6/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSNavigationBar.h"

@implementation PSNavigationBar

@synthesize backgroundImage = _backgroundImage;

- (void)dealloc {
  RELEASE_SAFELY(_backgroundImage);
  [super dealloc];
}

- (void)drawRect:(CGRect)rect  {
  UIImage *image = nil;
  if (_backgroundImage) {
    image = _backgroundImage;
  } else {
    image = [UIImage imageNamed:@"PSNavigationBar.bundle/BackgroundNavigationBar.png"];
  }
  
  [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
  
//  NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"BackgroundNavigationBar" ofType:@"png"];
//  if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
//    image = [UIImage imageWithContentsOfFile:imagePath];
//  } else {
//    image = [UIImage imageNamed:@"PSNavigationBar.bundle/BackgroundNavigationBar"];
//  }
}

@end
