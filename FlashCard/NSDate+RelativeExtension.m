//
//  NSDate+RelativeExtension.m
//  FlashCard
//
//  Created by Tzu-Chien Chiu on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+RelativeExtension.h"

@implementation NSDate (RelativeExtension)

+ (NSDate *)today {    
    return [NSDate date];
}

+ (NSDate *)twoDaysAgo {
    
    return [NSDate dateWithTimeIntervalSinceNow:-60*60*24*2];
}

+ (NSDate *)sixDaysAgo {
    
    return [NSDate dateWithTimeIntervalSinceNow:-60*60*24*6];
}

// Convert a date comporting a time into a rounded date (just the day, no time).
- (NSDate *)dayDate {
    
    unsigned int flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flags fromDate:self];
    NSDate* dateOnly = [[calendar dateFromComponents:components] dateByAddingTimeInterval:[[NSTimeZone localTimeZone]secondsFromGMT]];
    return dateOnly;
    
    /*
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *beginningOfDay = nil;
    NSTimeInterval lengthOfDay;
    [calendar rangeOfUnit:*/
}

- (NSString *)relativeDate {
    
    NSDate* _twoDaysAgo = [[NSDate twoDaysAgo] dayDate];
    NSDate* _sixDaysAgo = [[NSDate sixDaysAgo] dayDate];
    NSDate* _today = [[NSDate today] dayDate];

    if (self == [self laterDate:_today]) {
        return @"Today";
    } else if (self == [self laterDate:_twoDaysAgo]) {
        return @"Three days";
    } else if (self == [self laterDate:_sixDaysAgo]) {
        return @"This week";
    } else 
        return @"Long time ago";
}

@end
