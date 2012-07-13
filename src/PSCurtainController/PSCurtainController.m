//
//  PSCurtainController.m
//  Appstand
//
//  Created by Peter Shih on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCurtainController.h"

@interface PSCurtainController ()

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *curtainView;

@end

@implementation PSCurtainController

@synthesize
delegate = _delegate;

@synthesize
overlayView = _overlayView,
curtainView = _curtainView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Overlay
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.overlayView.exclusiveTouch = YES;
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0.0;
    [self.view addSubview:self.overlayView];
    
    // Setup Curtain
    self.curtainView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, 0, 44.0, 0))];
    self.curtainView.backgroundColor = [UIColor whiteColor];
    self.curtainView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.curtainView.top -= self.curtainView.height;
    [self.view addSubview:self.curtainView];
    
    [self.curtainView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(test:)]];
    
    [self.overlayView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCurtainFromTap:)]];
    
}
#pragma mark - Curtain

- (void)toggleCurtain:(BOOL)animated {
    if (self.curtainView.top == 0.0) {
        [self hideCurtain:animated];
    } else {
        [self showCurtain:animated];
    }
}

- (void)showCurtain:(BOOL)animated {
    [self showCurtain:animated completionBlock:NULL];
}

- (void)showCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    [self.view bringSubviewToFront:self.overlayView];
    [self.view bringSubviewToFront:self.curtainView];
    
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseOut;
    NSTimeInterval animationDuration = animated ? 0.4 : 0.0;
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.curtainView.top = 0.0;
        self.overlayView.alpha = 0.75;
    } completion:^(BOOL finished){
        if (completionBlock) {
            completionBlock();
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

- (void)hideCurtain:(BOOL)animated {
    [self hideCurtain:animated completionBlock:NULL];
}

- (void)hideCurtain:(BOOL)animated completionBlock:(void (^)(void))completionBlock {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseOut;
    NSTimeInterval animationDuration = animated ? 0.4 : 0.0;
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.overlayView.alpha = 0.0;
        self.curtainView.top = -self.curtainView.height;
    } completion:^(BOOL finished){
        if (completionBlock) {
            completionBlock();
        }
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];
}

#pragma mark - GR

- (void)hideCurtainFromTap:(UITapGestureRecognizer *)gr {
    [self hideCurtain:YES];
}

- (void)test:(UITapGestureRecognizer *)gr {
    [self hideCurtain:YES completionBlock:^{
//        int i = arc4random() % 2;
//        self.selectedViewController = [self.viewControllers objectAtIndex:i];
    }];
}


@end
