//
//  PSToolbar.h
//  OSnap
//
//  Created by Peter Shih on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSToolbar : UIToolbar {
  UIImage *_backgroundImage;
}

/**
 Setting this property to a custom UIImage will override the default toolbar background image
 */
@property (nonatomic, retain) UIImage *backgroundImage;

@end
