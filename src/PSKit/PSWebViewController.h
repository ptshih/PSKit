//
//  PSWebViewController.h
//  PSKit
//
//  Created by Peter Shih on 8/26/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSViewController.h"

@interface PSWebViewController : PSViewController

@property (nonatomic, strong) UIWebView *webView;

- (id)initWithURLPath:(NSString *)URLPath title:(NSString *)title;

- (void)webViewDidStartLoad:(UIWebView *)webView;
- (void)webViewDidFinishLoad:(UIWebView *)webView;

@end
