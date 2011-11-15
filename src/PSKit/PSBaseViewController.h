//
//  PSBaseViewController.h
//  PhotoTime
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"
#import "PSStateMachine.h"
#import "PSDataCenterDelegate.h"
#import "PSNullView.h"

@interface PSBaseViewController : PSViewController <PSStateMachine, PSDataCenterDelegate, PSNullViewDelegate> {
  UIScrollView *_activeScrollView; // subclasses should set this if they have a scrollView
  UILabel *_navTitleLabel;
  PSNullView *_nullView;
  
  BOOL _reloading;
  BOOL _dataDidError;
  BOOL _viewHasLoadedOnce;
}

@property (nonatomic, retain) UILabel *navTitleLabel;
@property (nonatomic, assign) BOOL viewHasLoadedOnce;

// View Config
- (UIView *)backgroundView;

// Orientation
- (void)orientationChangedFromNotification:(NSNotification *)notification;

@end
