//
//  SearchResultViewController.m
//  XMAddressbook
//
//  Created by developer_liu on 17/1/22.
//  Copyright © 2017年 MrDevelopLiu. All rights reserved.
//

#import "SearchResultViewController.h"
#import "XMAddressbookHelper.h"
#import "AddressbookCell.h"
#import "DetialViewController.h"

@interface SearchResultViewController ()
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation SearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[AddressbookCell class] forCellReuseIdentifier:NSStringFromClass([AddressbookCell class])];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchContent = searchController.searchBar.text;
    if (!searchContent.length) { return; }
    
    NSLog(@"text : {%@}", searchContent);
    NSMutableArray *array = (NSMutableArray *)[XMAddressbookHelper searchPersonByKey:searchContent];
    self.datas = array;
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressbookCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([AddressbookCell class]) forIndexPath:indexPath];
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    XMABRecordModel *model = self.datas[indexPath.row];
    
    [(AddressbookCell *)cell setIcon:model.icon];
    [(AddressbookCell *)cell setTitle:[model.name stringByAppendingString:model.mobilephone]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XMABRecordModel *model = self.datas[indexPath.row];
    DetialViewController *detailVC = [[DetialViewController alloc] init];
    detailVC.model = model;
    UINavigationController *detailNC = [[UINavigationController alloc] initWithRootViewController:detailVC];
    [self presentViewController:detailNC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
