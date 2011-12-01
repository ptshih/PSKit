//
//  PSStateMachine.h
//  PhotoTime
//
//  Created by Peter Shih on 2/27/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSStateMachine <NSObject>

@optional

/**
 Helps determine if a loading/empty screen is shown
 Or if data has been loaded to display
 Subclasses should implement
 */
- (BOOL)dataIsAvailable;
- (BOOL)dataIsLoading;
- (BOOL)dataDidError;

/**
 Tell the state machine to either show a loading/empty view or show data
 */
- (void)updateState;

/**
 Initiates loading of the dataSource
 */
- (void)setupDataSource;
- (void)restoreDataSource; // Restore view after it gets unloaded
- (void)reloadDataSource; // Refresh
- (void)loadDataSource; // Initial Load
- (void)dataSourceShouldLoadObjects:(id)objects shouldAnimate:(BOOL)shouldAnimate;
- (void)dataSourceShouldLoadObjects:(id)objects sortBy:(NSString *)sortBy ascending:(BOOL)ascending shouldAnimate:(BOOL)shouldAnimate;
- (void)dataSourceShouldLoadMoreObjects:(id)objects forSection:(NSInteger)section shouldAnimate:(BOOL)shouldAnimate;
- (void)dataSourceDidLoad;
- (void)dataSourceDidLoadMore;
- (void)dataSourceDidError;

/**
 Used by tableView to page in more data
 */
- (void)loadMore;
- (BOOL)shouldLoadMore;

/**
 Used to configure the view right after it is loaded
 */
- (UIView *)navigationTitleView;
- (UIView *)baseBackgroundView;
- (UIView *)rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected;

/**
 Remotely fetch data
 */
- (void)fetchDataSource;

/**
 Local fetch data
 */
- (void)dataSourceDidFetch;

@end