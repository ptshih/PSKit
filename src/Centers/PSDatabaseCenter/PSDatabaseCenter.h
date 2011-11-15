//
//  PSDatabaseCenter.h
//  MealTime
//
//  Created by Peter Shih on 8/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "EGODatabase.h"

@interface PSDatabaseCenter : PSObject {
  EGODatabase *_database;
}

+ (id)defaultCenter;

- (EGODatabase *)database;

@end
