//
//  PSViewController.m
//  PSKit
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

@synthesize drawerController = _drawerController;
@synthesize navController = _navController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _activeScrollView = nil;
    VLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)dealloc
{
  VLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  VLog(@"Called by class: %@", [self class]);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  VLog(@"Called by class: %@", [self class]);
}

#pragma mark - View
//- (void)loadView {
//  UIView *view = [[UIView alloc] initWithFrame:APP_FRAME];
//  view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//  self.view = view;
//  [view release];
//}

- (void)viewDidLoad {
  [super viewDidLoad];
  VLog(@"Called by class: %@", [self class]);
  
  // Background
  if ([self respondsToSelector:@selector(baseBackgroundView)]) {
    UIView *bgView = [self baseBackgroundView];
    if (bgView) {
      [self.view insertSubview:bgView atIndex:0];
    }
  } else if ([self respondsToSelector:@selector(baseBackgroundColor)]) {
    self.view.backgroundColor = [self baseBackgroundColor];
  }
  
  // Set navigation title view
  if (self.title) {
    self.navigationItem.titleView = [self navigationTitleView];
  }
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  VLog(@"Called by class: %@", [self class]);
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  VLog(@"Called by class: %@", [self class]);
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  VLog(@"Called by class: %@", [self class]);
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  VLog(@"Called by class: %@", [self class]);
}

#pragma mark - View Config
- (UIView *)navigationTitleView {
  self.navigationItem.title = nil;
  UILabel *l = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.width - 160.0, self.navigationController.navigationBar.height)] autorelease];
  l.autoresizingMask = ~UIViewAutoresizingNone;
  l.text = [[self.title copy] autorelease];
  l.numberOfLines = 2;
  l.backgroundColor = [UIColor clearColor];
  [PSStyleSheet applyStyle:@"navigationTitleLabel" forLabel:l];
  
  return l;
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)orientationChangedFromNotification:(NSNotification *)notification {
  // may should implement
}

#pragma mark - Scroll State
- (void)updateScrollsToTop:(BOOL)isEnabled {
  if (_activeScrollView) {
    _activeScrollView.scrollsToTop = isEnabled;
  }
}

@end
