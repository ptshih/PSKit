//
//  PSViewController.m
//  PSKit
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

// Margins
static CGSize margin() {
    if (isDeviceIPad()) {
        return CGSizeMake(8.0, 6.0);
    } else {
        return CGSizeMake(8.0, 6.0);
    }
}

#define kNullViewAnimationDuration 0.2

// PSNullView

@interface PSNullView : UIView

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation PSNullView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.messageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [PSStyleSheet applyStyle:@"loadingDarkLabel" forLabel:self.messageLabel];
        self.messageLabel.text = @"Loading...";
        [self addSubview:self.messageLabel];
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
        self.isReload = NO;
        
        self.contentOffset = CGPointZero;
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        self.shouldShowCurtain = NO;
        self.shouldShowNullView = NO;
        self.shouldAddRoundedCorners = NO;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.autoresizingMask = ~UIViewAutoresizingNone;
    
    // Background
    if ([self respondsToSelector:@selector(baseBackgroundView)]) {
        UIView *bgView = [self baseBackgroundView];
        if (bgView) {
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
    
    [self.view bringSubviewToFront:self.footerView];
    [self.view bringSubviewToFront:self.headerView];
    
    [self setupCurtain];
}

/*
 This relayouts the subviews
 */
- (void)updateSubviews {
    // subclass may implement
}

- (void)setupContent {
    CGFloat visibleHeaderHeight = (self.headerView) ? self.headerView.bottom : 0.0;
    CGFloat visibleFooterHeight = (self.footerView) ? self.view.height - self.footerView.top : 0.0;
    CGRect frame = CGRectMake(0, visibleHeaderHeight, self.view.width, self.view.height - visibleHeaderHeight - visibleFooterHeight);
    
    self.contentView = [[UIView alloc] initWithFrame:frame];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.contentView];
}

- (void)setupHeader {
    if (!self.shouldShowHeader) return;
    
    // Setup perma header
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
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
    
    [self layoutHeaderWithLeftWidth:32.0 rightWidth:32.0];

    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    
    UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.headerView.height, self.headerView.width, 8.0) image:[[UIImage imageNamed:@"DropShadow"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
    ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.headerView addSubview:ds];
    
    [self.view addSubview:self.headerView];
}

- (void)layoutHeaderWithLeftWidth:(CGFloat)leftWidth rightWidth:(CGFloat)rightWidth {
    self.leftButton.frame = CGRectMake(margin().width, margin().height, leftWidth, 32.0);
    self.rightButton.frame = CGRectMake(self.headerView.width - rightWidth - margin().width, margin().height, rightWidth, 32.0);
    self.centerButton.frame = CGRectMake(self.leftButton.right + margin().width, margin().height, self.headerView.width - leftWidth - rightWidth - margin().width * 4, 32.0);
}

- (void)setupFooter {
    if (!self.shouldShowFooter) return;
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    self.footerView.backgroundColor = FOOTER_BG_COLOR;
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIImageView *ds = [[UIImageView alloc] initWithFrame:CGRectMake(0, -8.0, self.footerView.width, 8.0) image:[[UIImage imageNamed:@"DropShadowInverted"] stretchableImageWithLeftCapWidth:1 topCapHeight:0]];
    ds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.footerView addSubview:ds];
    
    [self.view addSubview:self.footerView];
}

- (void)setupCurtain {
    if (!self.shouldShowCurtain) return;
    
    self.curtainController = [[CurtainController alloc] initWithNibName:nil bundle:nil];
    [self.curtainController setDelegate:self];
    NSArray *titles = [[[(PSSpringboardController *)self.parentViewController.parentViewController viewControllers] valueForKey:@"topViewController"] valueForKey:@"title"];
    NSArray *items = [NSArray arrayWithObjects:titles, nil];
    [self.curtainController setItems:items];
    self.curtainController.view.frame = self.contentView.frame;
    [self.view insertSubview:self.curtainController.view belowSubview:self.headerView];
}

- (void)setupNullView {
    if (!self.shouldShowNullView) return;
    
    self.nullView = [[PSNullView alloc] initWithFrame:self.contentView.bounds];
    self.nullView.autoresizingMask = self.contentView.autoresizingMask;
    self.nullView.backgroundColor = BASE_BG_COLOR;
    [self.contentView addSubview:self.nullView];
}

#pragma mark - Post View Config

- (void)addRoundedCorners {
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
    self.isReload = NO;
    
    if (self.shouldShowNullView) {
        [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
            self.nullView.messageLabel.text = @"Loading...";
            self.nullView.alpha = 1.0;
        }];
    }
}

- (void)reloadDataSource {
    ASSERT_MAIN_THREAD;
    [self beginRefresh];
    self.isReload = YES;
    
    if (self.shouldShowNullView) {
        [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
            self.nullView.messageLabel.text = @"Loading...";
            self.nullView.alpha = 1.0;
        }];
    }
}

- (void)dataSourceDidLoad {
    ASSERT_MAIN_THREAD;
    [self endRefresh];
    
    if ([self dataSourceIsEmpty]) {
        if (self.shouldShowNullView) {
            [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
                self.nullView.messageLabel.text = @"Empty...";
                self.nullView.alpha = 1.0;
            }];
        }
    } else {
        if (self.shouldShowNullView) {
            [UIView animateWithDuration:kNullViewAnimationDuration animations:^{
                self.nullView.messageLabel.text = nil;
                self.nullView.alpha = 0.0;
            }];
        }
    }
}

- (void)dataSourceDidError {
    ASSERT_MAIN_THREAD;
    [self endRefresh];
    
    if (self.shouldShowNullView) {
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

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

#pragma mark - CurtainControllerDelegate

- (void)curtainController:(CurtainController *)curtainController selectedRowAtIndex:(NSInteger)index {
    [(PSSpringboardController *)self.parentViewController.parentViewController setSelectedIndex:index];
}

@end
