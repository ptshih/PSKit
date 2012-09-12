//
//  PSTextFieldCell.m
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

#import "PSTextFieldCell.h"

@interface PSTextFieldCell ()

@end

@implementation PSTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [PSStyleSheet applyStyle:@"leadDarkLabel" forLabel:self.textLabel];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        self.textField.adjustsFontSizeToFitWidth = YES;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [PSStyleSheet applyStyle:@"leadDarkField" forTextField:self.textField];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textField.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = margin().width;
    CGFloat top = 0.0;
    CGFloat width = self.contentView.width - margin().width * 2;
    CGFloat height = self.contentView.height;
    CGSize labelSize = CGSizeZero;
    
    labelSize = [self.textLabel sizeForLabelInWidth:width];
    self.textLabel.frame = CGRectMake(left, top, labelSize.width, height);
    
    left += MAX(labelSize.width, 100.0) + margin().width;
    width -= MAX(labelSize.width, 100.0) + margin().width;
    
    self.textField.frame = CGRectMake(left, top, width, height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *title = [dict objectForKey:@"title"];
    NSString *subtitle = [dict objectForKey:@"subtitle"];
    
    self.textLabel.text = title;
    self.textField.placeholder = subtitle;
}

+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return 44.0;
}

@end
