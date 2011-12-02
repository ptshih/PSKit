//
//  PSFilmView.m
//  Rolodex
//
//  Created by Peter Shih on 11/29/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "PSFilmView.h"

#define HF_HEIGHT 60.0

@interface PSFilmView (Private)

- (void)setupHeaderAndFooter;

@end

@implementation PSFilmView

@synthesize filmViewDelegate = _filmViewDelegate;
@synthesize filmViewDataSource = _filmViewDataSource;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _reusableSlides = [[NSMutableSet alloc] initWithCapacity:2];
    
    _slideIndex = 0;
    
    // Setup Header and Footer
    [self setupHeaderAndFooter];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_reusableSlides);
  
  // Views
  RELEASE_SAFELY(_headerView);
  RELEASE_SAFELY(_footerView);
  [super dealloc];
}

#pragma mark - View Setup
- (void)setupHeaderAndFooter {
  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HF_HEIGHT)];
  UILabel *h = [[[UILabel alloc] initWithFrame:_headerView.frame] autorelease];
  h.autoresizingMask = ~UIViewAutoresizingNone;
  h.text = @"Pull Down to Load Previous";
  [PSStyleSheet applyStyle:@"filmViewHeader" forLabel:h];
  [_headerView addSubview:h];
  
  _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, HF_HEIGHT)];
  UILabel *f = [[[UILabel alloc] initWithFrame:_footerView.frame] autorelease];
  f.autoresizingMask = ~UIViewAutoresizingNone;
  f.text = @"Pull Down to Load Next";
  [PSStyleSheet applyStyle:@"filmViewFooter" forLabel:f];
  [_footerView addSubview:f];
  
  [self addSubview:_headerView];
  [self addSubview:_footerView];
}

#pragma mark - Layout
- (void)layoutSubviews {
  [super layoutSubviews];
  
  _headerView.frame = CGRectMake(0, 0, self.width, HF_HEIGHT);
  _footerView.frame = CGRectMake(0, self.height - HF_HEIGHT, self.width, HF_HEIGHT);
}

#pragma mark - Public Methods
- (void)reloadSlides {
  // Find out how many slides are in the dataSource
  NSInteger numSlides = 0;
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(numberOfSlidesInFilmView:)]) {
    numSlides = [self.filmViewDataSource numberOfSlidesInFilmView:self];
  }
  
  // Unload any previous slides
  if (_activeSlide) {
    [self enqueueReusableSlideView:_activeSlide];
    [_activeSlide release];
    _activeSlide = nil;
  }
  
  // Reset slide index
  _slideIndex = 0;
  
  // Load the first slide (top)
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:slideAtIndex:)]) {
    _activeSlide = [self.filmViewDataSource filmView:self slideAtIndex:_slideIndex];
    // Calculate newSlide's height
    CGFloat newSlideHeight = [self.filmViewDataSource filmView:self heightForSlideAtIndex:_slideIndex];
    _activeSlide.slideContentView.height = fmaxf(newSlideHeight, self.height);
    [self addSubview:_activeSlide];
  }
}

#pragma mark - Transition Previous or Next
- (void)slideView:(PSSlideView *)slideView shouldSlideInDirection:(PSFilmSlideDirection)direction {
  PSSlideView *newSlide = nil;
  CGFloat slideToY = 0.0;
  CGFloat emptyHeight = 0.0;
  
  // Find out how many slides are in the dataSource
  NSInteger numSlides = 0;
  if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(numberOfSlidesInFilmView:)]) {
    numSlides = [self.filmViewDataSource numberOfSlidesInFilmView:self];
  }
  
  if (direction == PSFilmSlideDirectionUp) {
    if (_slideIndex == 0) return;
    _slideIndex--;
    
    // Calculate empty height
    emptyHeight = 0 - slideView.contentOffset.y;
    
    // Get the previous slide
    if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:slideAtIndex:)]) {
      newSlide = [self.filmViewDataSource filmView:self slideAtIndex:_slideIndex];
      newSlide.top = 0 - self.height;
      // Calculate newSlide's height
      CGFloat newSlideHeight = [self.filmViewDataSource filmView:self heightForSlideAtIndex:_slideIndex];
      newSlide.slideContentView.height = fmaxf(newSlideHeight, self.height);
      [self addSubview:newSlide];
      slideToY = 0 + self.height + emptyHeight;
      
      // NOT IMPLEMENTED
      // Because we are going upwards, we need to simulate sliding thru the entire content not just the frame
    }
  } else if (direction == PSFilmSlideDirectionDown) {
    if (_slideIndex == (numSlides - 1)) return;
    _slideIndex++;
    
    // Calculate empty height
    emptyHeight = (slideView.contentOffset.y + slideView.height) - slideView.contentSize.height;
    
    // Get the next slide
    if (self.filmViewDataSource && [self.filmViewDataSource respondsToSelector:@selector(filmView:slideAtIndex:)]) {
      newSlide = [self.filmViewDataSource filmView:self slideAtIndex:_slideIndex];
      newSlide.top = self.bottom;
      // Calculate newSlide's height
      CGFloat newSlideHeight = [self.filmViewDataSource filmView:self heightForSlideAtIndex:_slideIndex];
      newSlide.slideContentView.height = fmaxf(newSlideHeight, self.height);
      [self addSubview:newSlide];
      slideToY = 0 - self.height - emptyHeight;
    }
  }
  
  
  
  // Animate the current slide off the screen and the new slide onto the screen
  _headerView.hidden = YES;
  _footerView.hidden = YES;
  BOOL shouldShowVerticalScrollIndicator = _activeSlide.showsVerticalScrollIndicator;
  BOOL shouldShowHorizontalScrollIndicator = _activeSlide.showsHorizontalScrollIndicator;
  _activeSlide.showsVerticalScrollIndicator = NO;
  _activeSlide.showsHorizontalScrollIndicator = NO;
  [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
    _activeSlide.frame = CGRectMake(0, slideToY, _activeSlide.width, _activeSlide.height);
    newSlide.frame = CGRectMake(0, 0, newSlide.width, newSlide.height);
  } completion:^(BOOL finished){
    [self enqueueReusableSlideView:_activeSlide];
    _activeSlide = newSlide;
    _activeSlide.showsVerticalScrollIndicator = shouldShowVerticalScrollIndicator;
    _activeSlide.showsHorizontalScrollIndicator = shouldShowHorizontalScrollIndicator;
    _headerView.hidden = NO;
    _footerView.hidden = NO;
  }];
  
}

#pragma mark - Reusing Slide Views
- (id)dequeueReusableSlideView {
  PSSlideView *slideView = [_reusableSlides anyObject];
  if (slideView) {
    [slideView retain];
    [slideView prepareForReuse];
    [_reusableSlides removeObject:slideView];
    [slideView autorelease];
  } else {
//    slideView = [[[PSSlideView alloc] initWithFrame:self.bounds] autorelease];
//    slideView.delegate = self;
//    slideView.scrollsToTop = NO;
//    slideView.backgroundColor = [UIColor clearColor];
  }
  return slideView;
}

- (void)enqueueReusableSlideView:(PSSlideView *)slideView {
  [_reusableSlides addObject:slideView];
  [slideView removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  // Detect if either header or footer got triggered
  // Perform a slide
  PSSlideView *slideView = (PSSlideView *)scrollView;
  
  CGFloat visibleTop = scrollView.contentOffset.y;
  CGFloat visibleBottom = scrollView.contentOffset.y + scrollView.height;
  
//  NSLog(@"scroll: %@, top: %f, bottom: %f", NSStringFromCGPoint(scrollView.contentOffset), visibleTop, visibleBottom);
  
  UILabel *h = [_headerView.subviews firstObject];
  UILabel *f = [_footerView.subviews firstObject];
  
  BOOL headerShowing = (visibleTop + HF_HEIGHT) < 0;
  BOOL footerShowing = (visibleBottom - HF_HEIGHT) > scrollView.contentSize.height;
  
  if (headerShowing) {
    h.text = @"Release to Load Previous";
    slideView.state = PSSlideViewStateUp;
  } else if (!footerShowing) {
    h.text = @"Pull Down to Load Previous";
    slideView.state = PSSlideViewStateNormal;
  }
  
  if (footerShowing) {
    f.text = @"Release to Load Next";
    slideView.state = PSSlideViewStateDown;
  } else if (!headerShowing) {
    f.text = @"Pull Down to Load Next";
    slideView.state = PSSlideViewStateNormal;
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (decelerate) {
    PSSlideView *slideView = (PSSlideView *)scrollView;
    NSLog(@"Slide View State: %d", slideView.state);
    if (slideView.state == PSSlideViewStateDown) {
      [self slideView:slideView shouldSlideInDirection:PSFilmSlideDirectionDown];
    } else if (slideView.state == PSSlideViewStateUp) {
      [self slideView:slideView shouldSlideInDirection:PSFilmSlideDirectionUp];
    }
  }
}

@end
