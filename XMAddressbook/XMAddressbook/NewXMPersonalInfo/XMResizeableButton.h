//  XMResizeableButton.h
//  Author : by Liuyang
//  Date : 2017-02-09

/*  This Class provide a resizeable UIButton's  imageRect and titleRect
 *  Don't do anthing else calculate rect from contentRect in those block
 */

#import <UIKit/UIKit.h>

@interface XMResizeableButton : UIButton

- (void)resizeImageWithBlock:(CGRect (^)(CGRect contectRect))block;
- (void)resizeTitleWithBlock:(CGRect (^)(CGRect contectRect, CGRect imageRect))block;
- (void)addTouchUpInSideTarget:(id)target action:(SEL)action;

@end
