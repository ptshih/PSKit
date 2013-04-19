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
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self.textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [PSStyleSheet applyStyle:@"cellPlaceholderLabel" forTextField:self.textField];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)textFieldChanged:(UITextField *)textField {
    [self.object setObject:textField.text forKey:@"value"];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.textField.text = nil;
    self.textField.enabled = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat left = margin().width;
    CGFloat top = 0.0;
    CGFloat width = self.contentView.width - margin().width * 2;
    
    self.textField.frame = CGRectMake(left, top, width, 44.0);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:dict atIndexPath:indexPath];
    
    NSString *placeholder = [dict objectForKey:@"placeholder"];
    self.textField.placeholder = placeholder;
    if ([dict objectForKey:@"value"]) {
        self.textField.text = [dict objectForKey:@"value"];
    }
    if ([dict objectForKey:@"enabled"] && [[dict objectForKey:@"enabled"] isEqualToString:@"false"]) {
        self.textField.enabled = NO;
    }
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return 44.0;
}

@end
