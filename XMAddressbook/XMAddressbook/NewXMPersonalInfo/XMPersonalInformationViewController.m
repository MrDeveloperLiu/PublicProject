#import "XMPersonalInformationViewController.h"

@interface XMPersonalInformationViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readwrite) XMPersonalInfoViewModel *viewModel;
@property (nonatomic, strong) XMPersonalInfoShowSource *dataSource;
@end

@implementation XMPersonalInformationViewController

- (void)dealloc{
    NSLog(@"%s", __func__);
}

+ (XMPersonalInformationViewController *)personVCWithViewModel:(XMPersonalInfoViewModel *)model{
    XMPersonalInformationViewController *vc = [[XMPersonalInformationViewController alloc] init];
    vc.viewModel = model;
    return vc;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor] , NSFontAttributeName : [UIFont boldSystemFontOfSize:20]};

}

//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//透明色
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    
    [self.view addSubview:self.tableView];
    [self.dataSource registerTableViewCellsInTableView:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
    
    self.title = @"中移动";
    // Do any additional setup after loading the view.
}

#pragma mark cell's delegate
- (void)protraitCell:(XMPerosnalInfoProtraitCell *)cell clickAtProtrait:(UIButton *)btn{
    NSLog(@"点击了头像按钮呀呀呀/// (type: %lu)", cell.type);
}
- (void)phoneCell:(XMPerosnalInfoPhoneCell *)cell copyAtInfoBtn:(UIButton *)btn{
    NSLog(@"拷贝了啊 //(type: %lu)", cell.type);
}
- (void)phoneCell:(XMPerosnalInfoPhoneCell *)cell clickAtInfoBtn:(UIButton *)btn{
    NSLog(@"点击了文字啊 (type: %lu)", cell.type);
}
- (void)phoneCell:(XMPerosnalInfoPhoneCell *)cell clickAtActionBtn:(UIButton *)btn{
    NSLog(@"点击了图片按钮啊 打电话啊// (type: %lu)", cell.type);
}
- (void)functionButtonCell:(XMPerosnalInfoFunctionButtonCell *)cell clickAtBtn:(UIButton *)btn{
    NSLog(@"点击多功能按钮啊// (type: %lu)", cell.type);
    
//    [UIApplication sharedApplication].keyWindow.rootViewController = [UIViewController new];
}
- (void)normalButtonCell:(XMPerosnalInfoNormalButtonCell *)cell clickAtBtn:(UIButton *)btn{
    NSLog(@"点击了普通按钮啊// (type: %lu)", cell.type);
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.frame;
}

- (XMPersonalInfoShowSource *)dataSource{
    if (!_dataSource) {
        _dataSource = [[XMPersonalInfoShowSource alloc] initWithViewController:self];
    }
    return _dataSource;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate = self.dataSource;
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
