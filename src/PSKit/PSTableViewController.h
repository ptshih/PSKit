//
//  PSTableViewController.h
//  PSKit
//
//  Created by Peter Shih on 2/14/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import "PSPullRefreshView.h"

@interface PSTableViewController : PSBaseViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, PSPullRefreshViewDelegate>

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *searchItems;
@property (nonatomic, strong) NSMutableArray *sectionTitles;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexes;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PSPullRefreshView *pullRefreshView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *loadMoreView;

// Config
@property (nonatomic, assign) BOOL shouldPullRefresh;
@property (nonatomic, assign) UITableViewStyle tableViewStyle;
@property (nonatomic, assign) UITableViewCellSeparatorStyle tableViewCellSeparatorStyle;
@property (nonatomic, strong) UIColor *separatorColor;

// View Setup
- (void)setupTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle separatorColor:(UIColor *)separatorColor;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles andPlaceholder:(NSString *)placeholder;

// Cell Selection State
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath withObject:(id)object;

// Cell Type
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;

@end
