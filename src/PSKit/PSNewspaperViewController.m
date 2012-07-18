//
//  PSNewspaperViewController.m
//  PSKit
//
//  Created by Peter Shih on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSNewspaperViewController.h"

@interface PSNewspaperViewController ()

@end

@implementation PSNewspaperViewController

@synthesize
items = _items,
newspaperView = _newspaperView;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.items = [NSMutableArray array];
        
        // Config
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.newspaperView.newspaperViewDelegate = nil;
    self.newspaperView.newspaperViewDataSource = nil;
}

- (void)dealloc {
    self.newspaperView.newspaperViewDelegate = nil;
    self.newspaperView.newspaperViewDataSource = nil;
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupSubviews {
    [super setupSubviews];
    
    self.newspaperView = [[PSNewspaperView alloc] initWithFrame:self.contentView.bounds];
    self.newspaperView.newspaperViewDelegate = self;
    self.newspaperView.newspaperViewDataSource = self;
    self.newspaperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.newspaperView.backgroundColor = [UIColor clearColor];

    [self.contentView addSubview:self.newspaperView];
}

- (void)updateSubviews {
    [super updateSubviews];

    self.newspaperView.frame = self.contentView.bounds;
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

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    [self.newspaperView reloadData];
    [self endRefresh];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
    [self.newspaperView reloadData];
    [self endRefresh];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

#pragma mark - PSNewspaperViewDelegate

#pragma mark - PSNewspaperViewDataSource

- (NSInteger)numberOfViewsInNewspaperView:(PSNewspaperView *)newspaperView {
    return [self.items count];
}

- (PSNewspaperCell *)newspaperView:(PSNewspaperView *)newspaperView cellAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    PSNewspaperCell *cell = [[PSNewspaperCell alloc] initWithFrame:CGRectZero];
    [cell fillCellWithObject:item];
    
    return cell;
}

- (NSDictionary *)newspaperView:(PSNewspaperView *)newspaperView objectAtIndex:(NSInteger)index {
    return [self.items objectAtIndex:index];
}

@end
