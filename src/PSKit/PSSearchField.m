//
//  PSSearchField.m
//  MealTime
//
//  Created by Peter Shih on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSSearchField.h"

#define MARGIN_X 10.0

@implementation PSSearchField

- (id)initWithFrame:(CGRect)frame style:(PSSearchFieldStyle)style {
  self = [super initWithFrame:frame];
  if (self) {
    _searchFieldStyle = style;
    if (style == PSSearchFieldStyleBlack) {
      self.background = [[UIImage imageNamed:@"PSKit.bundle/BackgroundSearchFieldBlack.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:15];
      self.font = [PSStyleSheet fontForStyle:@"searchField"];
      self.textColor = [PSStyleSheet textColorForStyle:@"searchField"];
    } else if (style == PSSearchFieldStyleWhite) {
      self.background = [[UIImage imageNamed:@"PSKit.bundle/BackgroundSearchFieldWhite.png"] stretchableImageWithLeftCapWidth:18 topCapHeight:15];
      self.font = [PSStyleSheet fontForStyle:@"searchField"];
      self.textColor = [PSStyleSheet textColorForStyle:@"searchField"];
    }
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.returnKeyType = UIReturnKeySearch;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.leftViewMode = UITextFieldViewModeAlways;
    UIImageView *mag = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PSKit.bundle/IconMagnifier.png"]] autorelease];
    mag.contentMode = UIViewContentModeCenter;
    self.leftView = mag;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame style:PSSearchFieldStyleBlack];
}

// This overrides the default image for a clear button
- (UIButton *)clearButton {
  UIButton *clearButton = [super clearButton];
  if (_searchFieldStyle == PSSearchFieldStyleBlack) {
    [clearButton setImage:[UIImage imageNamed:@"PSKit.bundle/IconClear.png"] forState:UIControlStateNormal];
  }
  return clearButton;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 36, 0);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 36, 0);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  return CGRectInset(bounds, 36, 0);
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.size.width - 20 - MARGIN_X, 0, 20, self.height);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
  return CGRectMake(MARGIN_X, 0, 20, self.height);
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
  return CGRectMake(bounds.size.width - 20 - MARGIN_X, 0, 20, self.height);
}

@end
