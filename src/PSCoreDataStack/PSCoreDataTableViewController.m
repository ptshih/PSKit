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

@synthesize
moc = _moc,
frc = _frc,
frcCacheName = _frcCacheName,
fetchRequest = _fetchRequest,
fetchPredicate = _fetchPredicate,
fetchSortDescriptors = _fetchSortDescriptors,
sectionNameKeyPath = _sectionNameKeyPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChangesFromContextDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
  }
  return self;
}

- (void)dealloc {
    RELEASE_SAFELY(_moc);
    RELEASE_SAFELY(_frc);
//  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    [super dealloc];
}

#pragma mark State Machine
- (BOOL)dataIsAvailable {
  return (self.frc && self.frc.fetchedObjects.count > 0);
}

- (BOOL)dataIsLoading {
  return _reloading;
}

- (void)updateState {
  [super updateState];
}

#pragma mark Data Source
- (void)dataSourceDidFetch {
  // subclass may optionally implement
  // this is called after a COLD local fetch happens
  // a good reason to implement this is to initiate a refresh from remote here
}


#pragma mark - Getters
- (NSManagedObjectContext *)moc {
    if (!_moc) {
        // Each controller should have its own MOC
        _moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        // The MOC should use the global persistent store
        [_moc setPersistentStoreCoordinator:[PSCoreDataStack persistentStoreCoordinator]];
    }
    return _moc;
}

- (NSFetchedResultsController *)frc {
    if (!_frc) {
        _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.moc sectionNameKeyPath:self.sectionNameKeyPath cacheName:self.frcCacheName];
        _frc.delegate = self;
    }
    return _frc;
}

// Subclass MUST implement
- (NSFetchRequest *)fetchRequest {
    return nil;
}

// Subclass MAY OPTIONALLY implement
- (NSString *)frcCacheName {
    return nil;
}

- (NSPredicate *)fetchPredicate {
    return nil;
}

- (NSArray *)fetchSortDescriptors {
    return nil;
}

- (NSString *)sectionNameKeyPath {
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

#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.frc sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[self.frc sections] objectAtIndex:section] numberOfObjects];
}

@end
