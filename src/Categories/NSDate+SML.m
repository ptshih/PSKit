//
//  NSDate+SML.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 6/21/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "NSDate+SML.h"


@implementation NSDate (SML)

#pragma mark - Other
+ (NSInteger)minutesSinceBeginningOfWeek {
  NSInteger dayOfWeek = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:[NSDate date]] weekday];
  
  // Convert gregorian to american
   // Monday is start of week (not Sunday)
  dayOfWeek -= 1;
  if (dayOfWeek == 0) dayOfWeek = 7;
  
  // Calculate minutes since beginning of week to the beginning of today
  NSInteger minutes = (60 * 24 * (dayOfWeek - 1));
  NSInteger hoursSinceToday = [[[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]] hour];
  NSInteger minutesSinceToday = [[[NSCalendar currentCalendar] components:NSMinuteCalendarUnit fromDate:[NSDate date]] minute];
  minutesSinceToday += 60 * hoursSinceToday; // offset by 7hrs
  return minutes + minutesSinceToday;
}

#pragma mark - Facebook
+ (NSDate *)dateFromFacebookTimestamp:(NSString *)timestamp {
  //2010-12-01T21:35:43+0000  
  static NSDateFormatter *df = nil;
  @synchronized (self) {
    if (!df) {
      df = [[NSDateFormatter alloc] init];    
      [df setTimeStyle:NSDateFormatterFullStyle];
      //    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
      [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    }
    NSDate *date = [df dateFromString:timestamp];
    return date;
  }
}

#pragma mark - AWS
- (NSString *)stringWithAWSRequestFormat {
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  
  [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
  [dateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
  
  return [dateFormatter stringFromDate:self];
}

#pragma mark - Milliseconds
+ (NSDate *)dateWithMillisecondsSince1970:(NSTimeInterval)millisecondsSince1970 {
  NSTimeInterval secondsSince1970 = millisecondsSince1970 / 1000;
  return [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
}

- (NSTimeInterval)millisecondsSince1970 {
  NSTimeInterval timeSince1970 = [self timeIntervalSince1970];
  NSTimeInterval milliseconds = ceil(timeSince1970 * 1000);
  return milliseconds;
}

@end
