//
//  PSDB.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

// Build this into a JsonDB singleton
// It should detect any mutations and try to sync with cloud
// If no connection, it should try to sync next time available
// Merge-rules: always take sync with most recent timestamp

#import "PSDB.h"

@interface PSDB ()

// Serial transaction queue to ensure only one operation happens at once
@property (nonatomic, strong) NSOperationQueue *transactions;
@property (nonatomic, strong) NSMutableDictionary *database;

// Persistence
- (NSString *)databasePath;
- (void)updateTimestamp;

@end


@implementation PSDB

+ (id)sharedDatabase {
    static id sharedDatabase;
    if (!sharedDatabase) {
        sharedDatabase = [[self alloc] init];
    }
    return sharedDatabase;
}

- (id)init {
    if (self = [super init]) {
        self.transactions = [[NSOperationQueue alloc] init];
        self.transactions.maxConcurrentOperationCount = 1;
        
        [self syncDatabase];
    }
    return self;
}

- (void)dealloc {
}

#pragma mark - Collections

- (NSMutableDictionary *)collectionWithName:(NSString *)name {
    NSMutableDictionary *collection = [self.database objectForKey:name];
    if (!collection) {
        collection = [NSMutableDictionary dictionary];
        [self.database setObject:collection forKey:name];
    }
    return collection;
}

#pragma mark - Documents

- (void)findDocumentsInCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableArray *documents))completionBlock {
    if (!collectionName) return;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        
        NSArray *keys = [[collection allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
        
        NSMutableArray *documents = [NSMutableArray array];
        for (NSString *key in keys) {
            [documents addObject:[NSJSONSerialization JSONObjectWithData:[[collection objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]];
        }
        
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(documents);
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

- (void)findOneDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *document))completionBlock {
    if (!key || !collectionName) return;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        NSString *json = [collection objectForKey:key];
        
        NSMutableDictionary *document = nil;
        
        if (json) {
            document = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        }
        
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(document);
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

- (void)saveDocument:(NSMutableDictionary *)document forKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *savedDocument))completionBlock {
    if (!document || !collectionName) return;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        // Write the document _id key
        // If a key is passed in, No-Op
        // If no key is passed in, generate a new key based on timestamp
        NSString *documentKey = key ? key : [NSString stringWithFormat:@"%0.f", [[NSDate date] millisecondsSince1970]];
        [document setObject:documentKey forKey:@"_id"];
        
        // Write to the document
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        NSString *json = [NSJSONSerialization stringWithJSONObject:document options:0 error:nil];
        [collection setObject:json forKey:documentKey];
        
        // Update the DB last modified timestamp
        [self updateTimestamp];
        
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(document);
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

- (void)deleteDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)())completionBlock {
    if (!key || !collectionName) return;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        // Delete the document with a given key
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        [collection removeObjectForKey:key];
        
        // Update the DB last modified timestamp
        [self updateTimestamp];
        
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock();
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

#pragma mark - Persistence

- (NSString *)databasePath {
    NSString *baseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *databasePath = [baseDirectory stringByAppendingPathComponent:@"psdb.plist"];
    return databasePath;
}

- (void)updateTimestamp {
    [self.database setObject:[[NSNumber numberWithDouble:[[NSDate date] millisecondsSince1970]] stringValue] forKey:@"timestamp"];
}

- (void)syncDatabase {
    NSData *dbData = nil;
    if (self.database) {
        dbData = [NSPropertyListSerialization dataFromPropertyList:self.database format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
        [dbData writeToFile:[self databasePath] atomically:YES];
    } else {
        dbData = [NSData dataWithContentsOfFile:[self databasePath]];
        NSPropertyListFormat format;
        self.database = [NSPropertyListSerialization propertyListFromData:dbData mutabilityOption:NSPropertyListMutableContainers format:&format errorDescription:nil];
    }
}

@end
