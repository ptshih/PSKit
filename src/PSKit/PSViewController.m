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
@synthesize psNavigationController = _psNavigationController;
@synthesize headerView = _headerView;
@synthesize contentView = _contentView;
@synthesize footerView = _footerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _activeScrollView = nil;
//    VLog(@"#%@", [self class]);
  }
  return self;
}

- (void)dealloc
{
//  VLog(@"#%@", [self class]);
  RELEASE_SAFELY(_headerView);
  RELEASE_SAFELY(_contentView);
  RELEASE_SAFELY(_footerView);
  [super dealloc];
}

- (void)viewDidUnload
{
  VLog(@"#%@", [self class]);
  RELEASE_SAFELY(_headerView);
  RELEASE_SAFELY(_contentView);
  RELEASE_SAFELY(_footerView);
  [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
  VLog(@"#%@", [self class]);
  [super didReceiveMemoryWarning];
}

#pragma mark - Setters/Getters
- (void)setHeaderView:(UIView *)headerView {
  [_headerView autorelease];
  [_headerView removeFromSuperview];
  _headerView = [headerView retain];
  
  // Add to view, adjust contentView
  _headerView.left = 0.0;
  _headerView.top = 0.0;
  _contentView.top = _headerView.bottom;
  _contentView.height -= _headerView.height;
  [self.view addSubview:_headerView];
}

- (void)setFooterView:(UIView *)footerView {
  [_footerView autorelease];
  [_footerView removeFromSuperview];
  _footerView = [footerView retain];
  
  // Add to view, adjust contentView
  _footerView.left = 0.0;
  _footerView.top = self.view.bottom - _footerView.height;
  _contentView.height -= _footerView.height;
  [self.view addSubview:_footerView];
}

#pragma mark - View
- (void)loadView {
  UIView *view = [[UIView alloc] initWithFrame:APP_FRAME];
  view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.view = view;
  [view release];
  
  _contentView = [[UIView alloc] initWithFrame:self.view.bounds];
  _contentView.autoresizingMask = self.view.autoresizingMask;
  [self.view addSubview:_contentView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  VLog(@"#%@", [self class]);
  
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
  VLog(@"#%@", [self class]);
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  VLog(@"#%@", [self class]);
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  VLog(@"#%@", [self class]);
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  VLog(@"#%@", [self class]);
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

- (PSDrawerController *)drawerController {
  if (_psNavigationController) {
    return _psNavigationController.drawerController;
  } else {
    return _drawerController;
  }
}

- (void)animatedBack {
  if (self.psNavigationController) {
    [self.psNavigationController popViewControllerAnimated:YES];
  }
}

@end
