//
//  PSCell.m
//  PSKit
//
//  Created by Peter Shih on 2/25/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSCell.h"

@implementation PSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //    VLog(@"#%@", [self class]);
//        self.layer.shouldRasterize = YES;
//        self.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.isExpanded = NO;
    }
    return self;
}


- (void)prepareForReuse {
    [super prepareForReuse];
    [self.psImageView prepareForReuse];
    self.parentTableView = nil;
    self.indexPath = nil;
    self.isExpanded = NO;
    
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
    
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

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath expanded:(BOOL)expanded forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [[self class] rowHeightForObject:object atIndexPath:indexPath forInterfaceOrientation:interfaceOrientation];
}

+ (CGFloat)rowHeight {
    // subclass may implement this or rowHeightForObject
    return 0.0;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // subclass must implement, defaults to rowHeight
    return [[self class] rowHeight];
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    self.object = object;
    self.parentTableView = tableView;
    self.indexPath = indexPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
