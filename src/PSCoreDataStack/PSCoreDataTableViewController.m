//
//  PSCoreDataTableViewController.m
//  Orca
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSCoreDataTableViewController.h"

@interface PSCoreDataTableViewController (Private)


@end

@implementation PSCoreDataTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize sectionNameKeyPathForFetchedResultsController = _sectionNameKeyPathForFetchedResultsController;
@synthesize searchPredicate = _searchPredicate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _context = nil;
    _fetchedResultsController = nil;
    _sectionNameKeyPathForFetchedResultsController = nil;
    _fetchLimit = 25;
    _fetchTotal = _fetchLimit;
    _isFetching = NO;
    _frcDelegate = self;
    
    [self resetFetchedResultsController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changesSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
  }
  return self;
}

#pragma mark State Machine
- (BOOL)dataIsAvailable {
  return (_fetchedResultsController && _fetchedResultsController.fetchedObjects.count > 0);
}

- (BOOL)dataIsLoading {
  return _isFetching || _reloading;
}

- (void)updateState {
  [super updateState];
}

#pragma mark Data Source
- (void)loadMore {
  [super loadMore];
  
  // Load more
  _fetchTotal += _fetchLimit;
  [[[self fetchedResultsController] fetchRequest] setFetchLimit:_fetchTotal];
  [self executeFetch:FetchTypeLoadMore];
}

- (void)dataSourceDidFetch {
  // subclass may optionally implement
  // this is called after a COLD local fetch happens
  // a good reason to implement this is to initiate a refresh from remote here
}

#pragma mark Core Data
- (void)changesSaved:(NSNotification *)notification {
  [self performSelectorOnMainThread:@selector(changesSavedOnMainThread:) withObject:notification waitUntilDone:YES];
}

- (void)changesSavedOnMainThread:(NSNotification *)notification {
  if ([notification object] != _context) {
    [_context mergeChangesFromContextDidSaveNotification:notification];
  }
}

- (void)resetFetchedResultsController {
  RELEASE_SAFELY(_fetchedResultsController);
  
  // Use main thread context here
  _context = [PSCoreDataStack mainThreadContext];
}

- (NSFetchedResultsController*)fetchedResultsController  {
  if (_fetchedResultsController) return _fetchedResultsController;
  NSFetchRequest *fr = [self getFetchRequestInContext:_context];
  
  _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fr managedObjectContext:_context sectionNameKeyPath:self.sectionNameKeyPathForFetchedResultsController cacheName:nil];
  _fetchedResultsController.delegate = _frcDelegate;
  
  return _fetchedResultsController;
}

- (void)executeFetch:(FetchType)fetchType {
  _isFetching = YES;
  
  if (fetchType == FetchTypeCold) {
    _hasMore = YES;
    _fetchTotal = _fetchLimit;
  }
  
  static dispatch_queue_t coreDataFetchQueue = nil;
  if (!coreDataFetchQueue) {
    coreDataFetchQueue = dispatch_queue_create("com.pskit.coreDataFetchQueue", NULL);
  }
  
  dispatch_async(coreDataFetchQueue, ^{
    NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
    NSError *error = nil;
    NSFetchRequest *backgroundFetch = [[self getFetchRequestInContext:context] copy];
    
    [backgroundFetch setResultType:NSManagedObjectIDResultType];
    //    [backgroundFetch setSortDescriptors:nil];
    NSPredicate *predicate = [backgroundFetch predicate];
    NSPredicate *combinedPredicate = nil;
    if (_searchPredicate) {
      if (predicate) {
//        combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, _searchPredicate, nil]];
        combinedPredicate = _searchPredicate;
      } else {
        combinedPredicate = _searchPredicate;
      }
      [backgroundFetch setPredicate:combinedPredicate];
    }
    
    NSArray *results = [context executeFetchRequest:backgroundFetch error:&error];
    
//    NSFetchRequest *countFetchRequest = [[NSFetchRequest alloc] init];
//    [countFetchRequest setEntity:backgroundFetch.entity];
//    NSUInteger count = [context countForFetchRequest:countFetchRequest error:nil];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (error) {
      [userInfo setObject:error forKey:@"error"];
    }
    if (results) {
      [userInfo setObject:results forKey:@"results"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      BOOL shouldReloadTable = NO;
      
//      NSLog(@"fetch count: %d", count);
    
      NSPredicate *originalPredicate = [[[self.fetchedResultsController.fetchRequest predicate] copy] autorelease];
      NSError *frcError = nil;
      NSPredicate *frcPredicate = [NSPredicate predicateWithFormat:@"self IN %@", results];
      [self.fetchedResultsController.fetchRequest setPredicate:frcPredicate];
      if ([self.fetchedResultsController performFetch:&frcError]) {
        VLog(@"Fetch request succeeded: %@", [self.fetchedResultsController fetchRequest]);
        switch (fetchType) {
          case FetchTypeCold:
            shouldReloadTable = YES;
            if ([_fetchedResultsController.fetchedObjects count] > 0 &&[_fetchedResultsController.fetchedObjects count] < _fetchLimit) {
              _hasMore = NO;
            }
            break;
          case FetchTypeLoadMore: {
            NSInteger newFetchedCount = [_fetchedResultsController.fetchedObjects count];
            if (_fetchTotal == newFetchedCount) {
              _hasMore = YES;
            } else {
              _hasMore = NO;
            }
            shouldReloadTable = YES;
            break;
          }
          case FetchTypeRefresh:
            shouldReloadTable = YES;
            break;
        }
        
        if (shouldReloadTable) {
          if (self.searchDisplayController.active) {
            [self.searchDisplayController.searchResultsTableView reloadData];
          } else {
            if ([self dataIsAvailable]) {
              [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(setShouldAnimate:) withObject:[NSNumber numberWithBool:NO]];
            }
            [_tableView reloadData];
            if ([self dataIsAvailable]) {
              [[self.tableView visibleCells] makeObjectsPerformSelector:@selector(setShouldAnimate:) withObject:[NSNumber numberWithBool:YES]];
            }
          }
        }
        _isFetching = NO;
        if (fetchType == FetchTypeLoadMore) {
          [self dataSourceDidLoadMore];
        } else if (fetchType == FetchTypeCold) {
          [self dataSourceDidFetch];
        } else {
          [self dataSourceDidLoad];
        }
      } else {
        VLog(@"Fetch failed with error: %@", [error localizedDescription]);
      }
      
      // Reset the FRC predicate so that it gets delegate callbacks
      [self.fetchedResultsController.fetchRequest setPredicate:originalPredicate];
      
      [context release];
      [backgroundFetch release];
      [userInfo release];
    });
  });
}

- (void)executeFetchOnMainThread {
  NSFetchRequest *newFetch = [[self getFetchRequestInContext:self.fetchedResultsController.managedObjectContext] copy];
  
  NSPredicate *predicate = [newFetch predicate];
  [self.fetchedResultsController.fetchRequest setPredicate:predicate];
  [newFetch release];
  
  NSError *frcError = nil;
  if ([self.fetchedResultsController performFetch:&frcError]) {
    VLog(@"Main Thread Fetch request succeeded: %@", [self.fetchedResultsController fetchRequest]);
  } else {
    VLog(@"Main Thread Fetch failed with error: %@", [frcError localizedDescription]);
  }
  
  if (self.searchDisplayController.active) {
    [self.searchDisplayController.searchResultsTableView reloadData];
  } else {
    [_tableView reloadData];
  }
  [self updateState];
}

- (void)executeSearchOnMainThread {
  [self.fetchedResultsController.fetchRequest setPredicate:_searchPredicate];
  
  NSError *frcError = nil;
  if ([self.fetchedResultsController performFetch:&frcError]) {
    VLog(@"Main Thread Search Fetch request succeeded: %@", [self.fetchedResultsController fetchRequest]);
  } else {
    VLog(@"Main Thread Search Fetch failed with error: %@", [frcError localizedDescription]);
  }
  
  [_tableView reloadData];
  [self updateState];
}

- (NSFetchRequest *)getFetchRequestInContext:(NSManagedObjectContext *)context {
  // Subclass MUST implement
  return nil;
}

#pragma mark NSFetchedresultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  
  UITableView *tableView = _tableView;
  
  DLog(@"type: %d, old indexPath: %@, new indexPath: %@, class: %@", type, indexPath, newIndexPath, NSStringFromClass([self class]));
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:{
      //      NSIndexPath *changedIndexPath = newIndexPath ? newIndexPath : indexPath;
      [self tableView:tableView configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
    }
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [_tableView endUpdates];
  [self updateState];
}

#pragma mark UISearchDisplayDelegate
- (void)delayedFilterContentWithTimer:(NSTimer *)timer {
  // SUBCLASS MUST IMPLEMENT
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  if (_searchTimer && [_searchTimer isValid]) {
    INVALIDATE_TIMER(_searchTimer);
  }
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:searchText, @"searchText", scope, @"scope", nil];
  _searchTimer = [[NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(delayedFilterContentWithTimer:) userInfo:userInfo repeats:NO] retain];
  [[NSRunLoop currentRunLoop] addTimer:_searchTimer forMode:NSDefaultRunLoopMode];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  [super searchDisplayControllerWillBeginSearch:controller];
//  [self executeFetch:FetchTypeCold];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
  [super searchDisplayControllerWillEndSearch:controller];
  _searchPredicate = nil;
  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
  [self executeFetchOnMainThread];
//  [self executeFetch:FetchTypeCold];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
  
  // Return NO if we are using coreData to background fetch (because we need to manually reload the table after the fetch is finished
  return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
  
  // Return NO if we are using coreData to background fetch (because we need to manually reload the table after the fetch is finished
  return NO;
}

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (void)coreDataDidReset {
  [self resetFetchedResultsController];
  if (self.searchDisplayController) {
    [self.searchDisplayController setActive:NO];
  }
  [self.tableView reloadData];
  [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kCoreDataDidReset object:nil];
  RELEASE_SAFELY(_fetchedResultsController);
  RELEASE_SAFELY(_sectionNameKeyPathForFetchedResultsController);
  RELEASE_SAFELY(_searchPredicate);
  INVALIDATE_TIMER(_searchTimer);
  [super dealloc];
}

@end
