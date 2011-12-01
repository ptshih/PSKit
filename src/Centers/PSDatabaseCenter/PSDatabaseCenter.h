//
//  PSDatabaseCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/28/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGODatabase.h"

// SQLite DB filename
#define SQLITE_DB_SCHEMA_VERSION @"1"
#define SQLITE_DB_NAME @"Rolodex_1"

@interface PSDatabaseCenter : PSObject {
  EGODatabase *_database;
}

+ (id)defaultCenter;

- (EGODatabase *)database;

@end
