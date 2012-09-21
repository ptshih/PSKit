//
//  PSCardCell.m
//  Vip
//
//  Created by Peter Shih on 9/21/12.
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

#import "PSCardCell.h"

@interface PSCardCell ()

@property (nonatomic, strong) UIImageView *shadowView;

@end

@implementation PSCardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryView = nil;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.cardView = [[UIView alloc] initWithFrame:CGRectZero];
        self.cardView.backgroundColor = CELL_BG_COLOR;
        [self.contentView addSubview:self.cardView];
        
        UIImage *shadowImage = [[UIImage imageNamed:@"Shadow"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
        self.shadowView = [[UIImageView alloc] initWithImage:shadowImage];
        [self.cardView addSubview:self.shadowView];
        
        // Header
        self.headerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.headerView.backgroundColor = FB_BLUE_COLOR;
        [self.cardView addSubview:self.headerView];
        
        self.headerLabel = [UILabel labelWithStyle:@"titleLightLabel"];
        [self.headerView addSubview:self.headerLabel];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.headerLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.cardView.frame = CGRectInset(self.contentView.bounds, margin().width, margin().height);
    self.shadowView.frame = UIEdgeInsetsInsetRect(self.cardView.bounds, UIEdgeInsetsMake(0, -1, -2, -1));
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
    self.headerLabel.text = self.headerText;
}

+ (CGFloat)rowWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [super rowWidthForInterfaceOrientation:interfaceOrientation] - margin().width * 2;
}

+ (CGFloat)rowHeightForObject:(NSDictionary *)dict atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return margin().height * 2;
}

@end
