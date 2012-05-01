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

- (void)dealloc {
    //  VLog(@"#%@", [self class]);
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    VLog(@"#%@", [self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    VLog(@"#%@", [self class]);
}

#pragma mark - View
- (void)loadView {
    self.view = [[[UIView alloc] initWithFrame:self.parentViewController.view.bounds] autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    VLog(@"#%@", [self class]);
    
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
    VLog(@"#%@", [self class]);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    VLog(@"#%@", [self class]);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    VLog(@"#%@", [self class]);
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    VLog(@"#%@", [self class]);
}

- (void)setupSubviews {
    // subclass should implement
}

#pragma mark - Post View Config
- (void)addRoundedCorners {
    // iPad doesn't need rounded corners
    if (!isDeviceIPad()) {
        UIImageView *topCorners = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/MaskCornersTop"] stretchableImageWithLeftCapWidth:160 topCapHeight:0]] autorelease];
        topCorners.top = self.view.top;
        [self.view addSubview:topCorners];
        
        UIImageView *bottomCorners = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"PSKit.bundle/MaskCornersBottom"] stretchableImageWithLeftCapWidth:160 topCapHeight:0]] autorelease];
        bottomCorners.top = self.view.height - bottomCorners.height;
        [self.view addSubview:bottomCorners];
    }
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

@end
