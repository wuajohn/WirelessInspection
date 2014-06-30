//
//  NSDate+String.h
//  WirelessInspection
//
//  Created by wuajohn on 14-6-25.
//  Copyright (c) 2014年 ajohn. All rights reserved.
//

#define DF @"yyyy-MM-dd"
#define DDF @"yyyy-MM-dd HH:mm:ss"

#import <Foundation/Foundation.h>

@interface NSDate (String)

+(NSDate*) dateFromString:(NSString*)sDate;

@end


@interface NSString (Date)

+(NSString*) stringFromDate:(NSDate*)date;
+(NSString*) stringFromLongDate:(NSDate*)date;

@end