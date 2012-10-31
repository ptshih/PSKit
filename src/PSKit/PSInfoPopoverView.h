//
//  PSInfoPopoverView.h
//  Lunchbox
//
//  Created by Peter Shih on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface PSInfoPopoverView : PSView

- (id)initWithMessage:(NSString *)message;
- (void)showInView:(UIView *)view;

@end
