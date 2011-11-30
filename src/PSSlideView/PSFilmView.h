//
//  PSFilmView.h
//  Rolodex
//
//  Created by Peter Shih on 11/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"
#import "PSSlideView.h"

typedef enum {
  PSFilmSlideDirectionUp = 0,
  PSFilmSlideDirectionDown = 1
} PSFilmSlideDirection;

@protocol PSFilmViewDelegate, PSFilmViewDataSource;

@interface PSFilmView : PSView <UIScrollViewDelegate> {
  NSMutableSet *_reusableSlides;
  PSSlideView *_activeSlide; // Just a pointer
  NSInteger _slideIndex;
  
  // Views
  UIView *_headerView;
  UIView *_footerView;
  
  id <PSFilmViewDelegate> _filmViewDelegate;
  id <PSFilmViewDataSource> _filmViewDataSource;
}

@property (nonatomic, assign) id <PSFilmViewDelegate> filmViewDelegate;
@property (nonatomic, assign) id <PSFilmViewDataSource> filmViewDataSource;

#pragma mark - Public Methods
- (void)reloadSlides;

#pragma mark - Transition Previous or Next
- (void)slideView:(PSSlideView *)slideView shouldSlideInDirection:(PSFilmSlideDirection)direction;

#pragma mark - Reusing Slide Views
- (id)dequeueReusableSlideView;
- (void)enqueueReusableSlideView:(PSSlideView *)slideView;

@end

@protocol PSFilmViewDelegate <NSObject>

@optional

@end

@protocol PSFilmViewDataSource <NSObject>

@required
- (NSInteger)numberOfSlidesInFilmView:(PSFilmView *)filmView;
- (PSSlideView *)filmView:(PSFilmView *)filmView slideAtIndex:(NSInteger)index;

@end