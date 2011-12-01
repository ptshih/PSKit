//
//  PSCoreDataStack.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface PSCoreDataStack : NSObject {

}

+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSManagedObjectContext *)newManagedObjectContext; // returns retained context
+ (NSManagedObjectContext *)mainThreadContext; // shared static context

// Persistent Store
+ (void)resetPersistentStoreCoordinator;
+ (void)deleteAllObjects:(NSString *)entityDescription inContext:(NSManagedObjectContext *)context;
+ (void)saveMainThreadContext;
+ (void)saveInContext:(NSManagedObjectContext *)context;
+ (void)resetInContext:(NSManagedObjectContext *)context;

+ (NSURL *)applicationDocumentsDirectory;

@end
