//
//  PSImageCell.m
//  PSKit
//
//  Created by Peter Shih on 2/25/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSImageCell.h"

@implementation PSImageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _psImageView = [[PSCachedImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:_psImageView];
    
    // Override default text labels
    self.textLabel.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _psImageView.image = nil;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _psImageView.left = 0;
  _psImageView.top = 0;
  _psImageView.width = self.contentView.height;
  _psImageView.height = self.contentView.height;
  
  self.textLabel.left = _psImageView.right + MARGIN_X;
  self.textLabel.width = self.contentView.width - _psImageView.width - MARGIN_X * 2;
}

- (void)loadImage {
  [_psImageView loadImageAndDownload:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_psImageView);
  [super dealloc];
}

@end
