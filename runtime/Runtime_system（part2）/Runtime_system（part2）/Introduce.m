//
//  Introduce.m
//  Runtime_system(part2)
//
//  Created by 刘杨 on 15/9/30.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "Introduce.h"
#import <objc/runtime.h>

@implementation Introduce
- (instancetype)init{

    /*类型编码Type Encoding
     作为对runtime的补充，编译器将每个方法的参数类型和返回值编码为一个字符串，并将其与发放选择器selector联系在一起
     *因此可以使用@encode();编译器指令来获取他。而这个指令返回这个类型的字符串编码，这些类型可以是诸如int，指针这样的基本类型，还可以是结构体、类等类型，事实上，任何可以作为sizeof();操作的参数类型都可以用@encode();
   ===============================================================================
    字符串                 编码类型
     c                      char
     i                      int
     s                      short
     l                      long
     q                      long long
     
     C                      unsigned char
     I                      unsigned int
     S                      unsigned short
     L                      unsigned long
     Q                      unsigned long long
     
     f                      float
     d                      double
     B                      bool
     v                      void
    
     *                      character string    char *
     @                      object              id
     #                      object              Class
     :                      method selector     SEL
     
     [array type]           array
     {name=type...}         structure
     (name=tyoe...)         union
     bnum                   a bit field of num bits
     ^type                  a pointer to type
     ?                      an unkown type
     
     r                      const
     n                      in
     N                      inout
     o                      out
     O                      bycopy
     R                      bybef
     V                      oneway
    ===============================================================================
     ！！！注意oc不支持long double类型 使用@encode(long double); 返回仍然与d（double）一样的
     */
#pragma mark 下面在main.m中得到数组的编码
    
/*
 ==================================================================================
 Ivar是表示实例变量的类型
 >>>>>实际上他是一个指向结构体objc_ivar的指针
 typedef struct objc_ivar *Ivar;
 >>>>>而结构体定义如下
 struct objc_ivar {
 char *ivar_name                                          OBJC2_UNAVAILABLE;//变量名
 char *ivar_type                                          OBJC2_UNAVAILABLE;//变量类型
 int ivar_offset                                          OBJC2_UNAVAILABLE;//基地址偏移字节
 #ifdef __LP64__
 int space                                                OBJC2_UNAVAILABLE;//
 #endif
 }
==================================================================================
objc_property_t是表示oc声明的属性类型，实际上是指向objc_property的结构体指针
typedef struct objc_property *objc_property_t;

>>>>>>>objc_property_attribute_t定义了属性的特性
typedef struct {
const char *name;                   //特性名
const char *value;                  //特性值
} objc_property_attribute_t;
==================================================================================
关联对象(Associated Object)
关联对象是oc运行时机制中一个非常重要的特性，其类似于成员变量，但是是在运行时添加的；众所周知，我们不能在分类中添加实例变量，因为编译器会报错。我们可能通过使用或者说是滥用全部变量来解决这个问题，但是这些都不是Ivar，因为他们不会链接到一个单独的实例。oc针对这一问题，提供了一个解决方案：关联对象
我们可以把关联对象想象成一个Objective-C对象(如字典)，这个对象通过给定的key连接到类的一个实例上。不过由于使用的是C接口，所以key是一个void指针(const void *)。我们还需要指定一个内存管理策略，以告诉Runtime如何管理这个对象的内存，则这个对象的内存管理策略由以下值来指定
OBJC_ASSOCIATION_ASSIGN                     值得一提的是，当关联策略是assgin的话，宿主释放时，关联对象不会被释放
OBJC_ASSOCIATION_RETAIN_NONATOMIC           而我们还可以选择是否自动retain或者copy来在多个线程状态下处理访问关联对象
OBJC_ASSOCIATION_COPY_NONATOMIC                 的多线程代码时，就非常有用了
OBJC_ASSOCIATION_RETAIN                     而当关联策略是retain或者copy的话，宿主释放时，关联对象会被释放
OBJC_ASSOCIATION_COPY
例如：将一个对象链接到其他对象所做的事情就是
 static char myObject;
 objc_setAssociatedObject(self, &myObject, anObject, OBJC_ASSOCIATION_RETAIN);
 id anObject = objc_getAssociatedObject(self, &myObject);
 */
#pragma mark 下面在UIView+Guesture.m中演示一段代码
    
/*
==================================================================================
>>>>>>成员变量，属性的操作方法
 1>const char *ivar_getName(Ivar v) 获取成员变量名
 2>const char *ivar_getTypeEncoding(Ivar v) 获取成员变量编码类型
 3>ptrdiff_t ivar_getOffset(Ivar v)获取成员变量的偏移量
 
 4>const char *property_getName(objc_property_t property) 获取属性名
 5>const char *property_getAttributes(objc_property_t property) 获取属性特性描述字符串
 6>objc_property_attribute_t *property_copyAttributeList(objc_property_t property, unsigned int *outCount)获取属性特性列表，需要free
 7>char *property_copyAttributeValue(objc_property_t property, const char *attributeName)获取属性中指定的特性，需要free
 
 8>void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)设置关联对象
 9>id objc_getAssociatedObject(id object, const void *key)获取关联对象
 10>void objc_removeAssociatedObjects(id object)移除关联对象
*/

    
    

    
    
    
    
    
    
    
    
    
    
    return self;
}
@end
