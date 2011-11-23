//
//  PSViewController.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

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
- (void)loadView
{
  [super loadView];
  VLog(@"Called by class: %@", [self class]);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  VLog(@"Called by class: %@", [self class]);
  
  // Background
  UIView *bgView = [self backgroundView];
  if (bgView) {
    [self.view insertSubview:bgView atIndex:0];
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
- (UIView *)backgroundView {
  return nil;
}

- (UIView *)navigationTitleView {
  UIView *v = [[[UIView alloc] initWithFrame:self.navigationItem.titleView.bounds] autorelease];
  v.autoresizingMask = self.navigationItem.titleView.autoresizingMask;
  UILabel *l = [[[UILabel alloc] initWithFrame:v.bounds] autorelease];
  l.text = [[self.title copy] autorelease];
  self.navigationItem.title = nil;
  l.numberOfLines = 3;
  l.backgroundColor = [UIColor clearColor];
  [PSStyleSheet applyStyle:@"navigationTitleLabel" forLabel:l];
  [v addSubview:l];
  
  return v;
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
