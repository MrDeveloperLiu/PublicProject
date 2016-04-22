//
//  XMDeleteAlonePersonViewController.h
//  Efetion
//
//  Created by 刘杨 on 15/12/8.
//
//

#import <UIKit/UIKit.h>

@class LYActionMenuViewController;
@protocol LYActionMenuViewControllerDelegate <NSObject>
@optional
- (void)deleteAlonePersonViewController:(LYActionMenuViewController *)vc deletePerson:(id)data;
- (void)deleteAlonePersonViewController:(LYActionMenuViewController *)vc cancelOrder:(id)data;
@end

@interface LYActionMenuViewController : UIViewController
/**
 *  把自己展示出来
 *
 *  @param delegate 代理
 *  @param vc       在哪个controller中
 *  @param data     要删除的XMData对象
 */
+ (void)showDeleteMenuWithDelegate:(id<LYActionMenuViewControllerDelegate>)delegate
                  inViewController:(UIViewController *)vc
                              data:(id)data;
@end
