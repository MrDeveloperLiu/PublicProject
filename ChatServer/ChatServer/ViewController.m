//
//  ViewController.m
//  ChatServer
//
//  Created by 刘杨 on 2017/9/2.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "ViewController.h"
#import "RegisterSqliteHelper.h"
#import "ChatConnection.h"
#import "CoreSocket.h"
#import "ChatMessage.h"

#define kPhone 1
#define kPhoneType @"iPhone"
#define kMacType @"Mac"

@interface ViewController () <CoreSocketDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *connectionBtn;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITableView *showView;
@property (weak, nonatomic) IBOutlet UITextField *chatTF;

@property (nonatomic, strong) CoreSocket *s;
@property (nonatomic, strong) CoreSocket *r;

@property (nonatomic, strong) NSMutableArray *chatArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if kPhone
#else
    NSInteger port = 9001;
    [self.s acceptOnPort:port error:nil];
    self.connectionBtn.hidden = YES;
#endif

    
    self.showView.delegate = self;
    self.showView.dataSource = self;
    
    _chatArray = [NSMutableArray array];
}


- (IBAction)send:(id)sender {
    NSString *msg = _chatTF.text;
    if (!msg.length) {
        return;
    }
    ChatMessage *message = [[ChatMessage alloc] init];
#if kPhone
    [message addHeader:kPhoneType forKey:@"From"];
    [message addHeader:kMacType forKey:@"To"];
#else
    [message addHeader:kMacType forKey:@"From"];
    [message addHeader:kPhoneType forKey:@"To"];
#endif
    
    [message addBody:@"Text" forKey:@"MessageType"];
    [message addBody:msg forKey:@"MessageContent"];
    
#if kPhone
    [self.r writeData:[message toMessage] timeOut:15];
#else
    [self.s writeData:[message toMessage] timeOut:15];
#endif
    
    [self addMessage:message];
    _chatTF.text = nil;
}

- (void)addMessage:(ChatMessage *)message{
    NSInteger index = _chatArray.count;

    [_chatArray addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index
                                                inSection:0];
    [self.showView insertRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationRight];
    [self.showView scrollToRowAtIndexPath:indexPath
                         atScrollPosition:UITableViewScrollPositionBottom
                                 animated:YES];
}

- (IBAction)connect:(id)sender {
    if (!self.connectionBtn.isSelected) {
        NSString *ip = @"192.168.1.100";
        
        NSInteger port = 9001;
        NSData *addr = [CoreSocket ipv4WithHost:ip port:port];
        if ([self.r connectToTheAddress:addr timeOut:10 error:nil]) {
            self.label.text = @"Connectiong";
        }
    }else{
        [self.r disconnect];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _chatArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    ChatMessage *message = _chatArray[indexPath.row];
    NSString *from = [message headerForKey:@"From"];
//    NSString *to = [message headerForKey:@"To"];
//    NSString *type = [message bodyForKey:@"MessageType"];
    NSString *msg = [message bodyForKey:@"MessageContent"];
    
    cell.textLabel.text = from;
    cell.detailTextLabel.text = msg;
    
    return cell;
}


- (void)onCoreSocket:(CoreSocket *)socket didConnectToTheHost:(NSString *)host port:(NSInteger)port{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = [NSString stringWithFormat:@"%@:%@", host, @(port)];
#if kPhone
        self.connectionBtn.selected = YES;
#else
#endif
    });
}
- (void)onCoreSocket:(CoreSocket *)socket disConnectToTheHost:(NSString *)host port:(NSInteger)port error:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = @"Disconnect";
#if kPhone
        self.connectionBtn.selected = NO;
#else
#endif
    });
}
- (void)onCoreSocket:(CoreSocket *)socket receiveData:(CoreSocketReadPacket *)packet{

}
- (void)onCoreSocket:(CoreSocket *)socket receiveDone:(CoreSocketReadPacket *)packet{
    dispatch_async(dispatch_get_main_queue(), ^{
        ChatMessage *message = [[ChatMessage alloc] initWithData:packet.data];
        [self addMessage:message];
    });
}

- (void)onCoreSocket:(CoreSocket *)socket writeDidTimeOut:(CoreSocketWritePacket *)packet{

}

- (void)onCoreSocket:(CoreSocket *)socket readDidTimeOut:(CoreSocketReadPacket *)packet{

}



- (CoreSocket *)r{
    if (!_r) {
        _r = [CoreSocket new];
        _r.delegate = self;
    }
    return _r;
}
- (CoreSocket *)s{
    if (!_s) {
        _s = [CoreSocket new];
        _s.delegate = self;
    }
    return _s;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
