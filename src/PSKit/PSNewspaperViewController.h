//
//  PSNewspaperViewController.h
//  PSKit
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"
#import "PSNewspaperView.h"

@interface PSNewspaperViewController : PSViewController <PSNewspaperViewDelegate, PSNewspaperViewDataSource>


@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) PSNewspaperView *newspaperView;

@end
