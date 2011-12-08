//
//  PSNavigationBar.h
//  MealTime
//
//  Created by Peter Shih on 10/6/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSNavigationBar : UINavigationBar {
  UIImage *_backgroundImage;
}

/**
 Setting this property to a custom UIImage will override the default NavigationBar background image
 */
@property (nonatomic, retain) UIImage *backgroundImage;

@end
