//
//  MenuView.h
//  Cass
//
//  Created by 刘杨 on 16/3/29.
//  Copyright © 2016年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LYMenuViewDelegate;
@class LYMenuViewItem, LYMenuViewDataSource;
@interface LYMenuView : UIView
@property (nonatomic, strong)                       UIColor     *menuColor;// default is clearColor
@property (nonatomic, assign)                       BOOL        scrollEnable;//defult is NO
//function : initialized the menu view with delegate and its datasource
+ (LYMenuView *)menuViewWithDelegate:(id<LYMenuViewDelegate>)delegate items:(NSArray<LYMenuViewItem *> *)items;
//function : show it
- (void)show:(BOOL)animate fromView:(UIView *)view toView:(UIView *)view;
//function : hide it
- (void)hide:(BOOL)animate;
@end

@protocol LYMenuViewDelegate <NSObject>
@required
//protocol must be implementation
- (void)menuView:(LYMenuView *)view tableView:(UITableView *)tableView
didSelectedRowAtIndexPath:(NSIndexPath *)indexPath dataSource:(LYMenuViewDataSource *)dataSource;
@end

@interface LYMenuViewItem : NSObject
//menu item with different content and selected status
@property (nonatomic, strong)                       UIImage     *image;
@property (nonatomic, copy)                         NSString    *title;
@property (nonatomic, strong)                       UIImage     *selectedImage;
@property (nonatomic, copy)                         NSString    *selectedTitle;
@property (nonatomic, assign, getter=isSelected)    BOOL        selected;
@end


//those not be implementation and it use to LYMenuView's datasource
@interface LYMenuViewDataSource : NSObject<UITableViewDataSource>
@property (nonatomic, strong)                       NSArray     *datas;
- (instancetype)initWithItems:(NSArray<LYMenuViewItem *> *)items tableView:(UITableView *)tableView;
@end

@interface LYMenuCell : UITableViewCell
@property (nonatomic, strong)                       UIImageView *iconView;
@property (nonatomic, strong)                       UILabel     *titleLabel;
@end