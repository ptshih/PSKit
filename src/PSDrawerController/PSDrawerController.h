//
//  PSDrawerController.h
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

#import <UIKit/UIKit.h>
#import "PSViewController.h"

#define kPSDrawerSlide @"PSDrawerSlide"
#define kPSDrawerHide @"PSDrawerHide"

/**
 Currently unused...
 */
typedef enum {
  PSDrawerStateClosed = 1,
  PSDrawerStateOpen = 2
} PSDrawerState;

@interface PSDrawerController : PSViewController {
//  PSDrawerState _state;
  BOOL _opened;
  BOOL _hidden;
  
  UIViewController *_bottomViewController;
  UIViewController *_topViewController;
}

#pragma mark - Config View Controllers
/**
 The array in this property must contain exactly two view controllers. The first view controller is the bottom (navigation) controller. The second view controller is the top (root) controller.
 */
- (void)setViewControllers:(NSArray *)viewControllers;

#pragma mark - Slide Drawer
/**
 This method slides the top controller partially off the screen.
 */
- (void)slide;

#pragma mark - Hide Drawer
/**
 This method slides the top controller completely off the screen.
 */
- (void)hide;

@end
