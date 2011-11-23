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

/**
 Used to configure the view right after it is loaded
 */
- (UIView *)backgroundView;
- (UIView *)navigationTitleView;

/**
 Used to update the view when the orientation changes
 */
- (void)orientationChangedFromNotification:(NSNotification *)notification;

/**
 Used to update the currently active scrollview (for scrollsToTop fix)
 */
- (void)updateScrollsToTop:(BOOL)isEnabled;

@end
