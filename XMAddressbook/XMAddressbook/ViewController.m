//
//  ViewController.m
//  XMAddressbook
//
//  Created by developer_liu on 17/1/12.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "ViewController.h"
#import "XMAddressbookHelper.h"
#import "UIViewMacro.h"
#import "AddressbookCell.h"
#import "DetialViewController.h"
#import "SearchResultViewController.h"
#import "XMResizeableButton.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, ABNewPersonViewControllerDelegate, UIAlertViewDelegate, UISearchControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *remindLabel;

@property (nonatomic, strong) NSMutableDictionary *dict;
@property (nonatomic, strong) NSMutableArray *keys;
@property (nonatomic, strong) UISearchController *searchVC;
@end

@implementation ViewController

NSObjectPropertyLazyloadAllocWithZone(UITableView,
                                      tableView,
                                      _tableView,
                                      NSObjectPropertySetter(^{
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}))

UIViewPropertyLazyload(UILabel,
                       remindLabel,
                       _remindLabel,
                       NSObjectPropertySetter(^{
    _remindLabel.text = @"当前没有获取到通讯录权限, 请在设置-隐私-通讯录中允许通讯录访问";
    _remindLabel.numberOfLines = 0;
}))

void AddressbookCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context){
    NSDictionary *dict = (__bridge NSDictionary *)info;
    [[NSNotificationCenter defaultCenter] postNotificationName:kAddressbookChange object:nil userInfo:dict];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [XMAddressbookHelper unRegistChangeWithCallBack:AddressbookCallback context:NULL];
}

- (void)loadAddressbook{
    NSArray *source = [XMAddressbookHelper loadAddressbookToModel:kABPersonSortByLastName];
    NSDictionary *dict = [XMAddressbookHelper transferDictWithArray:source];
    NSArray *keys = [XMAddressbookHelper keyArraySort:dict];
    
    self.dict = (NSMutableDictionary *)dict;
    self.keys = (NSMutableArray *)keys;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"通讯录";
    
    /*
    XMResizeableButton *btn = [XMResizeableButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"icon_mail_doc"] forState:UIControlStateNormal];
    [btn setTitle:@"移除我啊!!哈哈哈" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn resizeImageWithBlock:^CGRect(CGRect contectRect) {
        return (CGRect){20, 5, contectRect.size.height - 5 * 2, contectRect.size.height - 5 * 2};
    }];
    [btn resizeTitleWithBlock:^CGRect(CGRect contectRect, CGRect imageRect) {
        CGFloat x = 20 + 10 + contectRect.size.height - 5 * 2;
        return (CGRect){x, 5, contectRect.size.width - x - 20, contectRect.size.height - 5 * 2};
    }];
    [self.view addSubview:btn];
    btn.frame = VRect(0, 100, USSizeW, 50);
    btn.layer.cornerRadius = 5;
    btn.layer.borderColor = [[UIColor blackColor] CGColor];
    btn.layer.borderWidth = 0.5;
    */
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[AddressbookCell class]
           forCellReuseIdentifier:NSStringFromClass([AddressbookCell class])];
    [self.tableView registerClass:[UITableViewHeaderFooterView class]
forHeaderFooterViewReuseIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
    [self.view addSubview:self.remindLabel];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddressbookChangeNotification:) name:kAddressbookChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddressbookGrandNotification:) name:kAddressbookGrand object:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPerson:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchPerson:)];
 
    [self chooseShow];
 
    
}

- (void)AddressbookChangeNotification:(NSNotification *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAddressbook];
        [self.tableView reloadData];
    });
}

- (void)AddressbookGrandNotification:(NSNotification *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        [XMAddressbookHelper createAddressbook];
        [self chooseShow];
        [self.tableView reloadData];
    });
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddressbookGrand object:nil];
}

- (void)chooseShow{
    if ([XMAddressbookHelper haveAuthor]) {
        self.remindLabel.hidden = YES;
        //data soucre
        [self loadAddressbook];
        [XMAddressbookHelper registChangeWithCallBack:AddressbookCallback context:NULL];
        
    }else{
        self.remindLabel.hidden = NO;
    }
}

- (void)searchPerson:(id)sender{
    SearchResultViewController *resultVC = [[SearchResultViewController alloc] initWithStyle:UITableViewStylePlain]
    ;
    UISearchController *searchVC = [[UISearchController alloc] initWithSearchResultsController:resultVC];
    searchVC.searchResultsUpdater = resultVC;
    searchVC.delegate = self;
    [self presentViewController:searchVC animated:YES completion:nil];
    
    self.searchVC = searchVC;
}

- (void)didDismissSearchController:(UISearchController *)searchController{
    _searchVC = nil;
}

- (void)presentSearchController:(UISearchController *)searchController{
    NSLog(@"Present Search ViewController");
}


- (void)addNewPerson:(id)sender{
    UINavigationController *vc = [XMAddressbookHelper addNewPersonViewControllerWithPerson:NULL delegate:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:vc animated:YES completion:nil];
    });
}

- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
    [newPersonView dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.keys;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass([UITableViewHeaderFooterView class])];
    view.contentView.backgroundColor = [UIColor lightTextColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.keys.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dict[self.keys[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddressbookCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddressbookCell class])];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    XMABRecordModel *model = self.dict[self.keys[indexPath.section]][indexPath.row];
    [(AddressbookCell *)cell setTitle:model.name];
    [(AddressbookCell *)cell setIcon:model.icon];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    [(UITableViewHeaderFooterView *)view textLabel].text = self.keys[section];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DetialViewController *detailVC = [[DetialViewController alloc] init];
    detailVC.model = self.dict[self.keys[indexPath.section]][indexPath.row];
    detailVC.push = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *key = self.keys[indexPath.section];
    NSMutableArray *temp = self.dict[key];
    XMABRecordModel *model = temp[indexPath.row];
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:0 title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if ([XMAddressbookHelper deletePersonWithID:model.rid]) {
            NSMutableArray *remove = [NSMutableArray array];
            NSMutableArray *indexPaths = [NSMutableArray array];
            [temp enumerateObjectsUsingBlock:^(XMABRecordModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.rid == model.rid) {
                    [remove addObject:obj];
                    NSIndexPath *index = [NSIndexPath indexPathForRow:idx inSection:indexPath.section];
                    [indexPaths addObject:index];
                }
            }];
            [temp removeObjectsInArray:remove];
            
            if (!temp.count) {
                [self.dict removeObjectForKey:key];
                [self.keys removeObject:key];
                [self.tableView reloadData];
            }else{
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }
        
    }];
    
    return @[deleteAction];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;

    CGSize s = (CGSize){USSizeW - 60, 100};
    self.remindLabel.frame = VCenterRect(self.view.bounds, s);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
