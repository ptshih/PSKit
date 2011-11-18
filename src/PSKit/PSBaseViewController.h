//
//  PSBaseViewController.h
//  PhotoTime
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"
#import "PSStateMachine.h"

@interface PSBaseViewController : PSViewController <PSStateMachine, PSNullViewDelegate> {
  PSNullView *_nullView;
  
  BOOL _reloading;
  BOOL _dataDidError;
  BOOL _viewHasLoadedOnce;
}

@property (nonatomic, assign) BOOL viewHasLoadedOnce;



@end
