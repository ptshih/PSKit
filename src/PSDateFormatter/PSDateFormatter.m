//
//  PSDateFormatter.m
//  Phototime
//
//  Created by Peter Shih on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSDateFormatter.h"

@interface PSDateFormatter ()

- (void)releaseDateFormatters;
- (void)didReceiveMemoryWarning:(NSNotification *)notification;

@end

@implementation PSDateFormatter

@synthesize
autoupdatingCurrentCalendar = _autoupdatingCurrentCalendar,
timeFormatter = _timeFormatter,
weekdayFormatter = _weekdayFormatter,
monthDayFormatter = _monthDayFormatter,
monthDayShortFormatter = _monthDayShortFormatter,
monthDayYearFormatter = _monthDayYearFormatter,
monthDayYearShortFormatter = _monthDayYearShortFormatter;

+ (id)sharedDateFormatter {
    static id sharedDateFormatter;
    if (!sharedDateFormatter) {
        sharedDateFormatter = [[self alloc] init];
    }
    return sharedDateFormatter;
}

- (id)init {
    self = [super init];
    if (self) {
        self.autoupdatingCurrentCalendar = [NSCalendar autoupdatingCurrentCalendar];
        
        self.timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.timeFormatter.dateFormat = @"h:mm a";
        
        self.weekdayFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.weekdayFormatter.dateFormat = @"EEEE";
        
        self.monthDayFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.monthDayFormatter.dateFormat = @"MMMM d";
        
        self.monthDayShortFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.monthDayShortFormatter.dateFormat = @"MMM d";
        
        self.monthDayYearFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.monthDayYearFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        self.monthDayYearShortFormatter = [[[NSDateFormatter alloc] init] autorelease];
        self.monthDayYearShortFormatter.dateStyle = NSDateFormatterShortStyle;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [self releaseDateFormatters];
    [super dealloc];
}

- (void)releaseDateFormatters {
    self.autoupdatingCurrentCalendar = nil;
    self.timeFormatter = nil;
    self.weekdayFormatter = nil;
    self.monthDayFormatter = nil;
    self.monthDayShortFormatter = nil;
    self.monthDayYearFormatter = nil;
    self.monthDayYearShortFormatter = nil;
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    [self releaseDateFormatters];
}

#pragma mark - Formatting
const NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;

- (NSString *)veryShortRelativeStringFromDate:(NSDate *)date {
    if (!date) {
        return @"";
    }
    
    NSString *dateString = nil;
    
    NSTimeInterval secondsBeforeNow = [date timeIntervalSinceNow] * -1;
    NSInteger minutesBeforeNow = secondsBeforeNow / 60;
    NSInteger hoursBeforeNow = minutesBeforeNow / 60;
    NSInteger daysBeforeNow = hoursBeforeNow / 24;
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [self.autoupdatingCurrentCalendar components:unitFlags fromDate:date];
    NSDateComponents *nowComponents = [self.autoupdatingCurrentCalendar components:unitFlags fromDate:nowDate];    
    BOOL isToday = [dateComponents day] == [nowComponents day];
    
    if (minutesBeforeNow <= 1) {
        dateString = @"1 min";
    } else if (hoursBeforeNow < 1) {
        dateString = [NSString stringWithFormat:@"%d mins", minutesBeforeNow];
    } else if (daysBeforeNow < 1 && (isToday || hoursBeforeNow <= 8)) {
        dateString = hoursBeforeNow > 1 ? [NSString stringWithFormat:@"%d hours", hoursBeforeNow] : @"1 hour";
    } else {
        dateString = daysBeforeNow > 1 ? [NSString stringWithFormat:@"%d days", MAX(daysBeforeNow, 1)] : @"1 day";
    }
    
    return dateString;
}

- (NSString *)singleLetterRelativeStringFromDate:(NSDate *)date {
    if (!date) {
        return @"";
    }
    
    NSString *dateString = nil;
    
    NSTimeInterval secondsBeforeNow = [date timeIntervalSinceNow] * -1;
    NSInteger minutesBeforeNow = secondsBeforeNow / 60;
    NSInteger hoursBeforeNow = minutesBeforeNow / 60;
    NSInteger daysBeforeNow = hoursBeforeNow / 24;
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [self.autoupdatingCurrentCalendar components:unitFlags fromDate:date];
    NSDateComponents *nowComponents = [self.autoupdatingCurrentCalendar components:unitFlags fromDate:nowDate];
    BOOL isToday = [dateComponents day] == [nowComponents day];
    
    if (minutesBeforeNow <= 1) {
        dateString = [NSString stringWithFormat:@"%um", 1];
    } else if (hoursBeforeNow < 1) {
        dateString = [NSString stringWithFormat:@"%um", minutesBeforeNow];
    } else if (daysBeforeNow < 1 && (isToday || hoursBeforeNow <= 8)) {
        dateString = [NSString stringWithFormat:@"%uh", hoursBeforeNow];
    } else {
        dateString = [NSString stringWithFormat:@"%ud", MAX(daysBeforeNow, 1)];
    }
    
    return dateString;
}

- (NSString *)shortRelativeStringFromDate:(NSDate *)date includeTime:(PSDateFormatterIncludeTime)includeTime useShortDate:(BOOL)useShortDate {
    NSString *dateString = nil;
    
    if (!date) {
        return nil;
    }
    
    NSTimeInterval secondsBeforeNow = [date timeIntervalSinceNow] * -1;
    NSInteger minutesBeforeNow = secondsBeforeNow / 60;
    NSInteger hoursBeforeNow = minutesBeforeNow / 60;
    NSInteger daysBeforeNow = hoursBeforeNow / 24;
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [self.autoupdatingCurrentCalendar components:unitFlags fromDate:date];
    NSDateComponents *nowComponents = [self.autoupdatingCurrentCalendar components:unitFlags fromDate:nowDate];
    
    if (minutesBeforeNow < -5) { // Allow times from a few minutes in the future to make it under the wire as "Just Now"
        dateString = @"In the future";
    } else if (minutesBeforeNow < 5) {
        dateString = @"Just now";
    } else if (minutesBeforeNow < 60) {
        if (minutesBeforeNow == 1) {
            dateString = @"1 minute ago";
        } else {
            dateString = [NSString stringWithFormat:@"%u minutes ago", minutesBeforeNow];
        }
    } else if (hoursBeforeNow < 24 && [dateComponents day] == [nowComponents day]) {
        if (hoursBeforeNow == 1) {
            dateString = @"1 hour ago";
        } else {
            dateString = [NSString stringWithFormat:@"%u hours ago", hoursBeforeNow];
        }
    } else {
        if (hoursBeforeNow < 48 && [dateComponents day] == [nowComponents day] - 1) {
            // This isn't strictly correct (it will miss when yesterday crosses a month or year boundary),
            // but it's quick and it doesn't have any false positives.
            dateString = @"Yesterday";
        } else if (daysBeforeNow < 7) {
            dateString = [[self weekdayFormatter] stringFromDate:date];
        } else if (daysBeforeNow < 365) {
            NSDateFormatter *formatter = useShortDate ? [self monthDayShortFormatter] : [self monthDayFormatter];
            dateString = [formatter stringFromDate:date];
        } else {
            NSDateFormatter *formatter = useShortDate ? [self monthDayYearShortFormatter] : [self monthDayYearFormatter];
            dateString = [formatter stringFromDate:date];
        }
        
        // Append the time for all dates if requested, or if it's less than 24 hours ago.
        NSUInteger maxTimeHours = 0;
        switch (includeTime) {
            case PSDateFormatterIncludeTimeLast24Hours:
            case PSDateFormatterIncludeTimeToday:
                maxTimeHours = 24; break;
            case PSDateFormatterIncludeTimeAlways:
                maxTimeHours = NSUIntegerMax; break;
        }
        if (hoursBeforeNow < maxTimeHours) {
            NSString *timeString = [[self timeFormatter] stringFromDate:date];
            dateString = [NSString stringWithFormat:@"%@ %@", dateString, timeString];
        }
    }
    
    return dateString;
}

- (NSString *)shortRelativeStringFromDate:(NSDate *)date includeTime:(PSDateFormatterIncludeTime)includeTime {
    return [self shortRelativeStringFromDate:date includeTime:includeTime useShortDate:NO];
}

- (NSString *)shortRelativeStringFromDate:(NSDate *)date {
    return [self shortRelativeStringFromDate:date includeTime:PSDateFormatterIncludeTimeLast24Hours];
}

@end
