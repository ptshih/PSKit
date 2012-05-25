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

@synthesize
webView = _webView,
activityView = _activityView,
URLPath = _URLPath,
webTitle = _webTitle;

@synthesize
spinnerView = _spinnerView;


- (id)initWithURLPath:(NSString *)URLPath title:(NSString *)title {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
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
    return [UIColor whiteColor];
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
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height - self.footerView.height)];
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    [self.view addSubview:self.webView];
}

- (void)setupHeader {
    [super setupHeader];
    
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    self.headerView.backgroundColor = [UIColor blackColor];
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    
    NSString *title = self.webTitle ? self.webTitle : @"Loading...";
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.centerButton setTitle:title forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    //    [self.rightButton setImage:[UIImage imageNamed:@"IconPinWhite"] forState:UIControlStateNormal];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.rightButton.userInteractionEnabled = NO;
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinnerView.frame = self.rightButton.bounds;
    self.spinnerView.hidesWhenStopped = YES;
    [self.rightButton addSubview:self.spinnerView];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
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
        PSWebViewController *vc = [[PSWebViewController alloc] initWithURLPath:[req.URL absoluteString] title:nil];
        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
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
