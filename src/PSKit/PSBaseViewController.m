//
//  PSBaseViewController.m
//  PhotoTime
//
//  Created by Peter Shih on 2/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
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
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.autoresizingMask = ~UIViewAutoresizingNone;
  
  // NullView
  _nullView = [[PSNullView alloc] initWithFrame:self.view.bounds];
  _nullView.autoresizingMask = ~UIViewAutoresizingNone;
  [_nullView setState:PSNullViewStateDisabled];
  [self.view addSubview:_nullView];
  
  // Configure Empty View
  // Configure Loading View
  
  _viewHasLoadedOnce = YES;
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - PSNullViewDelegate
- (void)nullViewTapped:(id)sender {
  // When a nullView is tapped, reload the dataSource
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
  _dataDidError = NO;
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

@end