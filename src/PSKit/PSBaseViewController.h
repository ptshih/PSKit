//
//  PSBaseViewController.h
//  PSKit
//
//  Created by Peter Shih on 2/10/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"

@interface PSBaseViewController : PSViewController

/**
 requestQueue is a serial queue for loading a view controller's data source.
 Any remote requests should be added to this queue
 */
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic, assign) BOOL reloading;
@property (nonatomic, assign) BOOL isReload;

@end
