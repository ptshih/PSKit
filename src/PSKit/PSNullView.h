//
//  PSNullView.h
//  PSKit
//
//  Created by Peter Shih on 4/9/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSNullViewDelegate <NSObject>

- (void)nullViewTapped:(id)sender;

@end

typedef enum {
  PSNullViewStateDisabled = -1,
  PSNullViewStateEmpty = 0,
  PSNullViewStateLoading = 1,
  PSNullViewStateError = 2
} PSNullViewState;

@interface PSNullView : PSView {
  PSNullViewState _state;
  
  // Internal
  UIActivityIndicatorView *_aiv;
  UIImageView *_imageView;
  UILabel *_titleLabel;
  UILabel *_subtitleLabel;
  
  // External
  NSString *_loadingTitle;
  NSString *_loadingSubtitle;
  NSString *_emptyTitle;
  NSString *_emptySubtitle;
  NSString *_errorTitle;
  NSString *_errorSubtitle;
  UIImage *_loadingImage;
  UIImage *_emptyImage;
  UIImage *_errorImage;
  
  BOOL _isFullScreen;
  id <PSNullViewDelegate> _delegate;
}

@property (nonatomic, assign) PSNullViewState state;
@property (nonatomic, retain) NSString *loadingTitle;
@property (nonatomic, retain) NSString *loadingSubtitle;
@property (nonatomic, retain) NSString *emptyTitle;
@property (nonatomic, retain) NSString *emptySubtitle;
@property (nonatomic, retain) NSString *errorTitle;
@property (nonatomic, retain) NSString *errorSubtitle;
@property (nonatomic, retain) UIImage *loadingImage;
@property (nonatomic, retain) UIImage *emptyImage;
@property (nonatomic, retain) UIImage *errorImage;
@property (nonatomic, assign) BOOL isFullScreen;
@property (nonatomic, assign) id <PSNullViewDelegate> delegate;

@end
