//
//  PSStarView.h
//  PSKit
//
//  Created by Peter Shih on 10/6/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSStarView : PSView {
  CGFloat _rating;
}

@property (nonatomic, assign) CGFloat rating;

- (id)initWithFrame:(CGRect)frame rating:(CGFloat)rating;

@end
