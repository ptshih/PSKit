//
//  NSJSONSerialization+PSKit.m
//  Phototime
//
//  Created by Peter on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSJSONSerialization+PSKit.h"

@implementation NSJSONSerialization (PSKit)

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    NSString *string = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:error];
    string = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    return string;
}

@end
