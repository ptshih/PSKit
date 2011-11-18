//
//  PSBaseViewController.m
//  PhotoTime
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSBaseViewController.h"

@interface PSBaseViewController (Private)

@end

@implementation PSBaseViewController

@synthesize viewHasLoadedOnce = _viewHasLoadedOnce;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _reloading = NO;
    _activeScrollView = nil;
    _dataDidError = NO;
    _viewHasLoadedOnce = NO;
  }
  return self;
}

- (void)viewDidUnload {
  RELEASE_SAFELY(_nullView);
  [super viewDidUnload];
}

- (void)dealloc {
  RELEASE_SAFELY(_nullView);
  [super dealloc];
}

#pragma mark - View
- (void)loadView {
  [super loadView];
  
  self.view.autoresizingMask = ~UIViewAutoresizingNone;
  
  // Background
  UIView *bgView = [self backgroundView];
  if (bgView) {
    [self.view addSubview:bgView];
  }
  
  // NullView
  _nullView = [[PSNullView alloc] initWithFrame:self.view.bounds];
  _nullView.autoresizingMask = ~UIViewAutoresizingNone;
  [_nullView setState:PSNullViewStateDisabled];
  [self.view addSubview:_nullView];
  
  // Configure Empty View
  // Configure Loading View
  
  // Setup Nav Bar
  UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.width - 160, self.navigationController.navigationBar.height)];
//  navTitleView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  _navTitleLabel = [[UILabel alloc] initWithFrame:navTitleView.bounds];
  _navTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  _navTitleLabel.textAlignment = UITextAlignmentCenter;
  _navTitleLabel.numberOfLines = 3;
  _navTitleLabel.text = self.title;
  _navTitleLabel.font = [PSStyleSheet fontForStyle:@"navigationTitle"];
  _navTitleLabel.textColor = [PSStyleSheet textColorForStyle:@"navigationTitle"];
  _navTitleLabel.shadowColor = [PSStyleSheet shadowColorForStyle:@"navigationTitle"];
  _navTitleLabel.shadowOffset = CGSizeMake(0, 1);
  _navTitleLabel.backgroundColor = [UIColor clearColor];
  [navTitleView addSubview:_navTitleLabel];
  
  self.navigationItem.titleView = navTitleView;
  [navTitleView release];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _viewHasLoadedOnce = YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
//  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:kApplicationResumed object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
//  [[NSNotificationCenter defaultCenter] removeObserver:self name:kApplicationResumed object:nil];
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PSNullViewDelegate
- (void)nullViewTapped:(id)sender {
  [self reloadDataSource];
}

#pragma mark - PSStateMachine
- (BOOL)dataIsAvailable {
  return NO;
}

- (BOOL)dataIsLoading {
  return _reloading;
}

- (BOOL)dataDidError {
  return _dataDidError;
}

// DataSource
- (void)setupDataSource {
  
}

- (void)reloadDataSource {
  
}

- (void)restoreDataSource {
  
}

- (void)loadDataSource {
  _reloading = YES;
  _dataDidError = NO;
  [self updateState];
}

- (void)dataSourceDidLoad {
  _reloading = NO;
  [self updateState];
}

- (void)dataSourceDidLoadMore {
  _reloading = NO;
  [self updateState];
}

- (void)dataSourceDidError {
  _reloading = NO;
  _dataDidError = YES;
  [self updateState];
}

- (void)updateState {
  if ([self dataIsAvailable]) {
    // We have data to display
    [self.view sendSubviewToBack:_nullView];
    _nullView.state = PSNullViewStateDisabled;
  } else {
    // We don't have data available to display
    [self.view bringSubviewToFront:_nullView];
    if ([self dataIsLoading]) {
      // We are loading for the first time
      _nullView.state = PSNullViewStateLoading;
    } else {
      if ([self dataDidError]) {
        // There was a dataSource error, show the error screen
        _nullView.state = PSNullViewStateError;
      } else {
        // We have no data to display, show the empty screen
        _nullView.state = PSNullViewStateEmpty;
      }
    }
  }
}

- (void)updateScrollsToTop:(BOOL)isEnabled {
  if (_activeScrollView) {
    _activeScrollView.scrollsToTop = isEnabled;
  }
}



@end