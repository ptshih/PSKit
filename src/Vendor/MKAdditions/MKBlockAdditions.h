//
//  MKBlockAdditions.h
//  UIKitCategoryAdditions
//
//  Created by Mugunth on 21/03/11.
//  Copyright 2011 Steinlogic All rights reserved.
//

typedef void (^VoidBlock)();

typedef void (^DismissBlock)(int buttonIndex, NSString *textInput);
typedef void (^CancelBlock)();
typedef void (^PhotoPickedBlock)(UIImage *chosenImage);

#define kPhotoActionSheetTag 10000