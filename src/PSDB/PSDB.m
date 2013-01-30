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
        self.shouldSyncWithRemote = YES;
        
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

        NSMutableArray *documents = [NSMutableArray array];
        [collection enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [documents addObject:obj];
        }];
        
        [documents sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"modified" ascending:NO]]];
                
        if (completionBlock) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completionBlock(documents);
            }];
        }
    }];
    
    [self.transactions addOperation:op];
}

- (void)findOneDocumentForKey:(NSString *)key inCollection:(NSString *)collectionName completionBlock:(void (^)(NSMutableDictionary *document))completionBlock {
    if (!collectionName) return;
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        
        NSMutableDictionary *document = [collection objectForKey:key];
        
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
        BOOL isNew = key ? NO : YES;
        
        // Write the document id key
        // If a key is passed in, No-Op
        // If no key is passed in, generate a new key based on timestamp
        NSString *uuid = [NSString stringFromUUID];
        NSString *documentKey = key ? key : uuid;
        [document setObject:documentKey forKey:@"id"];
        
        // Created/Modified Timestamps
        if (isNew) {
            [document setObject:[self timestampString] forKey:@"created"];
         }
        [document setObject:[self timestampString] forKey:@"modified"];
        
        // Write to the document
        NSMutableDictionary *collection = [self collectionWithName:collectionName];
        [collection setObject:document forKey:documentKey];
        
        // Sync the DB to file
        [self syncDatabase];
        
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
        
        // Sync the DB to file
        [self syncDatabase];
        
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

- (NSString *)timestampString {
    return [[NSNumber numberWithDouble:[[NSDate date] millisecondsSince1970]] stringValue];
}

- (NSString *)databaseJsonRepresentation {
    return [NSJSONSerialization stringWithJSONObject:self.database options:0 error:nil];
}

- (void)syncDatabase {
    NSData *dbData = nil;
    
    if (!self.database) {
        // Try to read from file
        dbData = [NSData dataWithContentsOfFile:[self databasePath]];
        NSPropertyListFormat format;
        self.database = [NSPropertyListSerialization propertyListFromData:dbData mutabilityOption:NSPropertyListMutableContainers format:&format errorDescription:nil];
        
        // If no file, create a new db
        if (!self.database) {
            self.database = [NSMutableDictionary dictionary];
            NSString *uuid = [NSString stringFromUUID];
            [self.database setObject:uuid forKey:@"id"];
        }
    }
    
    // Update timestamp and write to file
    [self.database setObject:[self timestampString] forKey:@"timestamp"];
    dbData = [NSPropertyListSerialization dataFromPropertyList:self.database format:NSPropertyListBinaryFormat_v1_0 errorDescription:nil];
    [dbData writeToFile:[self databasePath] atomically:YES];
}

- (void)syncDatabaseWithRemote {
    // Send local copy up to server
    // Server determines if local or remote copy is newer
    // Server sends back newer copy
    // Local is overwritten with copy the server sends back
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[self databaseJsonRepresentation] forKey:@"database"];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/sync", API_BASE_URL]];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url method:@"POST" headers:headers parameters:parameters];
        
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        // Handle HTTP response codes
        if ([response isKindOfClass:[NSHTTPURLResponse class]] && response.statusCode != 200) {
            error = [NSError errorWithDomain:@"PSURLCacheErrorDomain" code:response.statusCode userInfo:nil];
        }
        
        NSMutableDictionary *downloadedDatabase = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (downloadedDatabase) {
            self.database = downloadedDatabase;
        }
    }];
    
    [self.transactions addOperation:op];
}

- (BOOL)resetDatabase {
    NSString *databasePath = [self databasePath];
    NSError *error;
    return [[NSFileManager defaultManager] removeItemAtPath:databasePath error:&error];
}

@end
