//
//  CSServerViewController.m
//  ChatServer
//
//  Created by 刘杨 on 2017/11/3.
//  Copyright © 2017年 Married. All rights reserved.
//

#import "CSServerViewController.h"
#import "AppDelegate.h"
#import "CSUserDefaultStore.h"
#import "CSServerConnectedCell.h"

@interface CSServerViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;

@property (nonatomic, strong) NSMutableDictionary *datas;
@end

@implementation CSServerViewController

- (void)dealloc{
    
}

- (IBAction)connectionBtnAction:(id)sender {
    NSInteger port = [self.portTextField.text integerValue];
    [CSUserDefaultStore setPort:port];
    
    if (self.connectBtn.isSelected) {
        [[ChatServerClient server] endListen];
        self.connectBtn.selected = NO;
    }else{
        [[ChatServerClient server] beginListen:port];
        self.connectBtn.selected = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.portTextField.text = @([CSUserDefaultStore port]).stringValue;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 64;
    
    [ChatClient addObserver:self selector:@selector(serverNotification:) forNotificationName:ChatServerStringNotification];
    
    self.datas = [NSMutableDictionary dictionary];
    [self.tableView registerNib:[UINib nibWithNibName:[CSServerConnectedCell name] bundle:nil] forCellReuseIdentifier:[CSServerConnectedCell identifier]];
}

- (void)serverNotification:(NSNotification *)notification{
    NSString *method = notification.userInfo[@"method"];
    if ([method isEqualToString:ChatServerStringDidConnected]) {
        CSConnection *connection = notification.userInfo[@"connection"];
        CSSocketAddress *address = [connection.address copy];
        address.online = YES;
        self.datas[[CSConnection connectionKey:address.socket]] = address;
    }else if ([method isEqualToString:ChatServerStringDidDisconnected]){
        CSConnection *connection = notification.userInfo[@"connection"];
        CSSocketAddress *address = [connection.address copy];
        CSSocketAddress *currentAddress = self.datas[[CSConnection connectionKey:address.socket]];
        currentAddress.online = NO;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.allValues.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CSServerConnectedCell *cell = [tableView dequeueReusableCellWithIdentifier:[CSServerConnectedCell identifier] forIndexPath:indexPath];
    CSSocketAddress *address = self.datas.allValues[indexPath.row];
    cell.ipLabel.text = [NSString stringWithFormat:@"ip: %@", address.address];
    cell.stateLabel.text = [NSString stringWithFormat:@"state: %@", address.online ? @"连接": @"断开"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end






