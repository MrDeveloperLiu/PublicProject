//
//  CSDateUntil.m
//  ChatServer
//
//  Created by 刘杨 on 2017/12/29.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSDateUntil.h"

@interface CSDateUntil ()
@property (nonatomic, strong) NSDateFormatter *fullFormat;
@property (nonatomic, strong) NSDateFormatter *normalFormat;
@property (nonatomic, strong) NSDateFormatter *monthFullFormat;
@property (nonatomic, strong) NSDateFormatter *hourFullFormat;
@property (nonatomic, strong) NSDateFormatter *monthFormat;
@property (nonatomic, strong) NSDateFormatter *hourFormat;
@end
@implementation CSDateUntil

+ (CSDateUntil *)until{
    static CSDateUntil *_until = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _until = [[CSDateUntil alloc] init];
    });
    return _until;
}

- (instancetype)init{
    if (self = [super init]) {
        [self innerInit];
    }
    return self;
}

- (void)innerInit{
    _currentFormat = [[NSDateFormatter alloc] init];
    [_currentFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
}

+ (NSDateFormatter *)exchangedCurrentDateFormat:(NSString *)format{
    [[[CSDateUntil until] currentFormat] setDateFormat:format];
    return [[CSDateUntil until] currentFormat];
}

/**
 @example "20170101123000"
 */
+ (NSDateFormatter *)fullFormat{
    return [[CSDateUntil until] fullFormat];
}
- (NSDateFormatter *)fullFormat{
    if (!_fullFormat) {
        _fullFormat = [[NSDateFormatter alloc] init];
        [_fullFormat setDateFormat:@"yyyyMMddHHmmss"];
    }
    return _fullFormat;
}
/**
 @example "2017-01-01 12:30:00"
 */
+ (NSDateFormatter *)normalFormat{
    return [[CSDateUntil until] normalFormat];
}
- (NSDateFormatter *)normalFormat{
    if (!_normalFormat) {
        _normalFormat = [[NSDateFormatter alloc] init];
        [_normalFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _normalFormat;
}
/**
 @example "2017-01-01"
 */
+ (NSDateFormatter *)monthFullFormat{
    return [[CSDateUntil until] monthFullFormat];
}
- (NSDateFormatter *)monthFullFormat{
    if (!_monthFullFormat) {
        _monthFullFormat = [[NSDateFormatter alloc] init];
        [_monthFullFormat setDateFormat:@"yyyy-MM-dd"];
    }
    return _monthFullFormat;
}
/**
 @example "12:30:00"
 */
+ (NSDateFormatter *)hourFullFormat{
    return [[CSDateUntil until] hourFullFormat];
}
- (NSDateFormatter *)hourFullFormat{
    if (!_hourFullFormat) {
        _hourFullFormat = [[NSDateFormatter alloc] init];
        [_hourFullFormat setDateFormat:@"HH:mm:ss"];
    }
    return _hourFullFormat;
}

/**
 @example "01-01"
 */
+ (NSDateFormatter *)monthFormat{
    return [[CSDateUntil until] monthFormat];
}
- (NSDateFormatter *)monthFormat{
    if (!_monthFormat) {
        _monthFormat = [[NSDateFormatter alloc] init];
        [_monthFormat setDateFormat:@"MM-dd"];
    }
    return _monthFormat;
}
/**
 @example "12:30"
 */
+ (NSDateFormatter *)hourFormat{
    return [[CSDateUntil until] hourFormat];
}
- (NSDateFormatter *)hourFormat{
    if (!_hourFormat) {
        _hourFormat = [[NSDateFormatter alloc] init];
        [_hourFormat setDateFormat:@"HH:mm"];
    }
    return _hourFormat;
}
@end
