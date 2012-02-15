//
//  NSMutableURLRequest+PSKit.h
//  Linsanity
//
//  Created by Peter on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *FSURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding);
extern NSString *FSQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding encoding);

@interface NSMutableURLRequest (FS)

+ (NSMutableURLRequest *)requestWithURL:(NSURL *)URL method:(NSString *)method headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters;

+ (NSMutableURLRequest *)requestWithFoursquareEndpoint:(NSString *)endpoint method:(NSString *)method headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters;

// Convenience Methods
- (NSString *)HTTPBodyString;
- (NSDictionary *)requestParameters;

@end
