//
//  PSViewController.m
//  PSKit
//
//  Created by Peter Shih on 3/16/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

@synthesize
headerView = _headerView,
footerView = _footerView,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
activeScrollView = _activeScrollView,
contentOffset = _contentOffset;

@synthesize
shouldAddRoundedCorners = _shouldAddRoundedCorners;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //  VLog(@"#%@", [self class]);
        self.contentOffset = CGPointZero;
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
}

/*
 This relayouts the subviews
 */
- (void)updateSubviews {
    // subclass may implement
}

- (void)setupHeader {
    // subclass may implement
}

- (void)setupFooter {
    // subclass may implement
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
    if (self.headerView && [self.headerView.layer.sublayers count] > 0 && [[self.headerView.layer.sublayers firstObject] isKindOfClass:[CAGradientLayer class]]) {
        [[self.headerView.layer.sublayers firstObject] setFrame:CGRectMake(0, self.headerView.height, self.headerView.width, 8.0)];
    }
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

@end
