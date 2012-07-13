//
//  PSCurtainController.h
//  Appstand
//
//  Created by Peter Shih on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSCurtainControllerDelegate;

@interface PSCurtainController : UIViewController

@property (nonatomic, unsafe_unretained) id <PSCurtainControllerDelegate> delegate;

- (void)toggleCurtain:(BOOL)animated;

- (void)showCurtain:(BOOL)animated;
- (void)showCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock;
- (void)hideCurtain:(BOOL)animated;
- (void)hideCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

@end

@protocol PSCurtainControllerDelegate <NSObject>

@optional

@end