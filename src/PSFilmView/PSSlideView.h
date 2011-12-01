//
//  PSSlideView.h
//  Rolodex
//
//  Created by Peter Shih on 11/30/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
  PSSlideViewStateNormal = 0,
  PSSlideViewStateUp = 1,
  PSSlideViewStateDown = 2
} PSSlideViewState;

@interface PSSlideView : UIScrollView {
  UIView *_slideContentView;
  
  PSSlideViewState _state;
}

@property (nonatomic, retain) UIView *slideContentView;

@property (nonatomic, assign) PSSlideViewState state;

- (void)prepareForReuse;

@end
