//
//  PSManagedObject.h
//  Linsanity
//
//  Created by Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PSManagedObject : NSManagedObject

+ (BOOL)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc entity:(NSDictionary *)entity uniqueKey:(NSString *)uniqueKey;
+ (BOOL)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc entities:(NSArray *)entities uniqueKey:(NSString *)uniqueKey;
- (void)updateAttributesWithDictionary:(NSDictionary *)dictionary;

@end
