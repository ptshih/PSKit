//
//  PSWebViewController.m
//  PSKit
//
//  Created by Peter Shih on 8/26/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSWebViewController.h"

@interface PSWebViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, copy) NSString *URLPath;
@property (nonatomic, copy) NSString *webTitle;

@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;

@property (nonatomic, assign) NSInteger frameCount;

- (void)loadWebView;

@end

@implementation PSWebViewController

- (id)initWithURLPath:(NSString *)URLPath title:(NSString *)title {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.shouldShowHeader = YES;
        self.shouldShowFooter = YES;
        
        self.headerHeight = 44.0;
        self.footerHeight = 44.0;
        
        self.URLPath = URLPath;
        self.webTitle = title;
        
        self.frameCount = 0;
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
    
    [self.rightButton setImage:[UIImage imageNamed:@"IconRefreshWhite"] forState:UIControlStateNormal];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinnerView.frame = self.rightButton.frame;
    self.spinnerView.hidesWhenStopped = YES;
    [self.headerView addSubview:self.spinnerView];
    
    self.rightButton.hidden = YES;
}

- (void)setupFooter {
    [super setupFooter];
    
    UIButton *backButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"navButton" target:self action:@selector(back)];
    backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [backButton setBackgroundImage:[UIImage stretchableImageNamed:@"ToolbarLeft" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.backButton = backButton;
    
    UIButton *forwardButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"navButton" target:self action:@selector(forward)];
    forwardButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [forwardButton setBackgroundImage:[UIImage stretchableImageNamed:@"ToolbarRight" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [forwardButton setImage:[UIImage imageNamed:@"IconNextWhite"] forState:UIControlStateNormal];
    
    backButton.frame = CGRectMake(0, 0, self.footerView.width / 2.0, self.footerView.height);
    forwardButton.frame = CGRectMake(self.footerView.width / 2.0, 0, self.footerView.width / 2.0, self.footerView.height);
    self.forwardButton = forwardButton;
    
    [self updateButtons];
    
    [self.footerView addSubview:backButton];
    [self.footerView addSubview:forwardButton];
}

#pragma mark - Actions

- (void)leftAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
    [self.webView reload];
}

- (void)back {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
}

- (void)forward {
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

- (void)updateButtons {
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

#pragma mark - State Machine

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
    
    return YES;
    
//    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeFormSubmitted || navigationType == UIWebViewNavigationTypeFormResubmitted) {
//        id vc = [[[self class] alloc] initWithURLPath:[req.URL absoluteString] title:nil];
//        [self.navigationController pushViewController:vc animated:YES];
//        return NO;
//    } else {
//        return YES;
//    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.frameCount == 0) {
        [self.spinnerView startAnimating];
        self.rightButton.hidden = YES;
    }
    self.frameCount++;
    
    [self.centerButton setTitle:@"Loading..." forState:UIControlStateNormal];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    
    if (self.frameCount == 0) {
        [self.spinnerView stopAnimating];
        self.rightButton.hidden = NO;
        
        [self updateButtons];
        
        if (!self.webTitle) {
            [self.centerButton setTitle:[[webView stringByEvaluatingJavaScriptFromString:@"document.title"] stringByUnescapingHTML] forState:UIControlStateNormal];
        } else if ([self.webTitle isEqualToString:@"Loading..."]) {
            [self.centerButton setTitle:[[webView stringByEvaluatingJavaScriptFromString:@"document.title"] stringByUnescapingHTML] forState:UIControlStateNormal];
        } else {
            [self.centerButton setTitle:self.webTitle forState:UIControlStateNormal];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.frameCount--;
    
    if (self.frameCount == 0) {
        [self.spinnerView stopAnimating];
        self.rightButton.hidden = NO;
        
        [self updateButtons];
    }
}

@end
