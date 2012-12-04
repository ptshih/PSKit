//
//  PSTileViewController.m
//  Lunchbox
//
//  Created by Peter Shih on 12/3/12.
//
//

#import "PSTileViewController.h"

@interface PSTileViewController ()

@end

@implementation PSTileViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        
        // Config
        self.shouldShowNullView = NO;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.tileView.delegate = nil;
    self.tileView.tileViewDelegate = nil;
    self.tileView.tileViewDataSource = nil;
}

- (void)dealloc {
    self.tileView.delegate = nil;
    self.tileView.tileViewDelegate = nil;
    self.tileView.tileViewDataSource = nil;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubviews {
    [super setupSubviews];
    
    self.tileView = [[PSTileView alloc] initWithFrame:self.contentView.bounds];
    self.tileView.delegate = self;
    self.tileView.tileViewDelegate = self;
    self.tileView.tileViewDataSource = self;
    self.tileView.backgroundColor = [UIColor clearColor];
    self.tileView.autoresizingMask = ~UIViewAutoresizingNone;
    
    [self.contentView addSubview:self.tileView];
}

#pragma mark - State Machine

- (void)loadDataSource {
    [super loadDataSource];
    [self beginRefresh];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    [self beginRefresh];
    self.contentOffset = CGPointZero;
}

- (void)loadMoreDataSource {
    [super loadMoreDataSource];
    [self beginLoadMore];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    
    [self.tileView reloadData];
    self.tileView.contentOffset = self.contentOffset;
    
    [self endRefresh];
}

- (void)dataSourceDidLoadMore {
    [super dataSourceDidLoadMore];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
    [self.tileView reloadData];
    self.tileView.contentOffset = CGPointZero;
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

#pragma mark - PSTileViewDelegate

- (void)tileView:(PSTileView *)tileView didSelectCell:(PSTileViewCell *)cell atIndex:(NSInteger)index {
    
}

#pragma mark - PSTileViewDataSource

- (NSInteger)numberOfTilesInTileView:(PSTileView *)tileView {
    return [self.items count];
}

- (NSArray *)templateForTileView:(PSTileView *)tileView {
    return [NSArray array];
}

- (PSTileViewCell *)tileView:(PSTileView *)tileView cellForItemAtIndex:(NSInteger)index {
    return nil;
}

@end
