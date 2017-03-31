#import "XMPersonalInformationViewController.h"

@interface XMPersonalInformationViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong, readwrite) XMPersonalInfoViewModel *viewModel;
@property (nonatomic, strong) XMPersonalInfoShowSource *dataSource;
@end

@implementation XMPersonalInformationViewController

+ (XMPersonalInformationViewController *)personVCWithViewModel:(XMPersonalInfoViewModel *)model{
    XMPersonalInformationViewController *vc = [[XMPersonalInformationViewController alloc] init];
    vc.viewModel = model;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//透明色
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor] , NSFontAttributeName : [UIFont systemFontOfSize:20]};
    
    [self.view addSubview:self.tableView];
    [self.dataSource registerTableViewCellsInTableView:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(- 64, 0, 0, 0);
    
    self.title = @"中移动";
    // Do any additional setup after loading the view.
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
