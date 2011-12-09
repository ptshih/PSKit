//
//  PSSlideView.h
//  PSKit
//
//  Created by Peter Shih on 11/30/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSSlideView : UIScrollView {
  UIView *_slideContentView;
}

@property (nonatomic, retain) UIView *slideContentView;

- (void)prepareForReuse;

+ (CGFloat)heightForObject:(id)object;

@end
