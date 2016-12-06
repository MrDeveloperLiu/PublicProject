//
//  XMCirleView.h
//  功能: 轮播图
//  作者: 刘杨
//  创建日期: 2016-11-14
//  最近修改: 2016年11月24日17:13:56
//

#import <UIKit/UIKit.h>

//cache directory
FOUNDATION_EXPORT NSString *const XMCirleViewCache;

@protocol XMCirleViewDelegate;
@interface XMCirleView : UIView
//delegate if you want to call method  'cirleView:clickedAtIndex:'
@property (nonatomic, weak, readonly)   id<XMCirleViewDelegate> delegate;
//images
@property (nonatomic, strong, readwrite) NSArray *images;
//titles's count must be equal to the images
@property (nonatomic, strong, readwrite) NSArray *titles;
//placeholder
@property (nonatomic, strong, readonly) UIImage *placeholder;
//default is 3's
@property (nonatomic, assign, readonly) NSTimeInterval looptime;

//begin loop
- (void)beginTimer;
//stop loop
- (void)invalidTimer;
//clear disk cache immdiately 
+ (void)clearDiskCache;
//resize image With size
+ (UIImage *)resizeImageWithSize:(CGSize)size image:(UIImage *)image;

/**
 @param images      <it can be NSString * or UIImage *>
 @param placeholder placeImage
 @param interval    looptime
 return XMCirleView *
 */
+ (XMCirleView *)cirleViewWithImages:(NSArray *)images placeholder:(UIImage *)placeholder
                            interval:(NSTimeInterval)interval delegate:(id<XMCirleViewDelegate>)delegate;
@end

@protocol XMCirleViewDelegate <NSObject>
@optional
//id<XMCirleViewDelegate> if you not set, never to call this
- (void)cirleView:(XMCirleView *)view clickedAtIndex:(NSInteger)index;
- (void)cirleView:(XMCirleView *)view clickedTitleAtIndex:(NSInteger)index;
@end


@protocol XMCirleImageViewDelegate;
@interface XMCirleImageView : UIImageView
@property (nonatomic, weak)   id<XMCirleImageViewDelegate> delegate;
@property (nonatomic, assign) NSInteger index;
@end

@protocol XMCirleImageViewDelegate <NSObject>
- (void)cirleImageView:(XMCirleImageView *)view clickedAtIndex:(NSInteger)index;
@end
