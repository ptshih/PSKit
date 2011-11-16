//
//  NSDate+PSKit.h
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PSKit)

#pragma mark - Other
+ (NSInteger)minutesSinceBeginningOfWeek;

#pragma mark - Facebook
+ (NSDate *)dateFromFacebookTimestamp:(NSString *)timestamp;

#pragma mark - AWS
- (NSString *)stringWithAWSRequestFormat;

#pragma mark - Milliseconds
+ (NSDate *)dateWithMillisecondsSince1970:(NSTimeInterval)millisecondsSince1970;
- (NSTimeInterval)millisecondsSince1970;

@end
