//
//  PSZoomView.h
//  OSnap
//
//  Created by Peter Shih on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface PSZoomView : PSView {
  UIView *_backgroundView;
  UIImageView *_zoomedView;
  CGRect _originalRect;
  BOOL _shouldRotate;
}

- (id)initWithImage:(UIImage *)image contentMode:(UIViewContentMode)contentMode;
- (void)showInRect:(CGRect)rect;

- (void)loadFullResolutionWithURL:(NSURL *)url;

@end
