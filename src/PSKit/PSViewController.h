//
//  PSViewController.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface PSViewController : UIViewController {
  UIScrollView *_activeScrollView; // subclasses should set this if they have a scrollView
}

// View Config
- (UIView *)backgroundView;
- (UIView *)navigationTitleView;

// Orientation
- (void)orientationChangedFromNotification:(NSNotification *)notification;

@end
