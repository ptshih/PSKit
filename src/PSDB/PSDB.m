//
//  PSDB.m
//  Check
//
//  Created by Peter Shih on 1/27/13.
//
//

#import "PSDB.h"

@interface PSDB ()

// Serial transaction queue to ensure only one operation happens at once
@property (nonatomic, strong) NSOperationQueue *transactions;
@property (nonatomic, strong) NSMutableDictionary *database;

// Retrieve a collection, if it doesn't exist, create one
- (NSMutableDictionary *)collectionWithName:(NSString *)name;

@end

@implementation PSDB

// Build this into a JsonDB singleton
// It should detect any mutations and try to sync with cloud
// If no connection, it should try to sync next time available
// Merge-rules: always take sync with most recent timestamp

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
        
        self.database = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
}

// Persistence

- (void)syncCollections {
    // TBD
}


// Collections

- (NSMutableDictionary *)collectionWithName:(NSString *)name {
    NSMutableDictionary *collection = [self.database objectForKey:name];
    if (!collection) {
        collection = [NSMutableDictionary dictionary];
        [self.database setObject:collection forKey:name];
    }
    return collection;
}


- (NSMutableArray *)documentsForCollection:(NSString *)collectionName {
    NSMutableDictionary *collection = [self collectionWithName:collectionName];
    
    NSArray *keys = [[collection allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO]]];
    
    NSMutableArray *documents = [NSMutableArray array];
    for (NSString *key in keys) {
        [documents addObject:[NSJSONSerialization JSONObjectWithData:[[collection objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]];
    }
    
    return documents;
}


// Documents

- (void)findDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *document))completionBlock {
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
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        if (![document objectForKey:@"_id"]) {
            [document setObject:key forKey:@"_id"];
        }
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        NSString *json = [NSJSONSerialization stringWithJSONObject:document options:0 error:nil];
        [collection setObject:json forKey:key];
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(document);
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

- (void)deleteDocumentForKey:(NSString *)key inCollection:(NSString *)collection completionBlock:(void (^)())completionBlock {
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [[self.database objectForKey:collection] removeObjectForKey:key];
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock();
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

@end
