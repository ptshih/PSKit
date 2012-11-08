//
//  PSAlertView.h
//  PSKit
//
//  Created by Peter Shih on 3/29/12.
//  Copyright (c) 2012 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 If there is a textField, we always return a string for textFieldValue (it can be empty)
 */
typedef void (^PSAlertViewCompletionBlock)(NSUInteger buttonIndex, NSString *textFieldValue);

@interface PSAlertView : UIView

+ (void)showWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles textFieldPlaceholder:(NSString *)textFieldPlaceholder completionBlock:(PSAlertViewCompletionBlock)completionBlock;

+ (void)showWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles emailText:(NSString *)emailText completionBlock:(PSAlertViewCompletionBlock)completionBlock;

@end