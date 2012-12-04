//
//  PSTileViewCell.m
//  Lunchbox
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "PSTileViewCell.h"

@implementation PSTileViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)prepareForReuse {
}

- (void)tileView:(PSTileView *)tileView fillCellWithObject:(id)object atIndex:(NSInteger)index {
    self.tileView = tileView;
    self.object = object;
    self.index = index;
}

@end
