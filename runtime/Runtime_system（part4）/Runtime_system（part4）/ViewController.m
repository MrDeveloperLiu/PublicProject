//
//  ViewController.m
//  Runtime_system（part4）
//
//  Created by 刘杨 on 15/10/5.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "runtime_category.h"

/**
 Objective-C中的协议是普遍存在的接口定义方式，即在一个类中通过@protocol定义接口，在另外类中实现接口，这种接口定义方式也成为“delegation”模式，@protocol声明了可以被其他任何方法类实现的方法，协议仅仅是定义一个接口，而由其他的类去负责实现
=============================================
 Category  分类，类别，类目typedef struct objc_category *Category;
 而结构体objc_category这么被定义
 struct objc_category {
 char *category_name                            分类名
 char *class_name                               分类所属的类名
 struct objc_method_list *instance_methods      实例方法列表
 struct objc_method_list *class_methods         类方法列表-->实际上是元类方法列表的一个子集
 struct objc_protocol_list *protocols           分类所实现的协议列表
 }
=============================================
 操作函数：Runtime并没有在<objc/runtime.h>头文件中提供针对分类的操作函数。因为这些分类中的信息都包含在objc_class中，我们可以通过针对objc_class的操作函数来获取分类的信息。
*/
#pragma mark 在viewDidLoad测试
/*
=============================================
 Protocol  协议typedef struct objc_object Protocol;
 
 @interface Protocol : Object
 {
 @private
 char *protocol_name                                        协议名
 struct objc_protocol_list *protocol_list                   协议列表
 struct objc_method_description_list *instance_methods      协议中实例方法列表
 struct objc_method_description_list *class_methods         协议中类方法列表
 }
- (const char *)name                                        获取协议名函数
- (BOOL) conformsTo: (Protocol *)aProtocolObject            是否遵守了某个协议
- (struct objc_method_description *) descriptionForInstanceMethod:(SEL)aSel 协议中实例方法描述，返回一个结构体指针
- (struct objc_method_description *) descriptionForClassMethod:(SEL)aSel    协议中类方法描述，返回一个结构体指针
@end
=============================================
操作函数：在runtime系统中，提供了很多操作Protocol的函数
 1>Protocol *objc_getProtocol(const char *name)返回指定的协议
 2>Protocol * __unsafe_unretained *objc_copyProtocolList(unsigned int *outCount)返回运行时所知道的所有协议组
 3>BOOL protocol_conformsToProtocol(Protocol *proto, Protocol *other)查看协议是否采用了另外一个协议
 4>BOOL protocol_isEqual(Protocol *proto, Protocol *other)测试两个协议是否相同
 5>const char *protocol_getName(Protocol *p)返回协议名
 6>struct objc_method_description protocol_getMethodDescription(Protocol *p, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod)获取协议中指定条件的方法描述
 7>struct objc_method_description *protocol_copyMethodDescriptionList(Protocol *p, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount)获取协议中指定条件的方法描述的数组
 8>objc_property_t protocol_getProperty(Protocol *proto, const char *name, BOOL isRequiredProperty, BOOL isInstanceProperty)获取协议的指定属性
 9>objc_property_t *protocol_copyPropertyList(Protocol *proto, unsigned int *outCount)获取协议的属性列表
 10>Protocol * __unsafe_unretained *protocol_copyProtocolList(Protocol *proto, unsigned int *outCount)获取协议采用的协议
 11>Protocol *objc_allocateProtocol(const char *name) 创建新的协议实例
 12>void objc_registerProtocol(Protocol *proto) 在运行时注册新创建的协议
 13>void protocol_addMethodDescription(Protocol *proto, SEL name, const char *types, BOOL isRequiredMethod, BOOL isInstanceMethod)为协议添加方法
 14>void protocol_addProtocol(Protocol *proto, Protocol *addition) 添加一个已经注册的协议到协议中
 15>void protocol_addProperty(Protocol *proto, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty)为协议添加属性
 
=============================================
● objc_getProtocol函数，需要注意的是如果仅仅是声明了一个协议，而未在任何类中实现这个协议，则该函数返回的是nil
● objc_copyProtocolList函数，获取到的数组需要使用free来释放
● objc_allocateProtocol函数，如果同名的协议已经存在，则返回nil
● objc_registerProtocol函数，创建一个新的协议后，必须调用该函数以在运行时中注册新的协议。协议注册后便可以使用，但不能再做修改，即注册完后不能再向协议添加方法或协议
需要强调的是，协议一旦注册后就不可再修改，即无法再通过调用protocol_addMethodDescription、protocol_addProtocol和protocol_addProperty往协议中添加方法
 =============================================
 */

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    /*
    runtime_category *runtimeClass = [[runtime_category alloc] init];
    
    
    unsigned int outCount = 0;
    Method *methodList = class_copyMethodList(runtimeClass.class, &outCount);
    for (int i = 0; i < outCount; i ++) {
        Method method = methodList[i];
        
        const char *name = sel_getName(method_getName(method));
        NSLog(@"name: %s", name);
        
        if (strcmp(name, sel_getName(@selector(method2)))) {
            NSLog(@"method2 在 分类列表里");
        }
    }
    free(methodList);
    */

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
