//
//  PSGridView.h
//  PSKit
//
//  Created by Peter Shih on 12/14/12.
//
//

#import <UIKit/UIKit.h>

#import "PSGridViewCell.h"
#import "PSGridViewTile.h"

@interface PSGridView : UIScrollView

@property (nonatomic, assign) UIViewController *parentViewController;

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)dictionary;

- (void)toggleTargetMode;
- (NSDictionary *)exportData;

@end