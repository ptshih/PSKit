//
//  PSOverlayImageView.m
//  MealTime
//
//  Created by Peter Shih on 9/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSOverlayImageView.h"

@implementation PSOverlayImageView

- (id)initWithImage:(UIImage *)image {
  self = [super initWithImage:image];
  if (self) {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromSuperview)] autorelease];
    gr.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gr];
  }
  
  return self;
}

//- (void)removeFromSuperview {
//  [super removeFromSuperview];
//}

@end
