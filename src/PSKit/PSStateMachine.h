//
//  PSStateMachine.h
//  PSKit
//
//  Created by Peter Shih on 2/27/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol PSStateMachine <NSObject>

@optional

// Data Source
- (void)loadDataSource; // Loads from local if exists, else from remote
- (void)reloadDataSource; // Attempts to reload from remote only
- (void)loadMoreDataSource; // Loads more from remote and appends to data source
- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache;
- (void)loadDataSourceFromFixtures;

// Load a single NSDictionary into the dataSource (not used for tableViews)
- (void)dataSourceShouldLoadObject:(id)object;

// Tells the tableView to load objects into the dataSource (self.items)
// If !animated, calls reloadData otherwise performs beginsUpdate/endsUpdate
// Finally it calls dataSourceDidLoad
- (void)dataSourceShouldLoadObjects:(id)objects animated:(BOOL)animated;

//- (void)dataSourceShouldLoadMoreObjects:(id)objects forSection:(NSInteger)section shouldAnimate:(BOOL)shouldAnimate;

- (void)dataSourceDidLoad;
- (void)dataSourceDidLoadMore;
- (void)dataSourceDidError;
- (BOOL)dataSourceIsEmpty;

- (void)reloadAfterError:(UIButton *)button;

/**
 Helps determine if a loading/empty screen is shown
 Or if data has been loaded to display
 Subclasses should implement
 */

// Refresh
- (void)beginRefresh;
- (void)endRefresh;

// Load More
- (void)beginLoadMore;
- (void)endLoadMore;

// Views
- (void)setupSubviews;
- (void)updateSubviews;

// Tables
- (void)setupTableHeader;
- (void)setupTableFooter;
- (void)setupLoadMoreView;


// Convenience
// UNUSED
- (id)parseData:(id)data httpResponse:(NSHTTPURLResponse *)httpResponse;



/**
 Configure/layout any subviews used in the view controller
 */
- (void)setupHeader;
- (void)setupFooter;
- (void)setupSubviews;


// DEPRECATED

/**
 Used by tableView to page in more data
 */
- (void)loadMore;

/**
 Used to configure the view right after it is loaded
 */
- (UIView *)baseBackgroundView;
- (UIColor *)baseBackgroundColor;
- (UIView *)rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;
- (UIColor *)rowBackgroundColorForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

/**
 Remotely fetch data
 */
- (void)fetchDataSource;

/**
 Local fetch data
 */
- (void)dataSourceDidFetch;

/**
 Core Data
 */
// Subclass MUST implement
- (NSFetchRequest *)fetchRequest;
- (NSString *)frcCacheName;
- (NSPredicate *)fetchPredicate;
- (NSArray *)fetchSortDescriptors;
- (NSString *)sectionNameKeyPath;

@end
