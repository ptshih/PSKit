//
//  PSNewspaperViewController.h
//  Satsuma
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSNewspaperView.h"

@interface PSNewspaperViewController : PSBaseViewController <PSNewspaperViewDelegate, PSNewspaperViewDataSource>


@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PSNewspaperView *newspaperView;

@end
