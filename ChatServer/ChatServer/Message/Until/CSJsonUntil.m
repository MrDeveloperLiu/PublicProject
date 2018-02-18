//
//  CSJsonUntil.m
//  ChatServer
//
//  Created by 刘杨 on 2018/2/16.
//  Copyright © 2018年 Married. All rights reserved.
//

#import "CSJsonUntil.h"

@implementation CSJsonUntil

+ (id)jsonWithData:(NSData *)data error:(NSError **)error{
    id retVal = nil; 
    @try{
        retVal = [NSJSONSerialization JSONObjectWithData:data
                                                 options:(NSJSONReadingMutableContainers)
                                                   error:error];
    }
    @catch(NSException *e){
        
    }
    @finally{

    }
    return retVal;
}
+ (NSData *)toJsonWithObject:(id)object error:(NSError **)error{
    NSData *retVal = nil;
    @try{
        retVal = [NSJSONSerialization dataWithJSONObject:object
                                                 options:NSJSONWritingPrettyPrinted
                                                   error:error];
    }
    @catch(NSException *e){
        
    }
    @finally{
        
    }
    return retVal;
}

@end
