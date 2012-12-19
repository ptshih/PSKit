//
//  PSPageView.h
//  Grid
//
//  Created by Peter Shih on 12/19/12.
//
//

#import <UIKit/UIKit.h>

#import "PSGridViewCell.h"
#import "PSGridViewTile.h"

@interface PSPageView : UIScrollView

- (id)initWithFrame:(CGRect)frame dictionary:(NSDictionary *)dictionary;

- (UIImage *)screenshot;

@end
