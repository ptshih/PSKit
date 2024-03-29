//
//  PSCurtainController.h
//  PSKit
//
//  Created by Peter Shih on 7/12/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PSCurtainControllerDelegate;

@interface PSCurtainController : UIViewController

@property (nonatomic, unsafe_unretained) id <PSCurtainControllerDelegate> delegate;

- (void)toggleFromView:(UIView *)view belowView:(UIView *)belowView animated:(BOOL)animated;

- (void)showFromView:(UIView *)view belowView:(UIView *)belowView animated:(BOOL)animated;

- (void)showCurtain:(BOOL)animated;
- (void)showCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock;
- (void)hideCurtain:(BOOL)animated;
- (void)hideCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock;

@end

@protocol PSCurtainControllerDelegate <NSObject>

@optional
- (NSInteger)numberOfRowsInCurtainController:(PSCurtainController *)curtainController;
- (id)curtainController:(PSCurtainController *)curtainController rowAtIndex:(NSInteger)index;
- (void)curtainController:(PSCurtainController *)curtainController selectedRowAtIndex:(NSInteger)index;

@end