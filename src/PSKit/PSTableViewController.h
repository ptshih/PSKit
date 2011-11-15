//
//  PSTableViewController.h
//  PhotoTime
//
//  Created by Peter Shih on 2/14/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseViewController.h"
#import "EGORefreshTableHeaderView.h"
//#import "UIViewController+Ad.h"

@interface PSTableViewController : PSBaseViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, EGORefreshTableHeaderDelegate> {
  UITableView *_tableView;
  NSMutableArray *_sectionTitles;
  NSMutableArray *_items;
  NSMutableArray *_searchItems;
  NSMutableDictionary *_selectedIndexes;
  NSArray *_visibleCells;
  NSArray *_visibleIndexPaths;
  NSMutableArray *_cellCache;
  
//  ADBannerView *_adView;
//  BOOL _adShowing;
  
  UISearchBar *_searchBar;
  EGORefreshTableHeaderView *_refreshHeaderView;
  UIView *_loadMoreView;
  UIView *_footerView; // just a pointer
  
  // Paging
  NSInteger _pagingStart;
  NSInteger _pagingCount;
  NSInteger _pagingTotal;
  
  // View State
  CGPoint _contentOffset;
  
  BOOL _hasMore;  
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *searchItems;

// View Config
- (UIView *)tableView:(UITableView *)tableView rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

// View Setup
- (void)setupTableViewWithFrame:(CGRect)frame andStyle:(UITableViewStyle)style andSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;
- (void)setupPullRefresh;
- (void)setupTableHeader;
- (void)setupTableFooter;
- (void)setupHeaderWithView:(UIView *)headerView;
- (void)setupFooterWithView:(UIView *)footerView;
- (void)setupLoadMoreView;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles andPlaceholder:(NSString *)placeholder;

// Utility Methods
- (void)resetPaging;

// Cell Selection State
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath withObject:(id)object;

// Cell Type
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath;

// ScrollView Stuff
- (void)scrollEndedTrigger;

- (void)reloadDataSafely;

@end
