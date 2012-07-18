//
//  PSViewController.m
//  PSKit
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  VLog(@"#%@", [self class]);
        self.contentOffset = CGPointZero;
        self.shouldShowHeader = NO;
        self.shouldShowFooter = NO;
        self.shouldShowCurtain = NO;
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
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:self.parentViewController.view.bounds];
}

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
    self.headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.headerView addGradientLayerWithFrame:CGRectMake(0, self.headerView.height, self.headerView.width, 8.0) colors:[NSArray arrayWithObjects:(id)RGBACOLOR(0, 0, 0, 0.5).CGColor, (id)RGBACOLOR(0, 0, 0, 0.3).CGColor, (id)RGBACOLOR(0, 0, 0, 0.1).CGColor, (id)RGBACOLOR(0, 0, 0, 0.0).CGColor, nil] locations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.1], [NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], nil] startPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 1.0)];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    //    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleDarkLabel" target:self action:@selector(centerAction)];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    self.centerButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    //    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    //    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];

    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

- (void)setupFooter {
    if (!self.shouldShowFooter) return;
    
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)];
    self.footerView.backgroundColor = RGBCOLOR(192, 192, 192);
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.footerView];
}

- (void)setupCurtain {
    if (!self.shouldShowCurtain) return;
    
    self.curtainController = [[CurtainController alloc] initWithNibName:nil bundle:nil];
    [self.curtainController setDelegate:self];
    NSArray *titles = [[[(PSSpringboardController *)self.parentViewController.parentViewController viewControllers] valueForKey:@"topViewController"] valueForKey:@"title"];
    [self.curtainController setItems:titles];
    self.curtainController.view.frame = self.contentView.frame;
    [self.view insertSubview:self.curtainController.view belowSubview:self.headerView];
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
    // subclass should implement
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
