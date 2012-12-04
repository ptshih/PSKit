//
//  PSTileViewController.h
//  Lunchbox
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "PSViewController.h"
#import "PSTileView.h"

@interface PSTileViewController : PSViewController <PSTileViewDelegate, PSTileViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PSTileView *tileView;

@end
