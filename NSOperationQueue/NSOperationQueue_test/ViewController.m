//
//  ViewController.m
//  NSOperationQueue_test
//
//  Created by 刘杨 on 15/9/27.
//  Copyright © 2015年 刘杨. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /*
    //1.NSOperationQueue 队列  NSOperation任务块
    //这两个本身都不是多线程，它实现多线程的原理是，将任务块放到队列里，队列会根据你所设置的最大线程数，开辟合适的线程来实现，多任务并发进行，但是注意的是正确的理解是：队列并发执行，但是任务确实串发执行的，通过线程实现的任务，需要手动建立一个自动释放池，如下：
    
    //就给开了一个线程
    NSInvocationOperation *opeartion1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(compute) object:nil];
    
    
    NSBlockOperation *opeartion2 = [NSBlockOperation blockOperationWithBlock:^{
        [self compute];
    }];
    //添加任务块
    [opeartion2 addExecutionBlock:^{
        NSLog(@"love you");
    }];
    
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 6;
    //两个任务加在一个队列里实际上是新开辟了一块线程，并且线程线程之间并发执行
    [queue addOperation:opeartion1];
    [queue addOperation:opeartion2];
    */
    
    /*
    //2.NSThread 需要手动管理线程
    //1>.初始化方法创建一个线程
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(compute) object:nil];
    [thread start];
    [thread cancel];
    
    //2>.通过类方法直接创建一个线程，自动开始线程内的任务
    [NSThread detachNewThreadSelector:@selector(compute) toTarget:self withObject:nil];
    [NSThread exit];
    */
    
    /*
    //3.本身，NSObject的分类里，NSThread就给其添加了一个隐式的开辟了一个线程的方法
    [self performSelectorInBackground:@selector(compute) withObject:nil];
    */
    
    //4.GCD
    //GCD 也同NSOperationQueue一样，也是通过创建队列，并为队列分配任务的方式现实的多线程技术，但是好处是，代码执行效率高，因为它是底层API，由C语言编写
    //GCD有两种队列，1.串行队列（必须等到一个任务执行完毕之后另一个任务才会执行）2.并行队列（其实也是有先后执行顺序的，但是它不会等到你第一个任务完毕之后才会去执行下一个任务，相当于你block体里异步执行的方法一样）3.组队列（毫无疑问，就是可以将所有同种任务全部放在一个组里执行）
    //当然GCD也为开发者提供了两个便捷的创建队列的方式
    //1.获取全局主线程队列
    //    dispatch_get_main_queue();
    //2.获取全局子线程队列
    //    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);//第一个参数，队列类型，第二个参数是苹果预留的参数，目前填0
    
    
    //1>串行队列
    //创建一个子线程串发执行的队列
    
    /*
    dispatch_queue_t queue = dispatch_queue_create("com.sina", DISPATCH_QUEUE_SERIAL);//第一个参数，通常以公司的反向域名命名，第二个参数，队列类型：serial串行队列
    dispatch_async(queue, ^{
        NSLog(@"第一个任务");
    });
    dispatch_async(queue, ^{
        NSLog(@"第二个任务");
    });
    dispatch_async(queue, ^{
        NSLog(@"第三个任务");
    });
     */
    /*
    //2>并行队列
    dispatch_queue_t queue = dispatch_queue_create("com.sina", DISPATCH_QUEUE_CONCURRENT);//concurrent 并行队列
    dispatch_async(queue, ^{
        NSLog(@"第一个任务");
    });
    dispatch_async(queue, ^{
        NSLog(@"第二个任务");
    });
    dispatch_async(queue, ^{
        NSLog(@"第三个任务");
    });
     */
/*
 
    //3>组队列
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("com.sina", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue, ^{
        NSLog(@"第一个任务");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"第二个任务");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"第三个任务");
    });
    //利用notify，用来检测，什么时候组任务执行完毕之后，来执行这里面的方法
    dispatch_group_notify(group, queue, ^{
        NSLog(@"mission complete");
    });
    //利用barrier来终端组队列任务（先执行完barrier再执行组队列里的任务）
//    dispatch_barrier_async(queue, ^{
//        NSLog(@"呵呵 我是来捣乱的");
//    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"第一个任务");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"第二个任务");
    });
    dispatch_group_async(group, queue, ^{
        NSLog(@"第三个任务");
    });
*/
    
    /*
  //4>某个任务执行多次
    dispatch_queue_t queue = dispatch_queue_create("com.sina", DISPATCH_QUEUE_CONCURRENT);
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    dispatch_apply(array.count, queue, ^(size_t index) {
        NSLog(@"我是第%@次任务", array[index]);
    });
     */
    
    /*
    //5>通过GCD调用函数指针，来执行函数的实现

    NSString *context = @"今天有小雨，好美丽";
    dispatch_queue_t queue = dispatch_queue_create("com.sina", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async_f(queue, (__bridge void *)(context), function);//    第一个参数队列，第二个参数任意对象类型，但是需要桥接，第三个参数是函数名；注意要使用这个方法，函数必须是void fun（void *）类型
     */
}

void function (void *context){
    NSLog(@"%@, %@", context, [NSThread currentThread]);
}



- (void)compute{
    @autoreleasepool {
        [self computeNumber];
    }
}

- (void)computeNumber{
    NSLog(@"%@", [NSThread currentThread]);
    NSInteger i = 0;
    while (i < 20) {
        NSLog(@"%ld", i++);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
