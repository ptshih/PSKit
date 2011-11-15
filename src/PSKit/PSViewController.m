//
//  PSViewController.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    VLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)dealloc
{
  VLog(@"Called by class: %@", [self class]);
  [super dealloc];
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
  self.view.autoresizingMask = ~UIViewAutoresizingNone;
  VLog(@"Called by class: %@", [self class]);
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

- (void)viewDidUnload
{
  [super viewDidUnload];
  VLog(@"Called by class: %@", [self class]);
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
