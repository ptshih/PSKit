//
//  PSTutorialView.m
//  PSKit
//
//  Created by Peter Shih on 10/6/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSTutorialView.h"

@implementation PSTutorialView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor darkGrayColor];
    
    UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)] autorelease];
    [bar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    bar.barStyle = UIBarStyleBlackOpaque;
    
    UINavigationItem *navItem = [[[UINavigationItem alloc] init] autorelease];
    bar.items = [NSArray arrayWithObject:navItem];
    navItem.title = @"Tutorial Title";
    
    [self addSubview:bar];
    
    CGFloat top = 0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height - 44)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.autoresizingMask = self.autoresizingMask;
    _scrollView.scrollsToTop = NO;
    _scrollView.pagingEnabled = NO;
    _scrollView.scrollEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    // Image
    _tutorialImage = [image retain];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:_tutorialImage] autorelease];
    [_scrollView addSubview:imageView];
    
    top += imageView.height;
    
    // Done Button
    UIButton *doneButton = [UIButton buttonWithFrame:CGRectMake(20, top, _scrollView.width - 40, 44) andStyle:@"text" target:self action:@selector(finish)];
    [doneButton setBackgroundImage:[UIImage stretchableImageNamed:@"PSKit.bundle/BarBlueButton.png" withLeftCapWidth:16 topCapWidth:22] forState:UIControlStateNormal];
    [doneButton setTitle:@"Get Started" forState:UIControlStateNormal];
    [_scrollView addSubview:doneButton];
    
    top += doneButton.height + 10;
    
    _scrollView.contentSize = CGSizeMake(_scrollView.width, top);
    
    [self addSubview:_scrollView];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_tutorialImage);
  RELEASE_SAFELY(_scrollView);
  [super dealloc];
}

- (void)layoutSubviews {
  [super layoutSubviews];

}

- (void)finish {
  if (self.delegate && [self.delegate respondsToSelector:@selector(tutorialDidFinish:)]) {
    [self.delegate tutorialDidFinish:self];
  }
}

@end
