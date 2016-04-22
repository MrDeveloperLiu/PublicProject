//
//  LYHeader.h
//  TestMasnory_Demo
//
//  Created by 刘杨 on 15/8/16.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 *  in the part you should insert the <Masonry>and<SDWebImage+Cache> or leading to a crash
 *
 *  @param indexPage the current page of the
 */


//block
typedef void(^IndexPage)(NSInteger indexPage);
//
//
@protocol LYHeaderDelegate <NSObject>

@optional
- (void)headerIndexPage:(NSInteger)indexPage;

@end


//
@interface LYHeader : UIView

/**
 *  super methods
 */
+ (LYHeader *)headerWithArray:(NSArray *)array;

/**
 *  begin the timer
 */
- (void)beginTimer;
/**
 *  stop the timer
 */
- (void)stopTimer;

//self delegate
@property (nonatomic, weak) id<LYHeaderDelegate> delegate;

/**
 *  deliver data with block
 */
@property (nonatomic, copy) IndexPage block;

/**
 *  the index page
 *
 *  @param block indexPage
 */
- (void)getIndexPageWithBlock:(IndexPage)block;

@end
