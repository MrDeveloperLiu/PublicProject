//
//  main.m
//  Runtime_system
//
//  Created by 刘杨 on 15/9/29.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "MyClass.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        
        
//        MyClass *myClass = [[MyClass alloc] init];
//        unsigned int outCount = 0;
        
        /*
        Class cls = myClass.class;
        
    
        
        //类名
        NSLog(@"class name: %s", class_getName(cls));
        NSLog(@"========================================");
        
        //是否元类
        NSLog(@"class is %@ a meta-class", (class_isMetaClass(cls) ? @"": @"not"));
        NSLog(@"========================================");
        
        Class meta_class = objc_getMetaClass(class_getName(cls));
        NSLog(@"%s's meta-class is %s", class_getName(cls), class_getName(meta_class));

        //父类
        NSLog(@"super class is %s", class_getName(class_getSuperclass(cls)));
        NSLog(@"========================================");
        
        //实例变量大小
        NSLog(@"instance's size is %zu",class_getInstanceSize(cls));
        NSLog(@"========================================");

        //获取成员变量
        Ivar *ivars = class_copyIvarList(cls, &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSLog(@"instance variable's name: %s index : %d", ivar_getName(ivar), i);
        }
        //释放数组
        free(ivars);
        
        Ivar string = class_getInstanceVariable(cls, "_string");//可以看出这里成员变量为什么要加下划线这个必要性
        if (string != NULL) {
            NSLog(@"instance variable %s", ivar_getName(string));
        }
        NSLog(@"========================================");

        //获取属性列表
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        for (int i = 0; i < outCount; i ++) {
            objc_property_t property = properties[i];
            NSLog(@"property's name: %s index : %d", property_getName(property), i);
        }
        free(properties);
        
        objc_property_t array = class_getProperty(cls, "array");//而属性不用加下划线
        if (array != NULL) {
            NSLog(@"property %s", property_getName(array));
        }
        NSLog(@"========================================");

        //方法操作
        Method *methods = class_copyMethodList(cls, &outCount);
        for (int i = 0; i < outCount; i ++) {
            Method method = methods[i];
            NSLog(@"method's signature : %s", sel_getName(method_getName(method)));
        }
        free(methods);
        
        Method method = class_getInstanceMethod(cls, @selector(method1));
        if (method != NULL) {
            NSLog(@"method : %s", sel_getName(method_getName(method)));
        }
        
        //因为此方法是私有方法，但是确实是实现了方法选择器，.h文件中找不到这个方法，所以才会报黄
        NSLog(@"myclass is %@ respone to selector :method3WithArg1:arg2:", (class_respondsToSelector(cls, @selector(method3WithArg1:arg2:)) ? @"": @"not"));
        
        //调用方法
        IMP imp = class_getMethodImplementation(cls, @selector(method1));
        imp();
        NSLog(@"========================================");

        //协议
        Protocol * __unsafe_unretained *protocols = class_copyProtocolList(cls, &outCount);
        Protocol *protocol;
        for (int i = 0; i < outCount; i ++) {
            protocol = protocols[i];
            NSLog(@"protocol's name: %s", protocol_getName(protocol));
        }
        //是否遵守了协议
        NSLog(@"myclass is%@ conform to protocol: %s", (class_conformsToProtocol(cls, protocol) ? @"" : @"not"), protocol_getName(protocol));
        NSLog(@"========================================");
        */
        
        
        /*
        IMP imp_submethod1 = class_getMethodImplementation(myClass.class, @selector(method2));

        
        //创建个类
        Class cls = objc_allocateClassPair(myClass.class, "MySubclass", 0);
        class_addMethod(cls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
        class_replaceMethod(cls, @selector(method1), (IMP)imp_submethod1, "v@:");
        class_addIvar(cls, "_ivar1", sizeof(NSString *), log(sizeof(NSString *)), "i");
        objc_property_attribute_t type = {"T", "@\"NSString\""};
        objc_property_attribute_t ownship = {"C", ""};
        objc_property_attribute_t  backingivar = {"V", "_ivar1"};
        objc_property_attribute_t attr[] = {type, ownship, backingivar};
        class_addProperty(cls, "property2", attr, 3);
        objc_registerClassPair(cls);
        
        //使用这个类
        id instance = [[cls alloc] init];
        [instance performSelector:@selector(submethod1)];
        [instance performSelector:@selector(method1)];
        */
         
        /*注意在ARC状态下不可使用malloc开辟内存空间
        int numClasses;
        Class *classes = NULL;
        numClasses = objc_getClassList(NULL, 0);
        if (numClasses > 0) {
            classes = malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            NSLog(@"number of classes : %d", numClasses);
            for (int i = 0; i < numClasses; i ++) {
                Class cls = classes[i];
                NSLog(@"class's name : %s", class_getName(cls));
            }
            free(classes);
        }
        */
         
    }
}
