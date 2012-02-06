//
//  PSDrawerController.m
//  PSKit
//
//  Created by Peter Shih on 11/22/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

/*
 Copyright (C) 2011 Peter Shih. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "PSDrawerController.h"
#import "PSViewController.h"

#define DRAWER_GAP 60.0

@implementation PSDrawerController

@synthesize
state = _state,
rootViewController = _rootViewController,
leftViewController = _leftViewController,
rightViewController = _rightViewController;

#pragma mark - Init
+ (id)sharedDrawer {
    static id sharedDrawer;
    if (!sharedDrawer) {
        sharedDrawer = [[self alloc] initWithNibName:nil bundle:nil];
    }
    return sharedDrawer;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        if (!rootViewController) return nil;
        
        self.rootViewController = rootViewController;
        self.leftViewController = leftViewController;
        self.rightViewController = rightViewController;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set default state variables
        _state = PSDrawerStateClosed;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {  
    RELEASE_SAFELY(_rootViewController);
    RELEASE_SAFELY(_leftViewController);
    RELEASE_SAFELY(_rightViewController);
    [super dealloc];
}

#pragma mark - View
//- (void)loadView {
//    self.view = self.rootViewController.view;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootViewController.view.frame = self.view.bounds;
    [self.view addSubview:self.rootViewController.view];
}

- (void)replaceRootViewControllerWithViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.view.frame = self.rootViewController.view.frame;
    self.rootViewController = viewController;
    
    switch (self.state) {
        case PSDrawerStateClosed:
            break;
            case PSDrawerStateOpenLeft:
            [self hideFromLeft];
            break;
        case PSDrawerStateOpenRight:
            [self hideFromRight];
            break;
        default:
            break;
    }
    
    // Prepare view frames
//    CGRect offscreenFrame = CGRectZero;
//    offscreenFrame = self.view.bounds;
//    offscreenFrame.origin.x = CGRectGetMaxX(offscreenFrame);
//    viewController.view.frame = offscreenFrame;
    
//    UIViewAnimationOptions animationOptions = UIViewAnimationCurveEaseInOut;
//    NSTimeInterval animationDuration = animated ? 0.3 : 0.0;
//    [self transitionFromViewController:self.rootViewController toViewController:viewController duration:animationDuration options:animationOptions animations:^{
//        // Slide it closed
//        viewController.view.frame = self.view.bounds;
//    } completion:^(BOOL finished) {
//        [self.rootViewController removeFromParentViewController];
//        self.rootViewController = viewController;
//    }];
}

#pragma mark - Slide Drawer
- (void)slideFromLeft {
    [self slideWithPosition:PSDrawerPositionLeft hidden:NO animated:YES];
}

- (void)slideFromRight {
    [self slideWithPosition:PSDrawerPositionRight hidden:NO animated:YES];
}

- (void)hideFromLeft {
    [self slideWithPosition:PSDrawerPositionLeft hidden:YES animated:YES];
}

- (void)hideFromRight {
    [self slideWithPosition:PSDrawerPositionRight hidden:YES animated:YES];
}

- (void)slideWithPosition:(PSDrawerPosition)position hidden:(BOOL)hidden animated:(BOOL)animated {
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionCurveEaseOut;
    NSTimeInterval animationDuration = animated ? 0.4 : 0.0;
    CGFloat left = 0.0;
    BOOL opened = !(_state == PSDrawerStateClosed);
    
    left = opened ? 0.0 : (hidden ? self.view.width : self.view.width - DRAWER_GAP);
    
    if (opened) {
        if (position == PSDrawerPositionLeft) {
            [_leftViewController viewWillDisappear:animated];
        } else if (position == PSDrawerPositionRight) {
            [_rightViewController viewWillDisappear:animated];
        }
    } else {
        if (position == PSDrawerPositionLeft) {
            left *= 1;
            [_leftViewController viewWillAppear:animated];
            _leftViewController.view.hidden = NO;
        } else if (position == PSDrawerPositionRight) {
            left *= -1;
            [_rightViewController viewWillAppear:animated];
            _rightViewController.view.hidden = NO;
        }
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:animationOptions
                     animations:^{
                         _rootViewController.view.left = left;
                     }
                     completion:^(BOOL finished){
                         if (!opened) {
                             if (position == PSDrawerPositionLeft) {
                                 [_leftViewController viewDidAppear:animated];
                                 _state = PSDrawerStateOpenLeft;
                             } else if (position == PSDrawerPositionRight) {
                                 [_rightViewController viewDidAppear:animated];
                                 _state = PSDrawerStateOpenRight;
                             }
                         } else {
                             if (position == PSDrawerPositionLeft) {
                                 [_leftViewController viewDidDisappear:animated];
                                 _leftViewController.view.hidden = YES;
                             } else if (position == PSDrawerPositionRight) {
                                 [_rightViewController viewDidAppear:animated];
                                 _rightViewController.view.hidden = YES;
                             }
                             _state = PSDrawerStateClosed;
                         }
                     }];
}

@end
