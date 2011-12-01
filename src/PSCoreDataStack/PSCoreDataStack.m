//
//  PSCoreDataStack.m
//  PSKit
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSCoreDataStack.h"

static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;
static NSManagedObjectModel *_managedObjectModel = nil;
static NSManagedObjectContext *_mainThreadContext = nil;

static NSDictionary *_storeOptions = nil;
static NSURL *_storeURL = nil;

@interface PSCoreDataStack (Private)

+ (void)resetStoreState;
+ (NSString *)applicationDocumentsDirectory;

@end

@implementation PSCoreDataStack

#pragma mark Initialization Methods
+ (void)initialize {  
  _storeOptions = [[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] retain];
  _storeURL = [[[[self class] applicationDocumentsDirectory] URLByAppendingPathComponent:CORE_DATA_SQL_FILE] retain];
}

+ (void)deleteAllObjects:(NSString *)entityDescription inContext:(NSManagedObjectContext *)context {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:context];
  [fetchRequest setEntity:entity];
  
  NSError *error;
  NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  
  for (NSManagedObject *managedObject in items) {
    [[[self class] mainThreadContext] deleteObject:managedObject];
  }
  if (![[[self class] mainThreadContext] save:&error]) {
  }
}

+ (void)resetStoreState {
  NSArray *stores = [_persistentStoreCoordinator persistentStores];
  
  for(NSPersistentStore *store in stores) {
    [_persistentStoreCoordinator removePersistentStore:store error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
  }
  
  [_managedObjectModel release];
  [_persistentStoreCoordinator release];
  _managedObjectModel = nil;
  _persistentStoreCoordinator = nil;
}

#pragma mark Core Data Accessors
// shared static context
+ (NSManagedObjectContext *)mainThreadContext {
  NSAssert([NSThread isMainThread], @"mainThreadContext must be called from the main thread");
  
  if (_mainThreadContext != nil) {
    return _mainThreadContext;
  }
  
  // Use main thread
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  if (coordinator != nil) {
    _mainThreadContext = [[NSManagedObjectContext alloc] init];
    [_mainThreadContext setPersistentStoreCoordinator:coordinator];
  }
  
  [_mainThreadContext setUndoManager:nil];
  
  return _mainThreadContext;
}

// returns a new retained context
+ (NSManagedObjectContext *)newManagedObjectContext {
  // Called on requesting thread
  
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  NSManagedObjectContext *context = nil;
  if (coordinator != nil) {
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
  }
  [context setUndoManager:nil];
  
  // not autoreleased
  return context;
}

#pragma mark Save
+ (void)saveMainThreadContext {
  NSError *error = nil;
  if ([_mainThreadContext hasChanges] && ![_mainThreadContext save:&error]) {
    abort(); // NOTE: DO NOT SHIP
  }
}

+ (void)saveInContext:(NSManagedObjectContext *)context {
  NSError *error = nil;
  if ([context hasChanges] && ![context save:&error]) {
    abort(); // NOTE: DO NOT SHIP
  }
}

+ (void)resetInContext:(NSManagedObjectContext *)context {
  [context reset];
}

#pragma mark Accessors
+ (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSURL *modelURL = [[NSBundle mainBundle] URLForResource:CORE_DATA_MOM withExtension:@"momd"];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
  
  return _managedObjectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if(_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  NSError *error = nil;
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:_storeOptions error:&error]) {
    NSLog(@"Epic Fail creating persistent store %@, %@", error, [error userInfo]);
    
    // Reset the store, something happened
    [[self class] resetPersistentStoreCoordinator];
    
    // Let's just crash and have the user relaunch
    abort();
  }
  
  return _persistentStoreCoordinator;
}

+ (void)resetPersistentStoreCoordinator {
  [_mainThreadContext release], _mainThreadContext = nil;
  
  [_persistentStoreCoordinator release];
  _persistentStoreCoordinator = nil;
  
  if (_storeURL) {
    [[NSFileManager defaultManager] removeItemAtURL:_storeURL error:nil];
  }
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataDidReset object:nil];
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
+ (NSURL *)applicationDocumentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
