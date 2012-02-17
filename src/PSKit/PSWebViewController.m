//
//  PSWebViewController.m
//  PSKit
//
//  Created by Peter Shih on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSWebViewController.h"

@implementation PSWebViewController

@synthesize
webView = _webView,
activityView = _activityView,
URLPath = _URLPath;

- (id)initWithURLPath:(NSString *)URLPath {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.URLPath = URLPath;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView.delegate = nil;
    self.webView = nil;
    self.activityView = nil;
}

- (void)dealloc
{
    self.webView.delegate = nil;
    self.webView = nil;
    self.activityView = nil;
    self.URLPath = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // WebView
    self.webView = [[[UIWebView alloc] initWithFrame:self.view.bounds] autorelease];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
    [self loadWebView];
}

- (void)loadWebView {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.URLPath]];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
    NSMutableURLRequest *request = (NSMutableURLRequest *)req;
    
    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
//        [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || navigationType == UIWebViewNavigationTypeFormResubmitted) {
        PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:[req.URL absoluteString]];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.title = [[webView stringByEvaluatingJavaScriptFromString:@"document.title"] stringByUnescapingHTML];
}

@end
