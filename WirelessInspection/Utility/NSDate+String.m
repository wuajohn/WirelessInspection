//
//  NSDate+String.m
//  WirelessInspection
//
//  Created by wuajohn on 14-6-25.
//  Copyright (c) 2014年 ajohn. All rights reserved.
//

#import "NSDate+String.h"

@implementation NSDate (String)

+(NSDate*) dateFromString:(NSString*)sDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:DF];
    NSDate *date=[formatter dateFromString:sDate];
    return date;
}

@end


@implementation NSString (Date)

+(NSString*) stringFromDate:(NSDate*)date
{
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:DF];
	return [format stringFromDate:date];
}

+(NSString*) stringFromLongDate:(NSDate*)date
{
	NSDateFormatter *format = [[NSDateFormatter alloc] init];
	[format setDateFormat:DDF];
	return [format stringFromDate:date];
}

@end
