//
//  PSTextField.m
//  PSKit
//
//  Created by Peter Shih on 7/11/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSTextField.h"


@implementation PSTextField

- (id)initWithFrame:(CGRect)frame withInset:(CGSize)inset {
  _inset = inset;
  return [self initWithFrame:frame];
}

//// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, _inset.width ,_inset.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, _inset.width ,_inset.height);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, _inset.width , _inset.height);
}


@end
