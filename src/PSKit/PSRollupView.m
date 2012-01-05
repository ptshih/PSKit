//
//  PSRollupView.m
//  PSKit
//
//  Created by Peter Shih on 6/22/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSRollupView.h"
#import "PSCachedImageView.h"

#define MARGIN 5.0
#define PICTURE_SIZE 30.0

@implementation PSRollupView

@synthesize backgroundImage = _backgroundImage;
@synthesize pictureURLArray = _pictureURLArray;
@synthesize desiredHeight = _desiredHeight;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    _desiredHeight = 0.0;
    
#warning switch this to PSStyleSheet
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _headerLabel.backgroundColor = [UIColor clearColor];
    _headerLabel.textColor = [UIColor whiteColor];
    _headerLabel.numberOfLines = 0;
    _headerLabel.shadowColor = [UIColor blackColor];
    _headerLabel.shadowOffset = CGSizeMake(0, 1);
    
    _pictureScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _pictureScrollView.scrollsToTop = NO;
    _pictureScrollView.showsHorizontalScrollIndicator = NO;
    _pictureScrollView.showsVerticalScrollIndicator = NO;
    _pictureScrollView.bounces = YES;
    _pictureScrollView.alwaysBounceHorizontal = YES;
    
    _footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _footerLabel.backgroundColor = [UIColor clearColor];
    _footerLabel.textColor = [UIColor whiteColor];
    _footerLabel.numberOfLines = 1;
    _footerLabel.shadowColor = [UIColor blackColor];
    _footerLabel.shadowOffset = CGSizeMake(0, 1);
    
    // Background Image
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_backgroundView];
    
    [self addSubview:_headerLabel];
    [self addSubview:_footerLabel];
    [self addSubview:_pictureScrollView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN;
  CGFloat left = MARGIN;
  CGFloat textWidth = self.width - MARGIN * 2;
  CGSize desiredSize = CGSizeZero;
  
  // Header
  if ([_headerLabel.text length] > 0) {
    desiredSize = [UILabel sizeForText:_headerLabel.text width:textWidth font:_headerLabel.font numberOfLines:_headerLabel.numberOfLines lineBreakMode:_headerLabel.lineBreakMode];
    _headerLabel.width = desiredSize.width;
    _headerLabel.height = desiredSize.height;
    _headerLabel.top = top;
    _headerLabel.left = left;
    
    top = _headerLabel.bottom + MARGIN;
  }
  
  // Pictures
  if ([_pictureURLArray count] > 0) {
    // http://openradar.appspot.com/8045239
    CGRect scrollFrame = CGRectMake(left, top, textWidth, PICTURE_SIZE);
    if (!CGRectEqualToRect(scrollFrame, _pictureScrollView.frame)) {
      _pictureScrollView.frame = scrollFrame;
    } 
    top = _pictureScrollView.bottom + MARGIN;
  }
  
  // Footer
  if ([_footerLabel.text length] > 0) {
    desiredSize = [UILabel sizeForText:_footerLabel.text width:textWidth font:_footerLabel.font numberOfLines:_footerLabel.numberOfLines lineBreakMode:_footerLabel.lineBreakMode];
    _footerLabel.width = desiredSize.width;
    _footerLabel.height = desiredSize.height;
    _footerLabel.top = top;
    _footerLabel.left = left;
    
    top = _footerLabel.bottom + MARGIN;
  }
  
  // Extra padding at bottom
//  top += MARGIN;
  
  _desiredHeight = top;
  self.height = top;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
  [_backgroundImage autorelease];
  _backgroundImage = [backgroundImage retain];
  
  [_backgroundView setImage:_backgroundImage];
//  [self setNeedsLayout];
}

- (void)setHeaderText:(NSString *)headerText {
  _headerLabel.text = headerText;
  // resize
//  [self setNeedsLayout];
}

- (void)setFooterText:(NSString *)footerText {
  _footerLabel.text = footerText;
  
//  [self setNeedsLayout];
}

- (void)setPictureURLArray:(NSArray *)pictureURLArray {
  [_pictureURLArray autorelease];
  _pictureURLArray = [pictureURLArray retain];
  
  // Update pictureScrollView
  PSCachedImageView *profileImage = nil;
  int i = 0;
  for (NSString *pictureURLPath in _pictureURLArray) {
    profileImage = [[[PSCachedImageView alloc] initWithFrame:CGRectMake(0, 0, PICTURE_SIZE, PICTURE_SIZE)] autorelease];
    [profileImage loadImageWithURL:[NSURL URLWithString:pictureURLPath]];
    
    profileImage.left = (i * profileImage.width) + (i * MARGIN);
    [_pictureScrollView addSubview:profileImage];
    i++;
  }
  
  NSInteger numPictures = [pictureURLArray count];
  _pictureScrollView.contentSize = CGSizeMake(numPictures * PICTURE_SIZE + numPictures * MARGIN - MARGIN, _pictureScrollView.height);
  
//  [self setNeedsLayout];
}

- (void)dealloc {
  RELEASE_SAFELY(_backgroundView);
  RELEASE_SAFELY(_backgroundImage);
  RELEASE_SAFELY(_headerLabel);
  RELEASE_SAFELY(_footerLabel);
  RELEASE_SAFELY(_pictureScrollView);
  RELEASE_SAFELY(_pictureURLArray);
  [super dealloc];
}

@end
