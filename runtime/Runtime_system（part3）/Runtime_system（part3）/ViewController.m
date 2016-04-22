//
//  ViewController.m
//  Runtime_system（part3）
//
//  Created by 刘杨 on 15/10/1.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>


@implementation ViewController
- (void)method1{
    //test method
}

- (void)viewDidLoad {
    [super viewDidLoad];
/*
SEL 又叫选择器  typedef struct objc_selector *SEL;
*是一个指向结构体objc_selector的指针，但是在runtime.h中并没有找到这个结构体如何定义的，oc在编译时，会根据方法的名字，参数序列生成唯一一个整形标示（int类型的地址）
*而两个类之间，不管他们是父子关系，或者说根本没有一点关系，只要方法名相同，及时参数类型不同，这个方法的SEL（选择器）的整形标示都是相同的，而承载这些方法选择器的是一个NSSet集合，集合的特点就是唯一性，因此，SEL是唯一的。（而SEL的本质是根据方法名hash化了一个字符串，而对于字符串的比较仅仅需要比较他们的地址就可以了，所以速度上是无与伦比的）所以这时候编译器会报错。当然，不同的类可以有相同的选择器。
 可以通过下面方法来获取SEL
 1>SEL sel_registerName(const char *str)在oc的runtime系统中，注册一个方法，将方法映射到选择器，并将这个选择器返回
 2>oc 编译时提供的@selector();
 3>SEL NSSelectorFromString(NSString *aSelectorName);
 ****而下列方法是对sel相关的操作函数
 4>const char *sel_getName(SEL sel)返回给定选择器指定方法的名称
 5>BOOL sel_isMapped(SEL sel)
 6>SEL sel_getUid(const char *str)在oc的runtime系统中，注册一个方法
 7>BOOL sel_isEqual(SEL lhs, SEL rhs) 比较两个选择器
*/
#pragma mark 在mian.m中演示一段代码
//================================================================

/*
 IMP 方法的最终实现    id (*IMP)(id, SEL, ...)
*实际上它是一个函数指针，指向方法实现的首地址，这个函数使用当前C调用约定，第一个参数是指向self的指针（如果是实例方法，则指向的是类实例的地址，如果是类方法，则指向的是元类的指针），第二个参数是方法选择器，接下来是方法的实际参数列表
*前面介绍，SEL就是为了查找方法的最终实现IMP的，由于每个方法对应唯一的SEL，因此我们可以通过SEL准确的获得它的IMP，取得IMP之后，就像C语言一样，来使用这个函数指针。
*通过取得IMP，我们可以跳过runtime的消息机制，直接执行IMP指向的函数实现了，所以使用runtime里的函数会比执行oc代码效率要更高一些
*/
//================================================================

/*
Method 方法   typedef struct objc_method *Method;
而其结构体被定义成
struct objc_method {
SEL method_name               方法名                           OBJC2_UNAVAILABLE;
char *method_types           （应该是方法参数类型）               OBJC2_UNAVAILABLE;
IMP method_imp                方法实现                         OBJC2_UNAVAILABLE;
}可以看到，这个结构体中包含了SEL 和 IMP，实际上相当于在SEL和IMP之间有了一个映射，有了SEL就可以轻松的找到其方法实现IMP从而调用该方法
>>>>>>objc_method_description可以看到一个方法描述被定义成这样的一个结构体
struct objc_method_description {
SEL name;               方法名
char *types;            方法参数类型
};
>>>>方法操作函数
 1>SEL method_getName(Method m) 获取方法名
 **返回的是一个SEL，如果想要获取方法名的C字符串可以使用   sel_getName(method_getName(method))
 2>IMP method_getImplementation(Method m)获取方法实现
 3>const char *method_getTypeEncoding(Method m) 获取描述方法参数和返回值类型的字符串
 4>unsigned int method_getNumberOfArguments(Method m)返回方法的参数个数
 5>char *method_copyReturnType(Method m) 获取方法类型和返回值的字符串
 6>char *method_copyArgumentType(Method m, unsigned int index) 获取方法指定位置参数的类型的字符串
 7>void method_getReturnType(Method m, char *dst, size_t dst_len) 通过引用返回方法的返回值类型字符串
 **类型字符串会被拷贝到dst中
 8>void method_getArgumentType(Method m, unsigned int index, char *dst, size_t dst_len)用过引用返回方法指定参数位置的字符串
 9>struct objc_method_description *method_getDescription(Method m) 返回指定方法的方法描述结构体
 10>IMP method_setImplementation(Method m, IMP imp) 设置方法的实现
 **这个函数返回值是返回的方法之前的实现
 11>void method_exchangeImplementations(Method m1, Method m2) 交换两个方法的实现
 ****下面俩是定义在message.h里
 12>id method_invoke(id receiver, Method m, ...) 调用指定的方法实现
 **返回的是实际实现的返回值，receiver不能为空，这个方法的效率会比method_getImplementation和method_getName更高
 13>void method_invoke_stret(id receiver, Method m, ...)调用返回一个数据结构的方法实现
*/
//================================================================
   
/*
方法调用流程
*oc的方法调用机制，id objc_msgSend(id self, SEL op, ...)
这个方法 完成了动态绑定所有事件
 1.首先它找到了selector对应的方法实现，由于同一个方法在不同类里面可能有不同的方法实现，那么我们就需要一个receiver的类来找到方法的确切实现，这里self相当于接收者。
 2.调用它的方法实现，并且将接受者对象，和方法所有的参数传递给它
 3.最后它将实现返回的值作为它自己的返回值
 
当消息发送给一个对象时，objc_msgSend通过对象的isa指针获取到类的结构体，然后在方法分发表里面查找方法的selector。如果没有找
selector，则通过objc_msgSend结构体中的指向父类的指针找到其父类，并在父类的分发表里面查找方法的selector。依此，会一直沿着类的继承体
到达NSObject类。一旦定位到selector，函数会就获取到了实现的入口点，并传入相应的参数来执行方法的具体实现。如果最后没有定位到selector
则会走消息转发流程
 ********隐藏参数objc_msgSend
 1>消息接收的对象
 2>方法的selector     
 虽然这个参数没有显示的声明，但是在代码中仍然可以引用他们，可以使用self来引用接收者对象，_cmd来引用选择器，示例如下：例1
 >>>>>>>>>>>获取方法地址
 reason：runtime中，方法的动态绑定，让我们写代码时候更具灵活性，但是同时也带来了性能上的问题，因为每次我们使用消息发送机制去执行一个方法的时候，runtime都会从方法列表中遍历一遍，虽然，方法缓存列表在一定程度上解决了这个问题，但是当我们频繁的调用一个方法的时候，不如直接取到方法的实现，就如同调用C函数一样直接高效
 *所以NObject类里给我们提供了methodForSelector:的方法
 例如：
 void (*setter)(id, SEL, BOOL);
 int i;
 setter = (void (*)(id, SEL, BOOL))[target methodForSelector:@selector(setFilled:)];
 for (i = 0 ; i < 1000 ; i++)
 setter(targetList[i], @selector(setFilled:), YES);
 当然这种方式只适合于在类似于for循环这种情况下频繁调用同一方法，以提高性能的情况。另外，methodForSelector:是由Cocoa运行时提供的；它不是Objective-C语言的特性。
*/
//================================================================

    
    
    
/*
消息转发
oc默认的消息转发机制是[object message];如果object无法响应这个消息，编译器会报错，但是如果以performSelector的方式调用某个方法的时候，只有在程序运行过程中，runtime才会去判断，这个object是否能响应message，如果不能，则程序crash
但是我们可以这么调用：
 if ([self respondsToSelector:@selector(method)]) {
 [self performSelector:@selector(method)];
 }
但是，讨论一下不适用responseToSelector这个方法的时候；当某一个对象无法接收某个消息的时候，就会启动消息转发（message forwarding）机制，通过这一机制，我们可以告诉object应该如何处理未知消息。我们说，当一个类收到了一个未知的消息时候，默认情况下会崩溃，而控制台会消失没有识别的方法发送给了某个对象<0x181ac100>....这段异常信息实际上是由NSObject中的doesNotRecognizeSelector方法抛出的
然而：我们可以采取一系列的措施，让我们的程序执行特定的逻辑，从而避免程序崩溃
>>>>>消息转发机制
 1>动态方法分析
 2>备用接收者
 3>完整转发
*/
    
    //下面详细说明下这三个步骤
//================================================================
/*
 1>动态方法分析
对象在接收到未知消息的时候，首先会调用所属类的+resolveInstanceMethod:（实例方法）或者 +resolveClassMethod:（类方法）在这个方法中，我们有机会为该未知消息添加一个处理方法，使用的前提是，我们已经实现了这个“处理方法”，只要在运行时通过class_addMethod这个方法动态的添加到类里面就可以
*/
#pragma mark 在Person.m文件中演示该段代码，并且在main函数里面调用
//================================================================
/*
 2>备用接收者
 如果在上一步无法处理消息，runtime会继续调以下方法-(id)forwardingTargetForSelector:(SEL)aSelector
*   如果一个对象实现了这个方法，返回一个非nil的结果，那么这个对象会被作为消息的备用接收者，而且，消息会被分发给这个对象上，（但是这个对象不能是自身self），否则会出现无限循环。
 使用这个方法通常是在对象的内部，可能还有一系列其他对象能处理该消息，我们便可借用这些对象来处理消息，这样，在外部看来，仍然是这个对象在处理这个消息。
 ****但是这个做法是，我们知道这个对象能够处理这个消息
*/
#pragma mark 在Asker.m文件中演示该段代码，并且在main函数里面调用，借用Person类的handler...方法来处理
//================================================================
/*
 3>完整的消息转发
 如果那样还是无法处理消息，那么只能调用完整的消息转发机制了，此时会调用-(void)forwardInvocation:(NSInvocation *)anInvocation
runtime系统会在这个方法给消息的接收者最后一次机会将消息发送给其他对象，对象会创建一个表示消息的NSInvocation的对象，把尚未处理的消息有关的全部细节封装在anInvocation中，包括selector，目标和参数
 **forwardInvocation的方法实现有两个任务
 1>定位可以处理封装在anInvocation中消息的对象（这个对象不需要能处理所有的未知的消息）
 2>使用anInvocation作为参数，将消息发送到选中的对象，anInvocation会保留调用结果，并且runtime系统会提取这一结果发送到消息发送的原始对象
 》》在这个方法中我们还可以实现更复杂的功能，比如可以对消息的内容进行修改，（追回一个参数，再去触发消息）
 》》若发现消息本不应由此类处理，则应调用父类同名的方法，以便继承体中每个类都有机会处理该消息
 ***我们还必须重写-(NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector方法，该方法为给定的selector提供一个合法的签名
*/
#pragma mark 在Handler.m文件中演示该段代码，并且在main函数里面调用，借用Person类的handler...方法来处理

//谈到这里，可以试想一下，我们可以利用runtime系统实现多继承
/*通过重写下列方法
     - (BOOL)respondsToSelector:(SEL)aSelector
     {
         if ( [super respondsToSelector:aSelector])
            return YES;
         else {
         * Here, test whether the aSelector message can     *
         * be forwarded to another object and whether that  *
         * object can respond to it. Return YES if it can.  *
    在这里将某个能响应这个selector的类，让他去响应，并return YES，那么也就是说，我们可以利用它来去别的类里面遍历这个所谓的（在self）里找不到的方法IMP
         }
        return NO;
    }

*/







}

//例1
/*
- strange
{
    id  target = getTheReceiver();
    SEL method = getTheMethod();
    if ( target == self || method == _cmd )
        return nil;
    return [target performSelector:method];
}
*/



















@end
