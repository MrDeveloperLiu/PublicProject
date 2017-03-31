//
//  ViewController.m
//  tttttt
//
//  Created by developer_liu on 17/2/10.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "ViewController.h"
#import "NetworkOperation.h"
#import "ChatTableViewCell.h"
#import "ChatEmoji.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    
    NSArray *es = [ChatEmoji loadEmojiPlist];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.sectionIndexColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    [self.tableView registerClass:[ChatTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ChatTableViewCell class])];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    
    
    NSString *text = @"大家好, 我是一个[feixin1thu]http://www.baidu.com, 哈哈哈哈, [feixin2thu][feixin3thu][feixin4thu][feixin5thu][feixin6thu], 小亲亲";
    NSString *t = @"嗯啊, 你好呀";
    NSString *t1 = @"啊呵呵哈哈哈";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @autoreleasepool {
            
            self.datas = [NSMutableArray array];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                for (int i = 0; i < 50; i++) {
                    @autoreleasepool {
                        
                        ChatModel *m = [[ChatModel alloc] init];
                        m.messageID = i + 1;
                        int a = i % 3;
                        if (!a) {
                            m.object = ChatObjectGroup;
                            m.content = text;
                        }else if (a == 1){
                            m.object = ChatObjectMe;
                            m.content = t;
                        }else if (a == 2){
                            m.object = ChatObjectOthers;
                            m.content = t1;
                        }
                        [self.datas addObject:m];
                        
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
                
            });
            
        }
        
    });
    

    
    /*
    for (int i = 0; i < 10; i++) {
        NetworkOperation *operation = [[NetworkOperation alloc] initWithBaseURL:@"http://www.cnblogs.com/kenshincui/p/4824810.html"];
        [operation setFailedBlock:^(NSURLSessionDataTask *task, NSURLResponse *response, NSError *error) {
            NSLog(@"failed\n %@", error.localizedDescription);
        }];
        [operation setFinishBlock:^(NSURLSessionDataTask *task, NSURLResponse *response, NSData *responseObject) {\
            id json = [NSJSONSerialization JSONObjectWithData:responseObject
                                                      options:NSJSONReadingMutableLeaves
                                                        error:NULL];
            NSLog(@"success\n %@ \n %@", json, responseObject);
        }];
        
        [self.queue addOperation:operation];
    }
    */
//    [self.queue cancelAllOperations];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = NSStringFromClass([ChatTableViewCell class]);
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ChatModel *m = self.datas[indexPath.row];
    [cell setModel:m];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatModel *m = self.datas[indexPath.row];
    return m.rowHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
