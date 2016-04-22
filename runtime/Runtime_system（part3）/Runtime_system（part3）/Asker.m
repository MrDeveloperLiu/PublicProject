//
//  Asker.m
//  Runtime_system（part3）
//
//  Created by 刘杨 on 15/10/1.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "Asker.h"
#import "Person.h"

@interface Asker(){
    Person *_helper;
}

@end

@implementation Asker

+ (Asker *)object{
    return [[[self class] alloc] init];
}

- (instancetype)init{
    if (self = [super init]) {
        _helper = [[Person alloc] init];
    }
    return self;
}

- (void)sendUnkownMessage{
    [self performSelector:@selector(handleUnkownMessage)];
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSString *selectorString = NSStringFromSelector(aSelector);
    //将消息转发给Person 来处理
    if ([selectorString isEqualToString:@"handleUnkownMessage"]) {
        return _helper;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
