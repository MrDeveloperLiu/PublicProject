//
//  ViewController.m
//  Runtime_system（part6）
//
//  Created by 刘杨 on 15/10/5.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "MyRuntimeBlock.h"

/**拾遗
 《补充runtime》
 **super
 在一个类的方法中，我们需要调用父类的方法时通常会用到super，那么它是如何工作的
 首先，我们需要知道，self和super不同，self是类隐藏的参数每个方法实现的第一个参数即为self，而super不是隐藏的参数，他实际上只是一个“编
 译器标示符”，它告诉编译器，当需要调用这个方法的时候，去父类里面找，而并不是本类中的方法。而super实际上和self指向的是同一个消息接收者
struct objc_super {
__unsafe_unretained id receiver;
#if !defined(__cplusplus)  &&  !__OBJC2__
__unsafe_unretained Class class;
#else
__unsafe_unretained Class super_class;
#endif
};
 可以看出，这个结构体里有两个成员，一个是id receiver，另一个是其父类super_class。而当用super来接收消息的时候，编译器会生成一个
 objc_super结构体，不是调用的id objc_msgSend(id self, SEL op, ...)，而是id objc_msgSendSuper(struct objc_super *super, SEL op, ...)。
 实际上，调用方法的时候，objc_msgSendSuper中结构体的id receiver，和self所指的是统一个接收者，而super_class指向其父类
 例如：objc_msgSendSuper(super_class->receiver, @selector(viewDidLoad))，
        objc_msgSend(self, @selector(viewDidLoad))，其效果是一样的
=================================================
 */
#pragma mark viewDidLoad示例代码
 /*
 库相关操作函数
 **库相关的操作主要是用于获取由系统提供的库相关的信息
 1>const char **objc_copyImageNames(unsigned int *outCount) 获取所有OC框架和动态库的名称
 2>const char *class_getImageName(Class cls) 获取指定类所在动态库
 3>const char **objc_copyClassNamesForImage(const char *image, unsigned int *outCount) 获取指定动态库或者框架中指定类的类名
=================================================
  */
#pragma mark viewDidLoad示例代码

/*
 块操作（block）
 **函数
 1>IMP imp_implementationWithBlock(id block)创建一个指针函数的指针，该函数调用时，会调用特定的blcok
 2>id imp_getBlock(IMP anImp)返回IMP（与imp_implementationWithBlock创建的）相关的block
 3>BOOL imp_removeBlock(IMP anImp)解除block与IMP（与imp_implementationWithBlock创建的）的关联关系，并且释放block的拷贝
=================================================
 */
#pragma mark viewDidLoad示例代码

/*
 弱引用 __weak
 1>id objc_loadWeak(id *location)加载弱指针引用的对象并且返回
 2>id objc_storeWeak(id *location, id obj)储存__weak变量的新值
 ● objc_loadWeak函数：该函数加载一个弱指针引用的对象，并在对其做retain和autoreleasing操作后返回它。这样，对象就可以在调用者使用它时保持足够长的生命周期。该函数典型的用法是在任何有使用__weak变量的表达式中使用。
 ● objc_storeWeak函数：该函数的典型用法是用于__weak变量做为赋值对象时。
=================================================
 */
/*
 布尔值
 *在objc中这么定义。 >>注意的是，YES中的1代表的不是非零，而就是1
 #define YES ((BOOL)1)
 #define NO  ((BOOL)0)
================================================= 
 */
/*
 空
 #ifndef Nil
 # if __has_feature(cxx_nullptr)
 #   define Nil nullptr
 # else
 #   define Nil __DARWIN_NULL
 # endif
 #endif
 
 #ifndef nil
 # if __has_feature(cxx_nullptr)
 #   define nil nullptr
 # else
 #   define nil __DARWIN_NULL
 # endif
 #endif
**其中，nil用于空的实例对象，而Nil用于空类对象
=================================================
 */
/*
 还有一些宏
 1>    NS_VALID_UNTIL_END_OF_SCOPE
 ===>该宏表明存储在某些局部变量中的值在优化时不应该被编译器强制释放
 *我们将局部变量标记为id类型或者是指向ObjC对象类型的指针，以便存储在这些局部变量中的值在优化时不会被编译器强制释放。相反，这些值会在变量再次被赋值之前或者局部变量的作用域结束之前都会被保存
 2>    OBJC_ROOT_CLASS
 ===>如果我们定义了一个Objective-C根类，则编译器会报错，指明我们定义的类没有指定一个基类。这种情况下，我们就可以使用这个宏定义来避过这个编译错误。该宏在iOS 7.0后可用
 3>    OBJC_OLD_DISPATCH_PROTOTYPES
 ===>该宏指明分发函数是否必须转换为合适的函数指针类型。当值为0时，必须进行转换
=================================================
 */
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //1.super
    /*
    NSLog(@"self.class: %@", self.class);
    NSLog(@"super.class: %@", super.class);
//打印结果
//    self.class: ViewController
//    super.class: ViewController
    */

    /*
    //2.库相关
    NSLog(@"获取指定类所在动态库");
    NSLog(@"UIView: %s", class_getImageName(NSClassFromString(@"UIView")));
    NSLog(@"获取指定动态库中所有类的类名");
    unsigned int outCount = 0;
    const char **names = objc_copyClassNamesForImage(class_getImageName(NSClassFromString(@"UIView")), &outCount);
    for (int i = 0; i < outCount; i ++) {
        NSLog(@"classes name is:  %s", names[i]);
    }
    free(names);
    //打印太多，暂贴两个结果
    //UIView: /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/System/Library/Frameworks/UIKit.framework/UIKit
    //classes name is:  UIKeyboardUISettings
    */
    
    /*
    //3.block
    IMP imp = imp_implementationWithBlock(^void(id obj, NSString *str){
        NSLog(@"%@", str);
    });
    class_addMethod(MyRuntimeBlock.class, @selector(testBlock:), imp, "v@:@");//编码类型： v->void @->id obj :->sel
    MyRuntimeBlock *runtime = [[MyRuntimeBlock alloc] init];
    [runtime performSelector:@selector(testBlock:) withObject:@"hello world!"];
    //打印结果hello world!
     */
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
