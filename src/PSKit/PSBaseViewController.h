//
//  PSBaseViewController.h
//  PSKit
//
//  Created by Peter Shih on 2/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"

@interface PSBaseViewController : PSViewController <PSErrorViewDelegate>

@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) BOOL hasLoadedOnce;

@end
