//
//  PSWebViewController.h
//  MealTime
//
//  Created by Peter Shih on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"

@interface PSWebViewController : PSViewController <UIWebViewDelegate> {
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *activityView;
@property (nonatomic, copy) NSString *URLPath;

- (id)initWithURLPath:(NSString *)URLPath;
- (void)loadWebView;

@end
