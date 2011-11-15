//
//  PSDatabaseCenter.m
//  MealTime
//
//  Created by Peter Shih on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSDatabaseCenter.h"

@implementation PSDatabaseCenter

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    _database = [[EGODatabase databaseWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", SQLITE_DB]]] retain];
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

// Accessors
- (EGODatabase *)database {
  return _database;
}


@end
