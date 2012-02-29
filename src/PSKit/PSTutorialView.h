//
//  PSTutorialView.h
//  PSKit
//
//  Created by Peter Shih on 10/6/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSTutorialViewDelegate <NSObject>

- (void)tutorialDidFinish:(id)sender;

@end

@interface PSTutorialView : PSView {
  UIScrollView *_scrollView;
  UIImage *_tutorialImage;
  id <PSTutorialViewDelegate> _delegate;
}

@property (nonatomic, assign) id <PSTutorialViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;
- (void)finish;

@end
