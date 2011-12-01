//
//  NSString+PSKit.h
//  PSKit
//
//  Created by Peter Shih on 6/21/11.
//  Copyright (c) 2011 Peter Shih.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (PSKit)

#pragma mark - UUID
+ (NSString *)stringFromUUID;

#pragma mark - MIME
+ (NSString *)MIMETypeForExtension:(NSString *)extension;

#pragma mark - JSON
- (BOOL)notNull;

#pragma mark - URL Encoding
- (NSString *)stringByURLEncoding;
- (NSString *)stringByEscapingQuery;
- (NSString *)stringWithPercentEscape;

#pragma mark - HTML
- (NSString *)stringByEscapingHTML;
- (NSString *)stringByUnescapingHTML;

#pragma mark - MD5
- (NSString *)stringFromMD5Hash;

@end
