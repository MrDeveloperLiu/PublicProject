//
//  RootViewController.m
//  Cass
//
//  Created by 刘杨 on 16/3/29.
//  Copyright © 2016年 刘杨. All rights reserved.
//
#define screenW [UIScreen mainScreen].bounds.size.width
#define screenH [UIScreen mainScreen].bounds.size.height

#import "RootViewController.h"
#import "LYMenuView.h"
#import <objc/message.h>

NSString *identifier = @"cell_1";

@interface RootViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, LYMenuViewDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LYMenuView *menu;
@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor greenColor];
    [self initialized];
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:identifier];
    
    
    
//    ((void(*)(id, SEL, ...))objc_msgSend)(self, @selector(haha:), @"en");

}

- (void)haha:(id)en{
    NSLog(@"%@", en);
}

- (void)menuView:(LYMenuView *)view tableView:(UITableView *)tableView
didSelectedRowAtIndexPath:(NSIndexPath *)indexPath dataSource:(LYMenuViewDataSource *)dataSource{
    LYMenuViewItem *item = dataSource.datas[indexPath.row];
    item.selected = !item.isSelected;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)hide{
    [self.menu hide:YES];
}

- (void)initialized{
    [self.view addSubview:self.collectionView];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blackColor];
    [btn setTitle:@"隐藏" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(100, 200, [UIScreen mainScreen].bounds.size.width - 200, 30);
    [self.view addSubview:btn];
    
    int count = 9;
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i ++) {
        LYMenuViewItem *item = [[LYMenuViewItem alloc] init];
        item.title = [NSString stringWithFormat:@"number %d", i + 1];
        item.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", i + 1]];
        item.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d", count - i]];
        item.selectedTitle = [NSString stringWithFormat:@"number %d", count - i];
        
        [array addObject:item];
    }
    
    self.menu = [LYMenuView menuViewWithDelegate:self items:array];
    [self.view addSubview:self.menu];
    self.menu.scrollEnable = YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.menu hide:NO];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 70;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    float r = arc4random_uniform(256)/255.0;
    float g = arc4random_uniform(256)/255.0;
    float b = arc4random_uniform(256)/255.0;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:r
                                                       green:g
                                                        blue:b alpha:1];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self.menu show:YES fromView:cell toView:self.view];
}

- (UICollectionViewFlowLayout *)layout{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];

        _layout.itemSize = CGSizeMake(screenW / 4, screenH / 5);
        _layout.minimumInteritemSpacing = 0;
        _layout.minimumLineSpacing = 0;
        _layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _layout;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,
                                                                             100,
                                                                             screenW,
                                                                             screenH-100)
                                             collectionViewLayout:self.layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
