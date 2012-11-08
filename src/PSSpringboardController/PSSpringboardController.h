//
//  PSSpringboardController.h
//  PSKit
//
//  Created by Peter Shih on 7/12/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSSpringboardControllerDelegate;

@interface PSSpringboardController : UIViewController

@property (nonatomic, unsafe_unretained) id <PSSpringboardControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic, assign) NSInteger selectedIndex;

@end

@protocol PSSpringboardControllerDelegate <NSObject>

@optional

@end