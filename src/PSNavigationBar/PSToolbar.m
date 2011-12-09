//
//  PSToolbar.m
//  OSnap
//
//  Created by Peter Shih on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSToolbar.h"

@implementation PSToolbar

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
    image = [UIImage imageNamed:@"PSNavigationBar.bundle/BackgroundToolbar.png"];
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
