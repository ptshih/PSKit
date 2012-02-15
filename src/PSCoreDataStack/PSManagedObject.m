//
//  PSManagedObject.m
//  Linsanity
//
//  Created by Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSManagedObject.h"

@implementation PSManagedObject

+ (BOOL)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc entity:(NSDictionary *)entity uniqueKey:(NSString *)uniqueKey {
    NSString *entityName = NSStringFromClass([self class]);
    NSString *newUniqueKey = [entity objectForKey:uniqueKey];
    
    // Find existing Entity
    NSFetchRequest *existingFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [existingFetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [existingFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K == %@)", uniqueKey, newUniqueKey]];
    
    NSError *error = nil;
    NSArray *foundEntities = [moc executeFetchRequest:existingFetchRequest error:&error];
    id existingEntity = nil;
    id newEntity = nil;
    if (foundEntities && [foundEntities count] > 0) {
        existingEntity = [foundEntities lastObject];
    }
    
    if (existingEntity) {
        // Update
        newEntity = existingEntity;
    } else {
        newEntity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
    }
    // Set properties
    [newEntity updateAttributesWithDictionary:entity];
    
    // TODO
    return YES;
}

+ (BOOL)updateOrInsertInManagedObjectContext:(NSManagedObjectContext *)moc entities:(NSArray *)entities uniqueKey:(NSString *)uniqueKey {
    NSString *entityName = NSStringFromClass([self class]);
    NSArray *uniqueKeyArray = [entities valueForKey:uniqueKey];
    
    // Find all existing Entities
    NSFetchRequest *existingFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
    [existingFetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [existingFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", uniqueKey, uniqueKeyArray]];
//    [existingFetchRequest setPropertiesToFetch:[NSArray arrayWithObject:uniqueKey]];
    
    NSError *error = nil;
    NSArray *foundEntities = [moc executeFetchRequest:existingFetchRequest error:&error];
    
    // Create a dictionary of existing entities
    NSMutableDictionary *existingEntities = nil;
    if (foundEntities && [foundEntities count] > 0) {
        // Found existing entities, create a look-up-table
        existingEntities = [NSMutableDictionary dictionary];
        [foundEntities enumerateObjectsUsingBlock:^(id entity, NSUInteger idx, BOOL *stop) {
            [existingEntities setObject:entity forKey:[entity valueForKey:uniqueKey]]; 
        }];
    }
    
    // Insert or update new entities
    __block id existingEntity = nil;
    __block id newEntity = nil;
    [entities enumerateObjectsUsingBlock:^(id entity, NSUInteger idx, BOOL *stop) {
        NSString *newUniqueKey = [entity objectForKey:uniqueKey];
        existingEntity = [existingEntities objectForKey:newUniqueKey];
        if (existingEntity) {
            // Update
            newEntity = existingEntity;
        } else {
            newEntity = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
        }
        // Set properties
        [newEntity updateAttributesWithDictionary:entity];
        
        // Reset
        newEntity = nil;
        existingEntity = nil;
    }];
    
    return YES;
}

- (void)updateAttributesWithDictionary:(NSDictionary *)dictionary {
    // subclass MUST implement
}


@end
