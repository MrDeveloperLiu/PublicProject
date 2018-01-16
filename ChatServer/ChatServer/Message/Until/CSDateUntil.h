//
//  CSDateUntil.h
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDateUntil : NSObject

/**
 @example "20170101123000"
 */
+ (NSDateFormatter *)fullFormat;
/**
 @example "2017-01-01 12:30:00"
 */
+ (NSDateFormatter *)normalFormat;
/**
 @example "2017-01-01"
 */
+ (NSDateFormatter *)monthFullFormat;
/**
 @example "12:30:00"
 */
+ (NSDateFormatter *)hourFullFormat;
/**
 @example "01-01"
 */
+ (NSDateFormatter *)monthFormat;
/**
 @example "12:30"
 */
+ (NSDateFormatter *)hourFormat;


@property (nonatomic, strong, readonly) NSDateFormatter *currentFormat;

+ (CSDateUntil *)until;

+ (NSDateFormatter *)exchangedCurrentDateFormat:(NSString *)format;



@end
