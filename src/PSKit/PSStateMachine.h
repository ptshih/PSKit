//
//  PSStateMachine.h
//  PhotoTime
//
//  Created by Peter Shih on 2/27/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol PSStateMachine <NSObject>

@optional

- (void)loadDataSource;
- (void)reloadDataSource;

// Models
- (void)loadFromCache;
- (void)loadFromRemote;

// Load a single NSDictionary into the dataSource (not used for tableViews)
- (void)dataSourceShouldLoadObject:(id)object;

// Tells the tableView to load objects into the dataSource (self.items)
// If !animated, calls reloadData otherwise performs beginsUpdate/endsUpdate
// Finally it calls dataSourceDidLoad
- (void)dataSourceShouldLoadObjects:(id)objects animated:(BOOL)animated;

//- (void)dataSourceShouldLoadMoreObjects:(id)objects forSection:(NSInteger)section shouldAnimate:(BOOL)shouldAnimate;



// Views
- (void)setupSubviews;
- (void)setupPullRefresh;

// Tables
- (void)setupTableHeader;
- (void)setupTableFooter;
- (void)setupLoadMoreView;

// Convenience
- (id)parseData:(id)data httpResponse:(NSHTTPURLResponse *)httpResponse;

/**
 Helps determine if a loading/empty screen is shown
 Or if data has been loaded to display
 Subclasses should implement
 */
- (BOOL)dataIsAvailable;
- (BOOL)dataIsLoading;
//- (BOOL)dataDidError;

/**
 Tell the state machine to either show a loading/empty view or show data
 */
- (void)updateState;

/**
 Configure/layout any subviews used in the view controller
 */
- (void)setupHeader;
- (void)setupFooter;
- (void)setupSubviews;


/**
 Used by tableView to page in more data
 */
- (void)loadMore;

/**
 Used to configure the view right after it is loaded
 */
- (UIView *)navigationTitleView;
- (UIView *)baseBackgroundView;
- (UIColor *)baseBackgroundColor;
- (UIView *)rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

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