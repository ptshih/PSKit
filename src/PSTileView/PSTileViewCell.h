//
//  PSTileViewCell.h
//  Lunchbox
//
//  Created by Peter Shih on 12/3/12.
//
//

#import <UIKit/UIKit.h>

@class PSTileView;

@interface PSTileViewCell : UIView

@property (nonatomic, strong) id object;
@property (nonatomic, weak) PSTileView *tileView;
@property (nonatomic, assign) NSInteger index;

- (void)prepareForReuse;

- (void)tileView:(PSTileView *)tileView fillCellWithObject:(id)object atIndex:(NSInteger)index;

@end
