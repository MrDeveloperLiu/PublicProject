//
//  Handler.m
//  Runtime_system（part3）
//
//  Created by 刘杨 on 15/10/1.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "Handler.h"
#import "Person.h"

@interface Handler(){
    Person *_helper;
}

@end
//完整的消息转发机制
@implementation Handler

+ (Handler *)object{
    return [[self alloc] init];
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

//寻找目标方法选择器，如果这个方法选择器名称跟handleUnkownMessage一样的话，那么将这个消息教给Person类去处理
- (id)forwardingTargetForSelector:(SEL)aSelector{
    NSString *selectorString = NSStringFromSelector(aSelector);
    if ([selectorString isEqualToString:@"handleUnkownMessage"]) {
        return _helper;
    }
    return [super forwardingTargetForSelector:aSelector];
}

//给方法一个签名
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        if ([Person instancesRespondToSelector:aSelector]) {
            signature = [Person instanceMethodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

//如果Person这个类实现了封装在anInvocation中的selector，那么将在Person类目标里寻找这个方法的IMP
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    if ([Person instancesRespondToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:anInvocation.target];
    }
}
//NSObject的forwardInvocation:方法实现只是简单调用了doesNotRecognizeSelector:方法，它不会转发任何消息。这样，如果不在以上所述的三个步骤中处理未知消息，则会引发一个异常
@end
