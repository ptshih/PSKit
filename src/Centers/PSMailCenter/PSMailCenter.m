//
//  PSMailCenter.m
//  MealTime
//
//  Created by Peter Shih on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSMailCenter.h"

@implementation PSMailCenter

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)controller:(UIViewController *)controller sendMailTo:(NSArray *)recipients withSubject:(NSString *)subject andMessageBody:(NSString *)messageBody {
  if([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    mailVC.mailComposeDelegate = self;
		mailVC.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    if (recipients) {
      [mailVC setToRecipients:recipients];
    }
		[mailVC setSubject:subject];
		[mailVC setMessageBody:messageBody isHTML:YES];
		[controller presentModalViewController:mailVC animated:YES];
		[mailVC release];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Mail Accounts Found", @"No Mail Accounts Found") message:NSLocalizedString(@"You must setup a Mail account before using this feature", @"You must setup a Mail account before using this feature") delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark MFMailCompose
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
  [controller dismissModalViewControllerAnimated:YES];
}

@end
