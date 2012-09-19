//
//  PSSubtitleCell.m
//  PSKit
//
//  Created by Peter Shih on 8/14/12.
//
//

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 8.0);
    } else {
        return CGSizeMake(8.0, 8.0);
    }
}

#import "PSSubtitleCell.h"

@implementation PSSubtitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [PSStyleSheet applyStyle:@"titleDarkLabel" forLabel:self.textLabel];
        
        self.subtitleLabel = [UILabel labelWithStyle:@"subtitleDarkLabel"];
        [self.contentView addSubview:self.subtitleLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.subtitleLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = margin().width;
    CGFloat top = margin().height;
    CGFloat width = self.contentView.width - margin().width * 2;
    CGSize labelSize = CGSizeZero;
    
    labelSize = [self.textLabel sizeForLabelInWidth:width];
    self.textLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.textLabel.bottom;

    if (self.subtitleLabel.text.length > 0) {
        labelSize = [self.subtitleLabel sizeForLabelInWidth:width];
        self.subtitleLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    }
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *title = [dict objectForKey:@"title"];
    NSString *subtitle = [dict objectForKey:@"subtitle"];
    
    self.textLabel.text = title;
    self.subtitleLabel.text = subtitle;
}


+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat minHeight = margin().height * 2;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - margin().width * 2;
    CGFloat height = 0.0;
    
    height += margin().height;
    
    // Labels
    NSString *title = [dict objectForKey:@"title"];
    NSString *subtitle = [dict objectForKey:@"subtitle"];
    
    height += [PSStyleSheet sizeForText:title width:width style:@"titleDarkLabel"].height;
    if (subtitle && subtitle.length > 0) {
        height += [PSStyleSheet sizeForText:subtitle width:width style:@"subtitleDarkLabel"].height;
    }
    
    height += margin().height;
    
    return MAX(minHeight, height);
}

@end
