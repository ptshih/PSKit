//
//  PSCoreDataTableViewController.h
//  Orca
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTableViewController.h"
#import "PSCoreDataStack.h"

@interface PSCoreDataTableViewController : PSTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain, readonly) NSManagedObjectContext *moc;
@property (nonatomic, retain, readonly) NSFetchedResultsController *frc;
@property (nonatomic, readonly) NSString *frcCacheName;
@property (nonatomic, readonly) NSFetchRequest *fetchRequest;
@property (nonatomic, readonly) NSPredicate *fetchPredicate;
@property (nonatomic, readonly) NSArray *fetchSortDescriptors;
@property (nonatomic, readonly) NSString *sectionNameKeyPath;

@end
