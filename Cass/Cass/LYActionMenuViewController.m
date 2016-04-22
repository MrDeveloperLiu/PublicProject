//
//  XMDeleteAlonePersonViewController.m
//  Efetion
//
//  Created by 刘杨 on 15/12/8.
//
//
#define kAnimationDuration 0.23
#define kRowHight 45
#define kDeleteCellIndentifer @"LYActionMenuViewController"

#import "LYActionMenuViewController.h"

@interface LYActionMenuViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)       UITableView *tableView;
@property (nonatomic, weak)         id<LYActionMenuViewControllerDelegate> delegate;
@property (nonatomic, strong)       id data;
@property (nonatomic, strong)       UIView *container;
@end

@implementation LYActionMenuViewController

+ (void)showDeleteMenuWithDelegate:(id<LYActionMenuViewControllerDelegate>)delegate
                  inViewController:(UIViewController *)vc
                              data:(id)data{
    LYActionMenuViewController *deleteVC = [[LYActionMenuViewController alloc] init];
    deleteVC.delegate = delegate;
    deleteVC.data = data;
    [deleteVC showSelfController:deleteVC InViewController:vc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置view的初始状态
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.container];
    [self.view addSubview:self.tableView];
    
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    self.container.frame = self.view.bounds;
    self.tableView.frame = CGRectMake(0,
                                      h,
                                      w,
                                      kRowHight * 2);
    
    //注册cell
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kDeleteCellIndentifer];
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.rowHeight = kRowHight;
        _tableView.scrollEnabled = NO;//不让其滑动
        _tableView.layer.cornerRadius = 2;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (UIView *)container{
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        _container.alpha = 0;
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapGRAction:)];
        [_container addGestureRecognizer:tapGR];
    }
    return _container;
}

- (void)tapGRAction:(UITapGestureRecognizer *)sender{
    [self removeSelf];
}

- (void)showSelfController:(LYActionMenuViewController *)selfContrlloer
          InViewController:(UIViewController *)viewController{
    //load view in view controller
    [viewController addChildViewController:selfContrlloer];
    [viewController.view addSubview:selfContrlloer.view];

    //animation
    [UIView animateWithDuration:kAnimationDuration animations:^{
        selfContrlloer.container.alpha = 1;
        
        selfContrlloer.tableView.transform = CGAffineTransformMakeTranslation(0, -kRowHight * 2);
    }];
}

- (void)removeSelf{
    //渐隐效果将view移除
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.container.alpha = 0;
        
        self.tableView.transform = CGAffineTransformMakeTranslation(0, kRowHight * 2);
    }completion:^(BOOL finished) {
        //remove view controller
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDeleteCellIndentifer];
    if (0 == indexPath.section) {
        cell.textLabel.text = @"移除该成员";
        cell.textLabel.textColor = [UIColor redColor];
    }else if (1 == indexPath.section){
        cell.textLabel.text = @"取消";
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section) {
        //回调代理方法通知delegate 进行了移除群成员的操作
        if ([self.delegate respondsToSelector:@selector(deleteAlonePersonViewController:deletePerson:)]) {
            [self.delegate deleteAlonePersonViewController:self deletePerson:self.data];
        }
    }else if (1 == indexPath.section){
        //回调代理方法通知delegate 取消操作
        if ([self.delegate respondsToSelector:@selector(deleteAlonePersonViewController:cancelOrder:)]) {
            [self.delegate deleteAlonePersonViewController:self cancelOrder:self.data];
        }
    }
    [self tapGRAction:nil];//回调完毕,默认移除自己
}
@end
