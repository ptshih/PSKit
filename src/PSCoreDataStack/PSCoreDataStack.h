//
//  PSCoreDataStack.h
//  PSKit
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define CORE_DATA_MOM @"YourCoreDataMoM"
#define CORE_DATA_SQL_FILE @"your_core_data_mom_file.sqlite"

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
