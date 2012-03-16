//
//  PSDateFormatter.h
//  Phototime
//
//  Created by Peter Shih on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    PSDateFormatterIncludeTimeToday,
    PSDateFormatterIncludeTimeLast24Hours,
    PSDateFormatterIncludeTimeAlways,
    
} PSDateFormatterIncludeTime;

@interface PSDateFormatter : NSObject

@property (nonatomic, retain) NSCalendar *autoupdatingCurrentCalendar;
@property (nonatomic, retain) NSDateFormatter *timeFormatter;
@property (nonatomic, retain) NSDateFormatter *weekdayFormatter;
@property (nonatomic, retain) NSDateFormatter *monthDayFormatter;
@property (nonatomic, retain) NSDateFormatter *monthDayShortFormatter;
@property (nonatomic, retain) NSDateFormatter *monthDayYearFormatter;
@property (nonatomic, retain) NSDateFormatter *monthDayYearShortFormatter;

+ (id)sharedDateFormatter;

/*
 PSDateFormatterIncludeTimeToday:
 Just now, N minutes ago, N hours ago, Yesterday, Saturday, June 28, Jun 28 2008
 
 PSDateFormatterIncludeTimeLast24Hours:
 Just now, N minutes ago, N hours ago, Yesterday 3:17pm, Saturday, June 28, Jun 28 2008
 
 PSDateFormatterIncludeTimeAlways:
 Just now, N minutes ago, N hours ago, Yesterday 3:17pm, June 28 3:17pm, June 28 2008 3:17pm
 */
- (NSString *)shortRelativeStringFromDate:(NSDate *)date includeTime:(PSDateFormatterIncludeTime)includeTime useShortDate:(BOOL)useShortDate;
- (NSString *)shortRelativeStringFromDate:(NSDate *)date includeTime:(PSDateFormatterIncludeTime)includeTime;
- (NSString *)shortRelativeStringFromDate:(NSDate *)date; // Defaults to PSDateFormatterIncludeTimeLast24Hours

- (NSString *)veryShortRelativeStringFromDate:(NSDate *)date; // Defaults to PSDateFormatterIncludeTimeLast24Hours
- (NSString *)singleLetterRelativeStringFromDate:(NSDate *)date; // Defaults to PSDateFormatterIncludeTimeLast24Hours

@end