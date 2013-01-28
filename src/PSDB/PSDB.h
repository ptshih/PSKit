//
//  PSDB.h
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import <Foundation/Foundation.h>

@interface PSDB : NSObject

+ (id)sharedDatabase;

// Persistence
- (void)syncCollections;

// Collections
- (NSMutableArray *)documentsForCollection:(NSString *)collectionName;

// Documents
- (void)findDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *document))completionBlock;
- (void)saveDocument:(NSMutableDictionary *)document forKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *savedDocument))completionBlock;
- (void)deleteDocumentForKey:(NSString *)key inCollection:(NSString *)collection completionBlock:(void (^)())completionBlock;
//- (BOOL)insertDocument:(NSDictionary *)document forCollection:(NSString *)collection;
//- (BOOL)updateDocument:(NSDictionary *)document forCollection:(NSString *)collection;


@end
