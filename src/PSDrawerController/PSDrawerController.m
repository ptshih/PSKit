//
//  PSDrawerController.m
//  Rolodex
//
//  Created by Peter Shih on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSDrawerController.h"

#define DRAWER_WIDTH 260

@implementation PSDrawerController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _state = PSDrawerStateClosed;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slide:) name:kPSDrawerSlide object:nil];
  }
  return self;
}

- (void)viewDidUnload {
  RELEASE_SAFELY(_bottomViewController);
  RELEASE_SAFELY(_topViewController);
  [super viewDidUnload];
}

- (void)dealloc {
  RELEASE_SAFELY(_bottomViewController);
  RELEASE_SAFELY(_topViewController);
  [super dealloc];
}

#pragma mark - Config View Controllers
- (void)setViewControllers:(NSArray *)viewControllers {
  if ([viewControllers count] == 2) {
    UIViewController *bottomViewController = [viewControllers objectAtIndex:0];
    UIViewController *topViewController = [viewControllers objectAtIndex:1];
    
    // Check to see if the view controllers actually changed
    if (![_bottomViewController isEqual:bottomViewController]) {
      RELEASE_SAFELY(_bottomViewController);
      _bottomViewController = [bottomViewController retain];
      
      // Set Frame
      _bottomViewController.view.frame = self.view.bounds;
      _bottomViewController.view.width = DRAWER_WIDTH;
      
      [self.view insertSubview:_bottomViewController.view atIndex:0];
    }
    
    if (![_topViewController isEqual:topViewController]) {
      RELEASE_SAFELY(_topViewController);
      _topViewController = [topViewController retain];
      
      // Set Frame
      _topViewController.view.frame = self.view.bounds;
//      _topViewController.view.left = DRAWER_WIDTH;
      
      [self.view insertSubview:_topViewController.view atIndex:1];
    }
  }
}

#pragma mark - Slide Drawer
- (void)slide:(NSNotification *)notification {
  CGFloat left = 0;
  if (_state == PSDrawerStateClosed) {
    _state = PSDrawerStateOpen;
    left = DRAWER_WIDTH;
  } else if (_state == PSDrawerStateOpen) {
    _state = PSDrawerStateClosed;
    left = 0;
  }
  
  [UIView animateWithDuration:0.4 animations:^{
    _topViewController.view.left = left;
  }];
}

@end
