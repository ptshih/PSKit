//
//  PSSearchField.h
//  MealTime
//
//  Created by Peter Shih on 9/14/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
  PSSearchFieldStyleBlack = 0,
  PSSearchFieldStyleWhite = 1
};
typedef uint32_t PSSearchFieldStyle;

@interface PSSearchField : UITextField {
  PSSearchFieldStyle _searchFieldStyle;
}

- (id)initWithFrame:(CGRect)frame style:(PSSearchFieldStyle)style;

@end
