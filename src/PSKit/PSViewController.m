//
//  PSViewController.m
//  PSKit
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#define kNullViewAnimationDuration 0.3

// PSNullView

@interface PSNullView : UIView

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIActivityIndicatorView *spinnerView;

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor labelStyle:(NSString *)labelStyle indicatorStyle:(UIActivityIndicatorViewStyle)indicatorStyle;

@end

@implementation PSNullView

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor labelStyle:(NSString *)labelStyle indicatorStyle:(UIActivityIndicatorViewStyle)indicatorStyle {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = backgroundColor;
        
        CGFloat midX = CGRectGetMidX(self.bounds);
        CGFloat midY = CGRectGetMidY(self.bounds);
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
        self.spinnerView.hidesWhenStopped = YES;
        [v addSubview:self.spinnerView];
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [PSStyleSheet applyStyle:labelStyle forLabel:self.messageLabel];
        self.messageLabel.text = @"Loading...";
        [self.messageLabel sizeToFit];
        self.messageLabel.left += self.spinnerView.width + 8.0;
        [v addSubview:self.messageLabel];
        
        v.width = self.spinnerView.width + self.messageLabel.width + 8.0;
        v.height = MAX(self.spinnerView.height, self.messageLabel.height);
        
        self.spinnerView.height = self.messageLabel.height;
        
        v.center = CGPointMake(midX, midY);
        
        [self addSubview:v];
    }
    return self;
}

@end

// PSViewController

#import "PSViewController.h"

@implementation PSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  VLog(@"#%@", [self class]);
        self.reloading = NO;
        self.loadingMore = NO;
        
        self.contentOffset = CGPointZero;
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        self.shouldShowNullView = NO;
        self.shouldAddRoundedCorners = NO;
        self.shouldAdjustViewForKeyboard = NO;
        
        self.headerHeight = 44.0;
        self.footerHeight = 44.0;
        
        self.headerLeftWidth = 44.0;
        self.headerRightWidth = 44.0;
        
        self.limit = 10;
        self.offset = 0;
        
        self.nullBackgroundColor = BASE_BG_COLOR;
        self.nullLabelStyle = @"loadingDarkLabel";
        self.nullIndicatorStyle = UIActivityIndicatorViewStyleGray;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = ~UIViewAutoresizingNone;
    
    // Background
    if ([self respondsToSelector:@selector(baseBackgroundView)]) {
        UIView *bgView = [self baseBackgroundView];
        if (bgView) {
            bgView.frame = self.view.bounds;
            bgView.autoresizingMask = self.view.autoresizingMask;
            [self.view insertSubview:bgView atIndex:0];
        }
    } else if ([self respondsToSelector:@selector(baseBackgroundColor)]) {
        self.view.backgroundColor = [self baseBackgroundColor];
    }
    
    // Setup Subviews
    [self setupSubviews];
    
    // Null View
    [self setupNullView];
    
    // Add rounded corners
    if (self.shouldAddRoundedCorners) {
        [self addRoundedCorners];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

/*
 This creates and adds subviews
 */
- (void)setupSubviews {
    // subclass should implement
    [self setupHeader];
    [self setupFooter];
    [self setupContent];
    [self updateSubviews];
    
    [self.view bringSubviewToFront:self.footerView];
    [self.view bringSubviewToFront:self.headerView];
}

/*
 This relayouts the subviews
 */
- (void)updateSubviews {
    CGFloat visibleHeaderHeight = (self.headerView) ? self.headerView.bottom : 0.0;
    CGFloat visibleFooterHeight = (self.footerView) ? self.view.height - self.footerView.top : 0.0;
    CGRect frame = CGRectMake(0, visibleHeaderHeight, self.view.width, self.view.height - visibleHeaderHeight - visibleFooterHeight);
    self.contentView.frame = frame;
}

- (void)setupContent {
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentView];
}

- (void)setupHeader {
    if (!self.shouldShowHeader) return;
    
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.headerHeight)];
    self.headerView.backgroundColor = HEADER_BG_COLOR;
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    
    self.leftButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"navButton" target:self action:@selector(leftAction)];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    //    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"navButton" target:self action:@selector(rightAction)];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    //    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"navigationTitleDarkLabel" target:self action:@selector(centerAction)];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    [self layoutHeaderWithLeftWidth:self.headerLeftWidth rightWidth:self.headerRightWidth];

    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    
    UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.headerView.height, self.headerView.width, 8.0) image:[[UIImage imageNamed:@"DropShadow"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
    ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.headerView addSubview:ds];
    
    [self.view addSubview:self.headerView];
}

- (void)layoutHeaderWithLeftWidth:(CGFloat)leftWidth rightWidth:(CGFloat)rightWidth {
    self.leftButton.frame = CGRectMake(0, 0, leftWidth, self.headerView.height);
    self.rightButton.frame = CGRectMake(self.headerView.width - rightWidth, 0, rightWidth, self.headerView.height);
    self.centerButton.frame = CGRectMake(self.leftButton.right, 0, self.headerView.width - leftWidth - rightWidth, self.headerView.height);
}

- (void)setupFooter {
    if (!self.shouldShowFooter) return;
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - self.footerHeight, self.view.width, self.footerHeight)];
    self.footerView.backgroundColor = FOOTER_BG_COLOR;
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, -8.0, self.footerView.width, 8.0) image:[[UIImage imageNamed:@"DropShadowInverted"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
    ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.footerView addSubview:ds];
    
    [self.view addSubview:self.footerView];
}

- (void)setupNullView {
    if (!self.shouldShowNullView) return;
    
    self.nullView = [[PSNullView alloc] initWithFrame:self.contentView.bounds backgroundColor:self.nullBackgroundColor labelStyle:self.nullLabelStyle indicatorStyle:self.nullIndicatorStyle];
    self.nullView.autoresizingMask = self.contentView.autoresizingMask;
    [self.contentView addSubview:self.nullView];
    
    [self.nullView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadDataSource)]];
}

#pragma mark - Post View Config

- (void)addRoundedCorners {
#warning BROKEN
    // iPad doesn't need rounded corners
    if (!isDeviceIPad()) {
        UIImageView *topCorners = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/MaskCornersTop"] stretchableImageWithLeftCapWidth:160 topCapHeight:0]];
        topCorners.top = self.view.top;
        [self.view addSubview:topCorners];
        
        UIImageView *bottomCorners = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/MaskCornersBottom"] stretchableImageWithLeftCapWidth:160 topCapHeight:0]];
        bottomCorners.top = self.view.height - bottomCorners.height;
        [self.view addSubview:bottomCorners];
    }
}

#pragma mark - DataSource

- (void)loadDataSource {
    ASSERT_MAIN_THREAD;
    [self beginRefresh];
    self.offset = 0;
    
    if (self.shouldShowNullView) {
        [self.nullView.spinnerView startAnimating];
        [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
            self.nullView.messageLabel.text = @"Loading...";
            self.nullView.alpha = 1.0;
        }];
    }
}

- (void)reloadDataSource {
    ASSERT_MAIN_THREAD;
    [self beginRefresh];
    self.offset = 0;
}

- (void)loadMoreDataSource {
    ASSERT_MAIN_THREAD;
    [self beginLoadMore];
    self.offset += self.limit;
}

- (void)dataSourceDidLoad {
    ASSERT_MAIN_THREAD;
    [self endRefresh];
    
    if ([self dataSourceIsEmpty]) {
        if (self.shouldShowNullView) {
            [self.nullView.spinnerView stopAnimating];
            [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
                self.nullView.messageLabel.text = @"Empty...";
                self.nullView.alpha = 1.0;
            }];
        }
    } else {
        if (self.shouldShowNullView) {
            [self.nullView.spinnerView stopAnimating];
            [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
                self.nullView.messageLabel.text = nil;
                self.nullView.alpha = 0.0;
            }];
        }
    }
}

- (void)dataSourceDidLoadMore {
    ASSERT_MAIN_THREAD;
    [self endLoadMore];
}

- (void)dataSourceDidError {
    ASSERT_MAIN_THREAD;
    [self endRefresh];
    
    if (self.shouldShowNullView) {
        [self.nullView.spinnerView stopAnimating];
        [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
            self.nullView.messageLabel.text = @"Error...";
            self.nullView.alpha = 1.0;
        }];
    }
}

- (BOOL)dataSourceIsEmpty {
    return NO;
}

- (void)beginRefresh {
    ASSERT_MAIN_THREAD;
    self.reloading = YES;
}

- (void)endRefresh {
    ASSERT_MAIN_THREAD;
    self.reloading = NO;
}

- (void)beginLoadMore {
    ASSERT_MAIN_THREAD;
    self.loadingMore = YES;
}

- (void)endLoadMore {
    ASSERT_MAIN_THREAD;
    self.loadingMore = NO;
}

#pragma mark - Rotation

// iOS6
- (NSUInteger)supportedInterfaceOrientations {
    if (isDeviceIPad()) {
        return UIInterfaceOrientationMaskAll;
    } else {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (isDeviceIPad()) {
        return YES;
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
}

- (void)orientationChangedFromNotification:(NSNotification *)notification {
    // may should implement
}

#pragma mark - Scroll State
- (void)updateScrollsToTop:(BOOL)isEnabled {
    if (self.activeScrollView) {
        self.activeScrollView.scrollsToTop = isEnabled;
    }
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!self.shouldAdjustViewForKeyboard) return;
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationOptions animationOptions = animationCurve << 16; // convert
    
    NSValue *frameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [frameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.view.height -= keyboardHeight;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!self.shouldAdjustViewForKeyboard) return;
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationOptions animationOptions = animationCurve << 16; // convert
    
    NSValue *frameValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [frameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.view.height += keyboardHeight;
    } completion:^(BOOL finished) {
        
    }];
}

@end
