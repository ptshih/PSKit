//
//  NSURL+PSKit.m
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import "NSURL+PSKit.h"


@implementation NSURL (PSKit)

- (NSURL *)URLByRemovingQuery {
  NSMutableString *URLString = [NSMutableString stringWithFormat:@"%@://", [self scheme]];
  
  if ([self user] && [self password]) [URLString appendFormat:@"%@:%@@", [self user], [self password]];
  
  if ([self host]) {
    [URLString appendString:[self host]];
  }
  if ([self port]) {
    [URLString appendFormat:@":%d", [[self port] integerValue]];
  }
  if ([self path]) {
    [URLString appendString:[self path]];
  }
  //  if (query) {
  //    [URLString appendFormat:@"?%@", query];
  //  }
  //  if ([self fragment]) {
  //    [URLString appendFormat:@"#%@", [self fragment]];
  //  }
  return [NSURL URLWithString:URLString];
}

@end
