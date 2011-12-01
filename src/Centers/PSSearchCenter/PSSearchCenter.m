//
//  PSSearchCenter.m
//  PSKit
//
//  Created by Peter Shih on 7/12/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSSearchCenter.h"

static NSString *_savedPath = nil;

@implementation PSSearchCenter

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

+ (void)initialize {
  _savedPath = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:PS_SEARCH_CENTER_PLIST] retain];
}

- (id)init {
  self = [super init];
  if (self) {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_savedPath];
    if (fileExists) {
      NSError *error = nil;
      NSData *termsData = [NSData dataWithContentsOfFile:_savedPath];
      _terms = [[NSMutableDictionary dictionaryWithDictionary:[NSPropertyListSerialization propertyListWithData:termsData options:0 format:NULL error:&error]] retain];
    } else {
      _terms = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
  }
  return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_terms);
  [super dealloc];
}

#pragma mark - Terms
- (NSArray *)searchResultsForTerm:(NSString *)term inContainer:(NSString *)container {
  // Load container, if no container return empty array
  NSMutableDictionary *containerDict = [_terms objectForKey:container];
  if (!containerDict) return [NSArray array];
  
  NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", term];
  NSArray *sortedKeys = [containerDict keysSortedByValueUsingComparator:^(id obj1, id obj2) {
    // DESCENDING
    if ([obj1 integerValue] < [obj2 integerValue]) {
      return (NSComparisonResult)NSOrderedDescending;
    } else if ([obj1 integerValue] > [obj2 integerValue]) {
      return (NSComparisonResult)NSOrderedAscending;
    } else {
      return (NSComparisonResult)NSOrderedSame;
    }
  }];
  
  return [sortedKeys filteredArrayUsingPredicate:searchPredicate];
}

- (BOOL)addTerm:(NSString *)term inContainer:(NSString *)container {
  // Load Container or create if not exist
  NSMutableDictionary *containerDict = [_terms objectForKey:container];
  if (!containerDict) {
    containerDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [_terms setObject:containerDict forKey:container];
  } else {
    containerDict = [NSMutableDictionary dictionaryWithDictionary:containerDict];
  }
  
  id val = nil;
  val = [containerDict objectForKey:term];
  if (val) {
    NSUInteger count = [val integerValue] + 1;
    [containerDict setObject:[NSNumber numberWithInteger:count] forKey:term];
  } else {
    [containerDict setObject:[NSNumber numberWithInteger:1] forKey:term];
  }
  
  [_terms setObject:containerDict forKey:container];
  
  // Write to disk
  NSError *error = nil;
  NSData *termsData = [NSPropertyListSerialization dataWithPropertyList:_terms format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
  
  return [termsData writeToFile:_savedPath atomically:YES];
}

- (void)resetTerms {
  for (NSMutableDictionary *container in [_terms allValues]) {
    [container removeAllObjects];
  }
}

@end
