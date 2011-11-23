//
//  PSCell.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 2/25/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCell.h"

@implementation PSCell

@synthesize isExpanded = _isExpanded;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    VLog(@"Called by class: %@", [self class]);
    
    _isExpanded = NO;
    self.opaque = YES;
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

- (void)dealloc {
  VLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _isExpanded = NO;
}

+ (NSString *)reuseIdentifier {
  return NSStringFromClass(self);
}

+ (PSCellType)cellType {
  return PSCellTypePlain;
}

+ (CGFloat)rowWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
    if (isDeviceIPad()) {
      return 768.0;
    } else {
      return 320.0;
    }
  } else {
    if (isDeviceIPad()) {
      return 1024.0;
    } else {
      return 480.0;
    }
  }
}

+ (CGFloat)rowHeightForObject:(id)object expanded:(BOOL)expanded forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return [[self class] rowHeightForObject:object forInterfaceOrientation:interfaceOrientation];
}

+ (CGFloat)rowHeight {
  return 60.0;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // subclass must implement
  return 0.0;
}

- (void)fillCellWithObject:(id)object {
  // Subclasses must implement
  [self fillCellWithObject:object shouldLoadImages:NO];
}

- (void)fillCellWithObject:(id)object shouldLoadImages:(BOOL)shouldLoadImages {
  // Subclasses must implement
}

- (void)setShouldAnimate:(NSNumber *)shouldAnimate {
  _cellShouldAnimate = [shouldAnimate boolValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

@end
