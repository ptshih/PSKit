//
//  NSJSONSerialization+PSKit.h
//  Linsanity
//
//  Created by Peter on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>

@interface NSJSONSerialization (PSKit)

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;


@end