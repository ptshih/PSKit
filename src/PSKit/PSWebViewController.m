//
//  PSWebViewController.m
//  PSKit
//
//  Created by Peter Shih on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSWebViewController.h"

@interface PSWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, copy) NSString *URLPath;
@property (nonatomic, copy) NSString *webTitle;

@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;

- (void)loadWebView;

@end

@implementation PSWebViewController

- (id)initWithURLPath:(NSString *)URLPath title:(NSString *)title {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.shouldShowHeader = YES;
        
        self.URLPath = URLPath;
        self.webTitle = title;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.webView.delegate = nil;
}

- (void)dealloc {
    self.webView.delegate = nil;
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return BASE_BG_COLOR;
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadWebView];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [super setupSubviews];
    
    // WebView
    self.webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    self.webView.autoresizingMask = self.contentView.autoresizingMask;
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.contentView insertSubview:self.webView belowSubview:self.headerView];
}

- (void)setupHeader {
    [super setupHeader];
    
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    NSString *title = self.webTitle ? self.webTitle : @"Loading...";
    [PSStyleSheet applyStyle:@"navigationTitleLightLabel" forButton:self.centerButton];
    [self.centerButton setTitle:title forState:UIControlStateNormal];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinnerView.frame = self.rightButton.bounds;
    self.spinnerView.hidesWhenStopped = YES;
    [self.rightButton addSubview:self.spinnerView];
}

#pragma mark - Actions
- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
}


- (void)loadWebView {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.URLPath]];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)req navigationType:(UIWebViewNavigationType)navigationType {
    [self.spinnerView startAnimating];
    
    NSMutableURLRequest *request = (NSMutableURLRequest *)req;
    
    if ([request respondsToSelector:@selector(setValue:forHTTPHeaderField:)]) {
        //        [request setValue:USER_AGENT forHTTPHeaderField:@"User-Agent"];
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || navigationType == UIWebViewNavigationTypeFormResubmitted) {
        id vc = [[[self class] alloc] initWithURLPath:[req.URL absoluteString] title:nil];
        [self.navigationController pushViewController:vc animated:YES];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.spinnerView stopAnimating];
    
    if (!self.webTitle) {
        [self.centerButton setTitle:[[webView stringByEvaluatingJavaScriptFromString:@"document.title"] stringByUnescapingHTML] forState:UIControlStateNormal];
    }
    //    self.title = [[webView stringByEvaluatingJavaScriptFromString:@"document.title"] stringByUnescapingHTML];
}

@end
