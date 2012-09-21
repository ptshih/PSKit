//
//  PSCardCell.h
//  Vip
//
//  Created by Peter Shih on 9/21/12.
//
//

#import "PSCell.h"

@interface PSCardCell : PSCell

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) NSString *headerText;

@end
