//
//  PSCell.h
//  PSKit
//
//  Created by Peter Shih on 2/25/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PSCachedImageView.h"

enum {
  PSCellTypePlain = 0,
  PSCellTypeGrouped = 1
};
typedef uint32_t PSCellType;


@interface PSCell : UITableViewCell

@property (nonatomic, retain) PSCachedImageView *psImageView;
@property (nonatomic, assign) UITableView *parentTableView;
@property (nonatomic, copy) NSIndexPath *indexPath;
@property (nonatomic, assign) BOOL isExpanded;

/**
 Reusable Cell Identifier
 Subclasses do NOT need to implement this unless custom behavior is needed
 */
+ (NSString *)reuseIdentifier;

+ (PSCellType)cellType;
+ (CGFloat)rowWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 Used for static height cells
 Subclasses should implement or else defaults to 44.0
 */
+ (CGFloat)rowHeight;

/**
 Used for variable height cells
 Attempts to call layoutSubviews for the corresponding cell class
 With the object passed
 */
+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath expanded:(BOOL)expanded forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end
