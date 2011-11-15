//
//  PSMailCenter.h
//  MealTime
//
//  Created by Peter Shih on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface PSMailCenter : NSObject <MFMailComposeViewControllerDelegate>

+ (id)defaultCenter;
- (void)controller:(UIViewController *)controller sendMailTo:(NSArray *)recipients withSubject:(NSString *)subject andMessageBody:(NSString *)messageBody;

@end
