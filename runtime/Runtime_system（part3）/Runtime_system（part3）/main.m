//
//  main.m
//  Runtime_system（part3）
//
//  Created by 刘杨 on 15/10/1.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "ViewController.h"
#import "Person.h"
#import "Asker.h"
#import "Handler.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
/*
        
        SEL sel1 = @selector(method1);
        NSLog(@"sel1 : %p", sel1);
        //输出为sel1 : 0x106ef8f58

    
        Person *person = [[Person alloc] init];
        [person method];
        //输出为<Person: 0x7fd1f0c00020>, 0x108dc1f68
        //显然self 打印的是一个object信息，<所属类: 对象内存地址>，而_cmd打印出来的是IMP，我们说它也是一块内存地址，指向的是一块结构体内存地址(我猜的啊。。)
        
    
*/
        
        /*
        
        Asker *asker = [Asker object];
        [asker sendUnkownMessage];
        //输出结果为<Person: 0x7f88aaf012e0> : 来处理这个消息了
        //显然，这个Person替Asker类来处理这个未知方法(此方法并没有在Asker类里实现)
    
        */
    
    
        /*
        Handler *handler = [Handler object];
        [handler sendUnkownMessage];
        //输出结果<Person: 0x7f878a603d30> : 来处理这个消息了
        //虽然，我们没有在Person类里声明这个方法，但是实际上它也去调用了，这就表示，我们可以使用runtime系统来使用苹果的私有方法,私有变量,私有属性等
         */
    
    
    
    
    
    
    
    
    
    }
}
