//
//  PSSearchField.h
//  MealTime
//
//  Created by Peter Shih on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
  PSSearchFieldStyleBlack = 0,
  PSSearchFieldStyleWhite = 1,
  PSSearchFieldStyleCell = 2
};
typedef uint32_t PSSearchFieldStyle;

@interface PSSearchField : UITextField {
}

- (id)initWithFrame:(CGRect)frame style:(PSSearchFieldStyle)style;

@end
