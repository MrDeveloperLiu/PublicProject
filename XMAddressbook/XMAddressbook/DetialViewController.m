//
//  DetialViewController.m
//  XMAddressbook
//
//  Created by developer_liu on 17/1/13.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "DetialViewController.h"
#import "UIViewMacro.h"
#import "NSObject+RoundImage.h"
#import "AddressbookCell.h"

@interface DetialViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation DetialViewController

NSObjectPropertyLazyloadAllocWithZone(UITableView, tableView, _tableView, NSObjectPropertySetter(^{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
}))

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.model.name;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:NSStringFromClass([self class])];
    [self.tableView registerClass:[AddressbookCell class]
           forCellReuseIdentifier:NSStringFromClass([AddressbookCell class])];
    
    if (!self.isPush) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    }
}

- (void)back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger number = 2;
    if (self.model.mobilephone.length) { number += 2; }
    if (self.model.email.length) { number += 1; }
    return number;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (0 == section) { return 1; }
    if (1 == section) { return 2; }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (0 == section) { return 1; }
    if (1 == section) { return 20; }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (0 == section) { return 4; }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) { return 90; }
    
    return 51;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifer = nil;
    if (0 == indexPath.section) {
        identifer = NSStringFromClass([AddressbookCell class]);
    }else{
        identifer = NSStringFromClass([self class]);
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = nil;
    
    if (2 == section) {
        view = [self btnWithTarget:self action:@selector(makePhoneCall:)
                             color:[UIColor redColor] title:@"打电话"];
    }else if (3 == section){
        view = [self btnWithTarget:self action:@selector(sendMessage:)
                             color:UIColorFromRGB(78, 129, 181) title:@"发短信"];;
    }else if (4 == section){
        view = [self btnWithTarget:self action:@selector(sendEmail:)
                             color:[UIColor purpleColor] title:@"写邮件"];
    }
  
    return view;
}


- (void)makePhoneCall:(id)sender{
    NSString *real = [self phoneNumber:self.model.mobilephone];
    [self phoneOpenURLProtocl:@"tel://" string:real];
}

- (void)sendMessage:(id)sender{
    NSString *real = [self phoneNumber:self.model.mobilephone];
    [self phoneOpenURLProtocl:@"sms://" string:real];
}

- (void)sendEmail:(id)sender{
    [self phoneOpenURLProtocl:@"mailto://" string:self.model.email];
}

- (BOOL)phoneOpenURLProtocl:(NSString *)protocl string:(NSString *)string{
    NSString *url = [NSString stringWithFormat:@"%@%@", protocl, string];
    return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (0 == indexPath.section) {
        [(AddressbookCell *)cell setIcon:self.model.icon];
        [(AddressbookCell *)cell setTitle:self.model.name];
    }else{
        NSDictionary *norAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor grayColor]};
        NSDictionary *detialAttr = @{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : UIColorFromRGB(25, 133, 132)};
        
        if (0 == indexPath.row) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"电话:   " attributes:norAttr];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.model.mobilephone ?: @"无" attributes:detialAttr]];
            cell.textLabel.attributedText = string;
        }else if (1 == indexPath.row){
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:@"邮箱:   " attributes:norAttr];
            [string appendAttributedString:[[NSAttributedString alloc] initWithString:self.model.email ?: @"无" attributes:detialAttr]];
            cell.textLabel.attributedText = string;
        }
    }
}


- (UIButton *)btnWithTarget:(id)target action:(SEL)action
                      color:(UIColor *)color title:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
