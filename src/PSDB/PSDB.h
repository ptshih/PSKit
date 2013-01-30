//
//  PSDB.h
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import <Foundation/Foundation.h>

@interface PSDB : NSObject

@property (nonatomic, assign) BOOL shouldSyncWithRemote;

// Singleton
+ (id)sharedDatabase;

// Persistence
- (void)syncDatabase;
- (void)syncDatabaseWithRemote;
- (BOOL)resetDatabase;

// Retrieve a collection, if it doesn't exist, create one
- (NSMutableDictionary *)collectionWithName:(NSString *)name;

// Documents
- (void)findDocumentsInCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableArray *documents))completionBlock;
- (void)findOneDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *document))completionBlock;
- (void)saveDocument:(NSMutableDictionary *)document forKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *savedDocument))completionBlock;
- (void)deleteDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)())completionBlock;

@end
