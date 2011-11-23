//
//  PSNullView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 4/9/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSNullView.h"

#define MARGIN_X 10.0

@interface PSNullView (Private)

- (void)didTapNullView:(UITapGestureRecognizer *)gr;

@end

@implementation PSNullView

@synthesize state = _state;
@synthesize loadingTitle = _loadingTitle;
@synthesize loadingSubtitle = _loadingSubtitle;
@synthesize emptyTitle = _emptyTitle;
@synthesize emptySubtitle = _emptySubtitle;
@synthesize errorTitle = _errorTitle;
@synthesize errorSubtitle = _errorSubtitle;
@synthesize loadingImage = _loadingImage;
@synthesize emptyImage = _emptyImage;
@synthesize errorImage = _errorImage;
@synthesize isFullScreen = _isFullScreen;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {    
    _isFullScreen = NO;
    
    _state = PSNullViewStateDisabled;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = UITextAlignmentCenter;
    _titleLabel.font = [PSStyleSheet fontForStyle:@"nullTitle"];
    _titleLabel.textColor = [PSStyleSheet textColorForStyle:@"nullTitle"];
    _titleLabel.shadowColor = [PSStyleSheet shadowColorForStyle:@"nullTitle"];
    _titleLabel.shadowOffset = [PSStyleSheet shadowOffsetForStyle:@"nullTitle"];
    
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleLabel.numberOfLines = 0;
    _subtitleLabel.backgroundColor = [UIColor clearColor];
    _subtitleLabel.textAlignment = UITextAlignmentCenter;
    _subtitleLabel.font = [PSStyleSheet fontForStyle:@"nullSubtitle"];
    _subtitleLabel.textColor = [PSStyleSheet textColorForStyle:@"nullSubtitle"];
    _subtitleLabel.shadowColor = [PSStyleSheet shadowColorForStyle:@"nullSubtitle"];
    _subtitleLabel.shadowOffset = [PSStyleSheet shadowOffsetForStyle:@"nullSubtitle"];
    
    _aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _aiv.hidesWhenStopped = YES;
    
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
    [self addSubview:_subtitleLabel];
    [self addSubview:_aiv];
    
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapNullView:)] autorelease];
    gr.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gr];
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_aiv);
  RELEASE_SAFELY(_imageView);
  RELEASE_SAFELY(_titleLabel);
  RELEASE_SAFELY(_subtitleLabel);
  
  RELEASE_SAFELY(_loadingTitle);
  RELEASE_SAFELY(_loadingSubtitle)
  RELEASE_SAFELY(_emptyTitle);
  RELEASE_SAFELY(_emptySubtitle);
  RELEASE_SAFELY(_errorTitle);
  RELEASE_SAFELY(_errorSubtitle);
  RELEASE_SAFELY(_loadingImage);
  RELEASE_SAFELY(_emptyImage);
  RELEASE_SAFELY(_errorImage);
  
  [super dealloc];
}

- (void)didTapNullView:(UITapGestureRecognizer *)gr {
  if (self.delegate && [self.delegate respondsToSelector:@selector(nullViewTapped:)] && self.state == PSNullViewStateError) {
    [self.delegate nullViewTapped:self];
  }
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  if (_isFullScreen && (self.state == PSNullViewStateEmpty || self.state == PSNullViewStateError)) {
    _imageView.hidden = NO;
    _imageView.top = 0;
    _imageView.left = 0;
  } else {
    CGFloat top = floorf(self.height / 2);
    
    if (_imageView.image && (self.state == PSNullViewStateEmpty || self.state == PSNullViewStateError)) {
      _imageView.hidden = NO;
      _imageView.left = floorf(self.width / 2) - floorf(_imageView.width / 2);
      _imageView.top = top - floorf(_imageView.height / 2) - 30;
      top = _imageView.bottom + 20;
    } else if (self.state == PSNullViewStateLoading) {
      _imageView.hidden = YES;
      _aiv.left = floorf(self.width / 2) - floorf(_aiv.width / 2);
      _aiv.top = top - floorf(_aiv.height / 2) - 30;
      top = _aiv.bottom + 10;
    } else {
      _imageView.hidden = YES;
      top -= 20;
    }
    
    _titleLabel.left = MARGIN_X;
    _titleLabel.width = self.width - MARGIN_X * 2;
    _titleLabel.top = top;
    top = _titleLabel.bottom;
    
    _subtitleLabel.left = MARGIN_X;
    _subtitleLabel.width = self.width - MARGIN_X * 2;
    _subtitleLabel.top = top; 
  }
}

#pragma mark - State
- (void)setState:(PSNullViewState)state
{
  _state = state;
  
  switch (state) {
    case PSNullViewStateDisabled:
      _titleLabel.text = nil;
      _subtitleLabel.text = nil;
      _imageView.image = nil;
      _imageView.hidden = YES;
      [_aiv stopAnimating];
      self.userInteractionEnabled = NO;
      break;
    case PSNullViewStateLoading:
      _titleLabel.text = _loadingTitle;
      _subtitleLabel.text = _loadingSubtitle;
      _imageView.image = _loadingImage;
      _imageView.hidden = NO;
      [_aiv startAnimating];
      self.userInteractionEnabled = YES;
      break;
    case PSNullViewStateEmpty:
      _titleLabel.text = _emptyTitle;
      _subtitleLabel.text = _emptySubtitle;
      _imageView.image = _emptyImage;
      _imageView.hidden = NO;
      [_aiv stopAnimating];
      self.userInteractionEnabled = YES;
      break;
    case PSNullViewStateError:
      _titleLabel.text = _errorTitle;
      _subtitleLabel.text = _errorSubtitle;
      _imageView.image = _errorImage;
      _imageView.hidden = NO;
      [_aiv stopAnimating];
      self.userInteractionEnabled = YES;
      break;
    default:
      _titleLabel.text = nil;
      _subtitleLabel.text = nil;
      _imageView.image = nil;
      _imageView.hidden = YES;
      [_aiv stopAnimating];
      self.userInteractionEnabled = NO;
      break;
  }
  [_titleLabel sizeToFit];
  [_subtitleLabel sizeToFit];
  [_imageView sizeToFit];
  [self layoutIfNeeded];
}

@end
