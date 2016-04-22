//
//  ViewController.m
//  Runtime_system
//
//  Created by 刘杨 on 15/9/29.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController
/*  说起运行时系统，那就不得不从类来说起
 首先，一个类--class被runtime这样定义 >> typedef struct objc_class *Class;
 显然，它是一个指向objc_class这个结构体的指针，具体参数解释如下，这个指针指向的是他的super_class（父类）
 ***着重一说的是这个cache，它是用于缓存最近的方法。一个对象在接收到一个消息时候，会根据isa指针去查找能否响应这个消息的对象，在实际使用过程中，往往一个类使用的方法只有一部分是最常用，所以这个参数就做了这么一件事：由于，每次对象执行相应的方法时候，都会从 methodList列表里遍历一遍，比较耗性能，所以它将你使用过的方法，缓存在cache这个缓存方法列表里面，下次再响应某个方法的时候，会首先从这个缓存列表里面去遍历，找不到的话，再去方法列表里去寻找改方法。所以，方法缓存的好处，极大的提高了运行效率。
 */

/*
struct objc_class {
    Class isa  OBJC_ISA_AVAILABILITY;                       //isa指针，指向他的元类（meta_class）
    
#if !__OBJC2__
    Class super_class                                        OBJC2_UNAVAILABLE;//父类
    const char *name                                         OBJC2_UNAVAILABLE;//类名
    long version                                             OBJC2_UNAVAILABLE;//类的版本信息 default 0
    long info                                                OBJC2_UNAVAILABLE;//类信息，供运行时使用的位标示符
    long instance_size                                       OBJC2_UNAVAILABLE;//实例变量的大小
    struct objc_ivar_list *ivars                             OBJC2_UNAVAILABLE;//类的实例变量的链表
    struct objc_method_list **methodLists                    OBJC2_UNAVAILABLE;//类的方法的链表
    struct objc_cache *cache                                 OBJC2_UNAVAILABLE;//方法缓存
    struct objc_protocol_list *protocols                     OBJC2_UNAVAILABLE;//协议链表
#endif
    
} OBJC2_UNAVAILABLE;
*/


/*  而我们在objc/objc.h里发现了objc_object这个结构体，这个结构体指针被定义成了id，也就是任意类型
 也就说，实际上任意类型，id这个指针指向的是一个结构体， 结构体里有一个isa指针，指向本类，即运行时库会根据实例对象的这个isa指针寻找到这个对象所属的类，再去相应的方法列表寻找与消息对应的选择器selector，如果找不到则去其父类去找，找到后执行这个方法选择器
 */

/*
struct objc_object {
    Class isa  OBJC_ISA_AVAILABILITY;
}; 
typedef struct objc_object *id;
*/

/**元类 meta-class
 从上述可得知，类本身也是一个对象，但是我们可以给这个类发送消息，即调用其类方法，那么问题来了，既然类也是对象，那么对象objc_object中的isa指针指向哪里？
    这就引出元类的概念。例如我们在初始化一个数组NSArray *array = [NSArray array];
 我们说NSArray其实也是一个对象，我们对NSArray发送了一条array消息，那么这个类的isa指针必须指向一个包含了这个类方法的meta-class的结构体，即元类；mtea-class实际上是一个类对象的类。元类之所以重要，是因为它承载着一个类的所有类方法，而每一个类基本上都有自己单独的meta-class类，因为每一个类不可能完全相同
 */
//那么问题又来了，既然我们也可以给meta-class类发送消息，那么它的isa指针又指向了哪里？
/*
为了不让这种结构一直无限延伸下去，oc的研发者，将所有的meta-class的类的isa指针指向了基类NSObject的meta-class，以此作为它们的所属类，而基类的meta-class类中isa指针指向的是自己，这样就形成了一个完美的闭环，则就形成了一个继承体系
 */


- (void)viewDidLoad {
    [super viewDidLoad];
/*
====>>>>>>类相关操作函数
1.获取类名（返回值是const char* ， 需要传入这个类Class cls）
const char *class_getName(Class cls)
2.获取父类
Class class_getSuperclass(Class cls)
3.一个类是否是元类
BOOL class_isMetaClass(Class cls)
*/

/*
 ====>>>>>>实例变量，及其属性操作函数
 获取实例大小（返回值size_t）
 size_t class_getInstanceSize(Class cls)
 ======>在objc_class中，所有的成员变量，属性的信息都是放在ivars链表中的，ivars是一个数组，每一个元素指向的是（变量信息）Ivar的指针
 ====>>>>>>对成员变量操作的函数
 
 1>Ivar class_getInstanceVariable(Class cls, const char *name)获取一个指定名称的成员变量信息
 2>Ivar class_getClassVariable(Class cls, const char *name)获取一个指定名称的类成员变量信息
 3>BOOL class_addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types)
 添加一个成员变量，不过oc不支持往已创建类中添加一个成员变量（不管是系统库类，还是自定义类）。但是可以动态的创建一个类，并给类添加成员变量，但是需要注意的是添加成员变量一定要在Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)和void objc_registerClassPair(Class cls) 之间调用，另外这个类也不能是元类，并且成员变量的按字节最小对齐量是1<<alignment
 4>Ivar *class_copyIvarList(Class cls, unsigned int *outCount)获取整个成员变量的列表
 它返回一个指向成员变量的信息的数组，数组中每个元素，是指向该成员变量信息的结构体指针，需要注意的是，我们需要手动free(); 这个数组
 
 ====>>>>>>属性操作函数
 1>objc_property_t class_getProperty(Class cls, const char *name)获取某个类指定的属性
 2>objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)获取某个类的属性列表（同Ivar4，也要手动释放数组）
 3>BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)为某个类添加属性
 4>void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)替换类的属性
 
 ====>>>>>>方法操作函数
 1>BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)为类添加一个方法，它的实现，可以覆盖父类方法，但是不会取代本类已存在的方法实现，如果要修改已经实现的方法的话，用method_setImplementation
 2>Method class_getInstanceMethod(Class cls, SEL name)获取实例方法
 3>Method class_getClassMethod(Class cls, SEL name)获取类方法
 >>上述两个方法都会去搜索父类实现的方法，而下面的返回方法列表的数组不包含父类实现的方法
 4>Method *class_copyMethodList(Class cls, unsigned int *outCount) 获取方法列表（同上也要手动释放数组）
 5>IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)替代方法的实现
 6>IMP class_getMethodImplementation(Class cls, SEL name) 获取方法的具体实现
 7>IMP class_getMethodImplementation_stret(Class cls, SEL name)
 8>BOOL class_respondsToSelector(Class cls, SEL sel)判断某个类是否能响应指定的selector
 *一个oc的方法是一个简单的c语言函数，它至少包括两个参数，self，_cmd，与成员变量不同的是，我们可以动态的添加方法，不管这个类是否存在，而
 const char *types涉及到类型编码
 //eg:
 void myMethodIMP(id self, SEL _cmd){
    //implementation
 }
 
 ====>>>>>>协议
 1>BOOL class_addProtocol(Class cls, Protocol *protocol)为类添加协议
 2>BOOL class_conformsToProtocol(Class cls, Protocol *protocol)返回类是否实现指定的协议
 3>Protocol * __unsafe_unretained *class_copyProtocolList(Class cls, unsigned int *outCount)返回实现协议的列表（需要手动free这个数组）
 
 ====>>>>>>版本
 1>int class_getVersion(Class cls)得到版本号
 2>void class_setVersion(Class cls, int version)设置版本号
 */

#pragma mark 下面在main.m中列举一些实例

/*
 ====>>>>>>动态创建类
 1>Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)创建一个新类和元类
 *如果要创建一个根类，那么其superclass指定为nil，extraBytes通常指定为0，该参数是分配给类和元类尾部对象索引ivars的字节数
 *为了创建一个新类，那么还需要调用诸如class_addMethod；class_addIvar，和一些协议，属性之类的，完成这些后，需要objc_registerClassPair 注册一下这个类，而实例方法加在本身上，类方法加在其元类上
 2>void objc_disposeClassPair(Class cls)销毁一个类及其相关的类
 *需要注意的是如果程序运行过程中还存在其类和子类的实例的话，则不能调用该方法
 3>void objc_registerClassPair(Class cls)在应用中注册由 objc_allocateClassPair创建出来的类
 */
    
#pragma mark 下面在main.m中列举一些实例

/*
 ====>>>>>>动态创建对象
 1>id class_createInstance(Class cls, size_t extraBytes)创建类实例
 *创建实例时，会在默认的内存区域为类分配内存。extraBytes参数表示分配的额外字节数。这些额外的字节可用于存储在类定义中所定义的实例变量之外的实例变量。该函数在ARC环境下无法使用。
 2>id objc_constructInstance(Class cls, void *bytes)在指定的位置创建类实例
 3>void *objc_destructInstance(id obj)销毁类实例
 */
    
/*
 ====>>>>>>实例操作函数
 1>id object_copy(id obj, size_t size)返回指定对象的一份拷贝
 2>id object_dispose(id obj)释放指定对象占用的内存
 3>Ivar object_setInstanceVariable(id obj, const char *name, void *value)修改实例变量的值
 4>Ivar object_getInstanceVariable(id obj, const char *name, void **outValue)获取实例变量的值
 5>void *object_getIndexedIvars(id obj)返回指向给定对象分配的任何额外字节的指针
 *注意的是上述方法在ARC状态下不可用
 6>id object_getIvar(id obj, Ivar ivar) 返回对象中实例变量的值
 7>void object_setIvar(id obj, Ivar ivar, id value)设置对象中实例变量的值
 */
    
/*
 ====>>>>>>针对类进行操作的函数
 1>const char *object_getClassName(id obj)返回给定对象的类名
 2>Class object_getClass(id obj) 返回对象的类
 3>Class object_setClass(id obj, Class cls)设置对象的类
 */

/*
 ====>>>>>>获取类定义
 1>int objc_getClassList(Class *buffer, int bufferCount)获取已注册的类定义列表
 2>Class *objc_copyClassList(unsigned int *outCount)创建并且返回一个指向所有已注册类的的指针列表
 ****返回指定类的类定义
 3>Class objc_lookUpClass(const char *name)
 4>Class objc_getClass(const char *name)
 5>Class objc_getRequiredClass(const char *name)
 6>Class objc_getMetaClass(const char *name)返回指定类的元类
 */
#pragma mark 下面在main.m中列举一些实例


    
    
    
}

@end
