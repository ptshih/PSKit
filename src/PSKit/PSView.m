//
//  PSView.m
//  PSKit
//
//  Created by Peter Shih on 3/26/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSView.h"

@implementation PSView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
//      self.opaque = YES;
//      self.layer.shouldRasterize = YES;
//      self.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    VLog(@"#%@", [self class]);
  }
  return self;
}

- (void)dealloc {
//  VLog(@"#%@", [self class]);
  [super dealloc];
}

@end
