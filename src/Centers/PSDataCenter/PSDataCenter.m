//
//  PSDataCenter.m
//  PhotoTime
//
//  Created by Peter Shih on 2/22/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "PSDataCenter.h"

@interface PSDataCenter (Private)

- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys;
- (NSArray *)sanitizeArray:(NSArray *)array;

@end

@implementation PSDataCenter

@synthesize delegate = _delegate;

// SUBCLASSES MUST IMPLEMENT
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
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark -
#pragma mark Private Convenience Methods
- (NSArray *)sanitizeArray:(NSArray *)array {
  NSMutableArray *sanitizedArray = [NSMutableArray array];
  
  // Loop thru all dictionaries in the array
  NSDictionary *sanitizedDictionary = nil;
  for (id value in array) {
    if ([value isKindOfClass:[NSDictionary class]]) {
      sanitizedDictionary = [self sanitizeDictionary:value forKeys:[value allKeys]];
      [sanitizedArray addObject:sanitizedDictionary];
    } else {
      [sanitizedArray addObject:value];
    }
  }
  
  return sanitizedArray;
}

- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys {
  NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionary];
  
  // Loop thru all keys we expect to get and remove any keys with nil values
  NSString *value = nil;
  for (NSString *key in keys) {
    value = [dictionary valueForKey:key];
    
    if ([value notNil]) {
      if ([value isKindOfClass:[NSArray class]]) {
        [sanitizedDictionary setValue:[self sanitizeArray:(NSArray *)value] forKey:key];
      } else if ([value isKindOfClass:[NSDictionary class]]) {
        [sanitizedDictionary setValue:[self sanitizeDictionary:(NSDictionary *)value forKeys:[(NSDictionary *)value allKeys]] forKey:key];
      } else {
        [sanitizedDictionary setValue:value forKey:key];
      }
    }
  }
  
  return sanitizedDictionary;
}

- (NSString *)buildRequestParamsString:(NSDictionary *)params {
  if (!params) return nil;
  
  NSMutableString *encodedParameterPairs = [NSMutableString string];
  
  NSArray *allKeys = [params allKeys];
  NSArray *allValues = [params allValues];
  
  for (int i = 0; i < [params count]; i++) {
    NSString *key = [[NSString stringWithFormat:@"%@", [allKeys objectAtIndex:i]] stringByURLEncoding];
    NSString *value = [[NSString stringWithFormat:@"%@", [allValues objectAtIndex:i]] stringByURLEncoding];
    [encodedParameterPairs appendFormat:@"%@=%@", key, value];
    if (i < [params count] - 1) {
      [encodedParameterPairs appendString:@"&"];
    }
  }
  
  return encodedParameterPairs;
}

- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params {
  return [NSMutableData dataWithData:[[self buildRequestParamsString:params] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
}

@end
