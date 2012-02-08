//
//  PSTableViewController.h
//  PhotoTime
//
//  Created by Peter Shih on 2/14/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import "EGORefreshTableHeaderView.h"
//#import "UIViewController+Ad.h"

@interface PSTableViewController : PSBaseViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, EGORefreshTableHeaderDelegate> {
  
  // Paging
  NSInteger _pagingStart;
  NSInteger _pagingCount;
  NSInteger _pagingTotal;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *searchItems;
@property (nonatomic, retain) NSMutableArray *sectionTitles;
@property (nonatomic, retain) NSMutableDictionary *selectedIndexes;
@property (nonatomic, retain) NSMutableArray *cellCache;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) EGORefreshTableHeaderView *pullRefreshView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UIView *loadMoreView;

// View Setup
- (void)setupTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style separatorStyle:(UITableViewCellSeparatorStyle)separatorStyle separatorColor:(UIColor *)separatorColor;
- (void)setupPullRefresh;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles andPlaceholder:(NSString *)placeholder;

// Utility Methods
- (void)resetPaging;

// Cell Selection State
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath withObject:(id)object;

// Cell Type
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;

// ScrollView Stuff
- (void)scrollEndedTrigger;

// Refresh
- (void)beginRefresh;
- (void)endRefresh;

@end
