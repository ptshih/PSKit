//
//  NSMutableURLRequest+PSKit.h
//  PSKit
//
//  Created by Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *PSURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding);
extern NSString *PSQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding encoding);

@interface NSMutableURLRequest (PS)

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters;

// Convenience Methods
- (NSString *)HTTPBodyString;
- (NSDictionary *)requestParameters;

@end
