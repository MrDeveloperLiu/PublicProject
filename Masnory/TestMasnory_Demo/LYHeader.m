//
//  LYHeader.m
//  TestMasnory_Demo
//
//  Created by 刘杨 on 15/8/16.
//  Copyright (c) 2015年 刘杨. All rights reserved.
//


/**
 *  如果想用从网络上请求的图片轮播，扔给我类方法一个url数组，我给你返回一组图片，但是需要把这个宏定义的kCount 去掉，并且将所有用到这个的地方替换成array.count
 
 ！！！！！！现在仅仅需要你将下面一行注释掉即可      ^_^~
 */

//#define kCount 10

#import "LYHeader.h"
#import <Masonry.h>
#import "UIImageView+WebCache.h"

@interface LYHeader ()<UIScrollViewDelegate>
{
    IndexPage _indexPageBlock;
    NSInteger _currentIndex;
    //---> BOOL that's the page control touch event if yes,return
    BOOL _isClicked;
}

//main view
@property (nonatomic, strong) UIView *mainView;
//container view
@property (nonatomic, strong) UIView *container;
//image view
@property (nonatomic, strong) UIImageView *imageView;
//timer
@property (nonatomic, strong) NSTimer *timer;
//scoll view
@property (nonatomic, strong) UIScrollView *scrollView;
//page control
@property (nonatomic, strong) UIPageControl *pageControl;

//array --> url array
@property (nonatomic, strong) NSArray *array;

@end

@implementation LYHeader

+ (LYHeader *)headerWithArray:(NSArray *)array{
    return [[self alloc] initWithArray:array];
}

- (instancetype)initWithArray:(NSArray *)array{
    if (self = [super init]) {
        
        _isClicked = NO;
        
#ifndef kCount
        //init array with picture url's array
        self.array = [NSArray arrayWithArray:array];
#endif
        //main view
        [self createMainView];
        //set delegate
        self.scrollView.delegate = self;
        //add timer
#ifdef kCount
        [self beginTimer];
#endif
    }
    return self;
}

/**
 *  main view
 */
- (void)createMainView{
    _mainView = [[UIView alloc] init];
    [self addSubview:_mainView];
    __weak __typeof(self) weakSelf = self;
    [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.edges.equalTo(weakSelf);
    }];
    //scrollview
    [self createScrollView];
}

/**
 *  scroll view
 */
- (void)createScrollView{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;//is paged
    _scrollView.showsHorizontalScrollIndicator = NO;
    [_mainView addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_mainView);
    }];
/**
 *  be careful the method use in somewhere
 */
    //page control
    [self createPageControl];
    //container
    [self createContainer];

}

/**
 *  container
 */
- (void)createContainer{
    _container = [[UIView alloc] init];
    _container.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_container];
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(_scrollView);
        make.height.equalTo(_scrollView);
    }];
    //there will add a new constraint in the end (mas_bottom)
    //image view
    [self createImageView];
}

#pragma mark in the end we need change there into request-->with url
/**
 *  image view
 */
- (void)createImageView{
    
#ifdef kCount
    //last image view --> for defferent sences
    UIImageView *lastImageView = nil;
    for (int i = 0; i < kCount; i ++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%d", i + 1]]];
        [_container addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(_container);
            make.width.mas_equalTo(_mainView.mas_width);
            make.left.mas_equalTo(lastImageView ? lastImageView.mas_right : _container.mas_left);
        }];
        lastImageView = imageView;
    }
    //add a new constraint (container-->mas_bottom)
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastImageView.mas_right);
    }];
    
#else
    //from url
    __block UIImageView *lastImageView = nil;
    
    for (int i = 0; i < self.array.count; i ++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [imageView sd_setImageWithURL:[NSURL URLWithString:self.array[i]]];
        });
        
        [_container addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(_container);
            make.width.mas_equalTo(_mainView.mas_width);
            make.left.mas_equalTo(lastImageView ? lastImageView.mas_right : _container.mas_left);
        }];
        lastImageView = imageView;
        if (i == self.array.count - 1) {
            [self beginTimer];
        }
    }
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastImageView.mas_right);
    }];

#endif
    
}

/**
 *  ！！！！！子线程里面不要加UI控件
 */

#pragma mark - using kcount
/**
 *  page control
 */
- (void)createPageControl{
    _pageControl = [[UIPageControl alloc] init];
#ifdef kCount
    _pageControl.numberOfPages = kCount;
#else
    _pageControl.numberOfPages = _array.count;
#endif
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [_mainView addSubview:_pageControl];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.bottom.equalTo(_mainView);
        make.height.mas_equalTo(@29);
    }];
}

/**
 *  begin timer
 */
- (void)beginTimer{
//    [self nextPage:nil];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(nextPage:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.pageControl addTarget:self action:@selector(pageControlAction:) forControlEvents:UIControlEventValueChanged];
}
    
#pragma mark - using kcount

/**
 *  next page
 *
 *  @param sender timer
 */
- (void)nextPage:(NSTimer *)sender{
    static int page = 0;
#ifdef kCount
    if (_pageControl.currentPage == kCount - 1) {
#else
    if (_pageControl.currentPage == _array.count - 1) {
#endif
        page = 0;
    }else{
        page = (int)_pageControl.currentPage + 1;
    }
    [_scrollView setContentOffset:CGPointMake(page * self.scrollView.frame.size.width, 0) animated:YES];

}

/**
 *  page control method
 *
 *  @param sender page control
 */
- (void)pageControlAction:(UIPageControl *)sender{
    if(_isClicked){
        return;
    }
    _isClicked = YES;
    _pageControl.userInteractionEnabled = NO;
    [self stopTimer];
    [UIView animateWithDuration:1.0f animations:^{
        [_scrollView setContentOffset:CGPointMake(self.mainView.frame.size.width * sender.currentPage, 0) animated:NO];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self beginTimer];
        _isClicked = NO;
        _pageControl.userInteractionEnabled = YES;
    });
}

/**
 *  stop timer
 */
- (void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

/**
 *  scroll view delegate method
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        CGFloat scollW = self.scrollView.frame.size.width;
        int page = (self.scrollView.contentOffset.x + scollW * 0.5) / scollW;
        self.pageControl.currentPage = page;
        
        static int index = 0;
        if (index != page) {
            [self deliverIndexPageWithPage:(NSInteger)page];
            index = page;
        }
    }
}

/**
 *  if we dragging then let the timer stop
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        [self stopTimer];
    }
}
 
/**
 *  if wo stop dragging the let the timer begin
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (scrollView == self.scrollView) {
        [self beginTimer];
    }
}
    
/**
 *  deliver current index of the pageControl
 */
- (void)deliverIndexPageWithPage:(NSInteger)page{
    //delegate deliver data
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerIndexPage:)]) {
        [self.delegate headerIndexPage:page];
    }
    //block deliver data
    if (_indexPageBlock) {
        _indexPageBlock(page);
    }
}

/**
 *  block method
 */
- (void)getIndexPageWithBlock:(IndexPage)block{
    if (block) {
        _indexPageBlock = [block copy];
    }
}

@end
