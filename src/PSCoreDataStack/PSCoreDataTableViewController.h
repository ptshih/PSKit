//
//  PSCoreDataTableViewController.h
//  Orca
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PSTableViewController.h"
#import "PSCoreDataStack.h"

typedef enum {
  FetchTypeCold = 0,
  FetchTypeRefresh = 1,
  FetchTypeLoadMore = 2
} FetchType;

@interface PSCoreDataTableViewController : PSTableViewController <NSFetchedResultsControllerDelegate> {  
  NSManagedObjectContext *_context;
  NSFetchedResultsController * _fetchedResultsController;
  NSString * _sectionNameKeyPathForFetchedResultsController;
  NSTimer *_searchTimer;
  NSPredicate *_searchPredicate;
  NSInteger _fetchLimit;
  NSInteger _fetchTotal;
  BOOL _isFetching;
  id _frcDelegate;
}

@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, retain) NSString * sectionNameKeyPathForFetchedResultsController;
@property (nonatomic, retain) NSPredicate *searchPredicate;


- (void)delayedFilterContentWithTimer:(NSTimer *)timer;

- (void)resetFetchedResultsController;
- (void)executeFetch:(FetchType)fetchType;
- (void)executeFetchOnMainThread;
- (void)executeSearchOnMainThread;
- (NSFetchRequest *)getFetchRequestInContext:(NSManagedObjectContext *)context;
- (void)coreDataDidReset;

@end
