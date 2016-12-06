//if condition is false then assert work
#define XMAssertFalse(condition, desc) NSAssert(!(condition), desc)
#define kLoopTime 3.0f

#import "XMCirleView.h"

@interface XMCirleView() <UIScrollViewDelegate, XMCirleImageViewDelegate>{
    NSTimeInterval _looptime;
    BOOL           _layoutImageView;
}
//图片缓存
@property (nonatomic, strong) NSCache *webImageCache;
//下载图片队列
@property (nonatomic, strong) NSOperationQueue *downloadQueue;
//下载会话
@property (nonatomic, strong) NSURLSession *downloadSession;
//当前图片源索引
@property (nonatomic, assign) NSInteger index;
//滑动视图
@property (nonatomic, strong) UIScrollView *scrollView;
//小点点
@property (nonatomic, strong) UIPageControl *pageContorl;
//文字按钮
@property (nonatomic, strong) UIButton *textBtn;
//计时器
@property (nonatomic, strong) NSTimer *timer;
//用于记录imageViews的数组
@property (nonatomic, strong) NSMutableArray *imageViews;

//redefine readonly properties

//delegate if you want to call method  'cirleView:clickedAtIndex:'
@property (nonatomic, weak, readwrite)   id<XMCirleViewDelegate> delegate;
//placeholder
@property (nonatomic, strong, readwrite) UIImage *placeholder;
//loop time
@property (nonatomic, assign, readwrite) NSTimeInterval looptime;
@end

NSString *const XMCirleViewCache = @"XMCirleViewCache";

@implementation XMCirleView

+ (void)initialize{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask,
                                                              YES).lastObject;
    cachePath = [cachePath stringByAppendingPathComponent:XMCirleViewCache];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cachePath]) {
        [fileManager createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    NSLog(@"cache path : %@", cachePath);
}

- (void)dealloc{
    [self invalidSession];
    [self invalidTimer];
    _scrollView = nil;
    _pageContorl = nil;
    _imageViews = nil;
    _images = nil;
    _placeholder = nil;
    _delegate = nil;
    _downloadQueue = nil;
    _downloadSession = nil;
    _webImageCache = nil;
}

+ (XMCirleView *)cirleViewWithImages:(NSArray *)images placeholder:(UIImage *)placeholder
                            interval:(NSTimeInterval)interval delegate:(id<XMCirleViewDelegate>)delegate{
    XMCirleView *view = [[XMCirleView alloc] init];
    view.looptime = interval;
    view.placeholder = placeholder;
    view.images = images;
    view.delegate = delegate;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setContainerSubViews];
    }
    return self;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setContainerSubViews];
    }
    return self;
}

- (void)setContainerSubViews{
    [self addSubview:self.scrollView];
    [self addSubview:self.textBtn];
    [self addSubview:self.pageContorl];
}

#pragma mark - 重写setter

- (void)setImages:(NSArray *)images{
    
    _images = images;
    self.pageContorl.hidden = (1 >= images.count);
    self.pageContorl.numberOfPages = images.count;
    
    XMAssertFalse(images.count < 1, @"XMCirleView 'setImages:' images的数量必须大于或者等于1");
    
    if ([images.firstObject isKindOfClass:[UIImage class]]) {
        if (1 == images.count) {
            XMCirleImageView *imageView = [self imageViewWithIndex:0];
            imageView.image = images.firstObject;
        }
        
        if (1 < images.count) {
            
            XMCirleImageView *imageView = [self imageViewWithIndex:1];
            imageView.image = images.firstObject;
            
            XMCirleImageView *nextImageView = [self imageViewWithIndex:2];
            nextImageView.image = images[[self modfiyImagesIndex:1]];
            
            XMCirleImageView *preImageView = [self imageViewWithIndex:0];
            preImageView.image = images[[self modfiyImagesIndex:images.count - 1]];
            
        }
        
    }else if ([images.firstObject isKindOfClass:[NSString class]]){
        
        [self clearNousePicture];
        [self clearMemoryCache];
        
        if (1 == images.count) {
            XMCirleImageView *imageView = [self imageViewWithIndex:0];
            imageView.image = [self imageWithContentOfURL:
                               [NSURL URLWithString:images.firstObject]
                                               completion:nil];
        }
        
        if (1 < images.count) {

            XMCirleImageView *imageView = [self imageViewWithIndex:1];
            imageView.image = [self imageWithContentOfURL:
                               [NSURL URLWithString:images.firstObject]
                                               completion:nil];
            
            XMCirleImageView *nextImageView = [self imageViewWithIndex:2];
            nextImageView.image = [self imageWithContentOfURL:
                                   [NSURL URLWithString:images[[self modfiyImagesIndex:1]]]
                                                   completion:nil];
            
            XMCirleImageView *preImageView = [self imageViewWithIndex:0];
            preImageView.image = [self imageWithContentOfURL:
                                  [NSURL URLWithString:images[[self modfiyImagesIndex:images.count - 1]]]
                                                  completion:nil];
            
        }
        
        [self layoutSubviews];
    }else{
        XMAssertFalse(0, @"XMCirleView 'setImages:' 数组必须为 <UIImage *> 或者 <NSString *>");
    }
    
    [self beginTimer];
}

- (void)setTitles:(NSArray *)titles{
    _titles = titles;
    NSInteger count = titles.count;
    XMAssertFalse(!(count == _images.count), @"XMCirleView 'setTitles:' 数组个数必须同images一样");
    _textBtn.hidden = !count;
    
    NSInteger selectIndex = [self modfiyImagesIndex:_index];
    [self setCurrentTitle:_titles[selectIndex]];
}

- (void)setCurrentTitle:(NSString *)title{
    [_textBtn setTitle:title forState:UIControlStateNormal];
}

#pragma mark - 清空缓存

+ (void)clearDiskCache{
    //再查找disk缓存, if 有则清空
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                  NSUserDomainMask,
                                                                  YES).lastObject;
        cachePath = [cachePath stringByAppendingPathComponent:XMCirleViewCache];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cachePath]) {
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
            for (NSString *subPath in contents) {
                NSString *removePath = [cachePath stringByAppendingPathComponent:subPath];
                if ([fileManager fileExistsAtPath:removePath]) {
                    [fileManager removeItemAtPath:removePath error:NULL];
                }
            }
        }
    });
}

//判断是否所传数组中包含此图片
- (BOOL)haveThisPicture:(NSString *)picture{
    
    for (NSString *url in self.images) {
        if ([url rangeOfString:picture].location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

//后台清除无用的disk缓存图片
- (void)clearNousePicture{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                  NSUserDomainMask,
                                                                  YES).lastObject;
        cachePath = [cachePath stringByAppendingPathComponent:XMCirleViewCache];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cachePath]) {
            NSArray *contents = [fileManager contentsOfDirectoryAtPath:cachePath error:NULL];
            for (NSString *subPath in contents) {
                if (![self haveThisPicture:[subPath componentsSeparatedByString:@"."].firstObject]) {
                    NSString *removePath = [cachePath stringByAppendingPathComponent:subPath];
                    if ([fileManager fileExistsAtPath:removePath]) {
                        [fileManager removeItemAtPath:removePath error:NULL];
                    }
                }
            }
        }

    });
}

#pragma mark - 下载图片

- (UIImage *)imageWithContentOfURL:(NSURL *)url completion:(void(^)(NSString *path, UIImage *image))completion{
    
    NSString *filename = url.lastPathComponent;
    filename = [filename componentsSeparatedByString:@"."].firstObject;
    filename = [filename stringByAppendingString:@".png"];
    
    
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                              NSUserDomainMask,
                                                              YES).lastObject;
    cachePath = [cachePath stringByAppendingPathComponent:XMCirleViewCache];
    cachePath = [cachePath stringByAppendingPathComponent:filename];
    
    //优先查找memory缓存
    if ([self.webImageCache objectForKey:cachePath]) {
        return [self.webImageCache objectForKey:cachePath];
    }

    //查找disk缓存
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cachePath]) {
        UIImage *diskCacheImage = [UIImage imageWithContentsOfFile:cachePath];
        //缓存进memory
        if (diskCacheImage) [self.webImageCache setObject:diskCacheImage forKey:cachePath];
        return diskCacheImage;
    }
    
    //if 没有, 则去下载
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    NSURLSessionDataTask *dataTask = [self.downloadSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSUInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (200 == statusCode && data) {
            //保存图片
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                image = [XMCirleView resizeImageWithSize:self.bounds.size image:image];
                NSData *pngData = UIImagePNGRepresentation(image);
                [pngData writeToFile:cachePath atomically:NO];
                if (completion) completion(cachePath, image);
            });
        }else{
            NSLog(@"<XMCirleView>: download error : %@ statusCode : %lu",
                  error.localizedDescription, statusCode);
        }
        
    }];
    [dataTask resume];
    
    return _placeholder;
}

#pragma mark - 简单的图片压缩技术
+ (UIImage *)resizeImageWithSize:(CGSize)size image:(UIImage *)image{
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    [image drawInRect:(CGRect){{0, 0}, size}];
    UIImage *retVal = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return retVal;
}

#pragma mark - 视图布局

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!_layoutImageView) {
        for (XMCirleImageView *imageView in self.imageViews) {
            imageView.frame = (CGRect){self.frame.size.width * imageView.index, 0,
                self.frame.size.width, self.frame.size.height};
        }
                
        self.scrollView.frame = self.bounds;
        self.textBtn.frame = (CGRect){0, self.frame.size.height - 30, self.frame.size.width, 30};
        self.pageContorl.frame = (CGRect){0, self.frame.size.height - 10, self.frame.size.width, 0};
        
        _layoutImageView = YES;
    }
    
    if (1 < self.images.count){
        self.scrollView.contentSize = (CGSize){self.frame.size.width * 3, 0};
        [self.scrollView setContentOffset:(CGPoint){self.frame.size.width, 0} animated:NO];
    }else{
        self.scrollView.contentSize = CGSizeZero;
    }
    
}

#pragma mark - 计时器方法

- (void)beginTimer{
    
    [self invalidTimer];
    
    if (self.images.count > 1) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.looptime
                                                      target:self selector:@selector(timerAction:)
                                                    userInfo:nil repeats:YES];
    }
}

- (void)invalidTimer{
    
    [self.timer invalidate];
    self.timer = nil;
}

- (void)invalidSession{
    
    [self.downloadSession invalidateAndCancel];
    [self.downloadSession finishTasksAndInvalidate];
    //同时清空内存缓存
    [self clearMemoryCache];
}

- (void)clearMemoryCache{
    [self.webImageCache removeAllObjects];
}

- (void)timerAction:(id)sender{
    
    [self.scrollView setContentOffset:(CGPoint){self.scrollView.frame.size.width * 2, 0} animated:YES];
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (decelerate && 1 < self.images.count) [self beginTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if (1 < self.images.count) [self invalidTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    [self scrollViewMoving:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self scrollViewMoving:scrollView];
}

#pragma mark - 滑动后需要修正的图片

- (void)scrollViewMoving:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x / scrollView.frame.size.width + 0.5;
    [self scrollEndAndModifyPage:page];
    
    _index = [self modfiyImagesIndex:_index];
    
    self.pageContorl.currentPage = _index;
    
    
    if (self.titles.count) [self setCurrentTitle:self.titles[_index]];
    
    XMCirleImageView *imageView = [self imageViewWithIndex:1];
    
    imageView.image = [self.images[_index] isKindOfClass:[UIImage class]] ?
    
                      self.images[_index] :
    
                      [self imageWithContentOfURL: [NSURL URLWithString:self.images[_index]] completion:nil];
    
    if (1 < self.images.count) {
        
        NSInteger next = [self modfiyImagesIndex:_index + 1];
        XMCirleImageView *nextImageView = [self imageViewWithIndex:2];
        nextImageView.image = [self.images[next] isKindOfClass:[UIImage class]] ?
        
                              self.images[next] :
        
                              [self imageWithContentOfURL: [NSURL URLWithString:self.images[next]] completion:nil];
        
        NSInteger previous = [self modfiyImagesIndex:_index - 1];
        XMCirleImageView *preImageView = [self imageViewWithIndex:0];
        preImageView.image = [self.images[previous] isKindOfClass:[UIImage class]] ?
        
                             self.images[previous] :
        
                            [self imageWithContentOfURL:[NSURL URLWithString:self.images[previous]] completion:nil];
    }
    
    
    [self layoutSubviews];
}

#pragma mark - 索引相关
#pragma mark 修正索引

- (NSInteger)modfiyImagesIndex:(NSInteger)index{
    
    if (0 > index) {
        index = self.images.count - 1;
    }else if (self.images.count < index + 1){
        index = 0;
    }
    return index;
}

#pragma mark 改变页码

- (void)scrollEndAndModifyPage:(NSInteger)page{
    
    if (!page) {
        _index --;
    }else if (2 == page){
        _index ++;
    }
}

#pragma mark 根据索引取得控件

- (XMCirleImageView *)imageViewWithIndex:(NSInteger)index{
    
    for (XMCirleImageView *imageView in self.imageViews)
        if (imageView.index == index) return imageView;
    return nil;
}

#pragma mark - XMCirleImageView delegate

- (void)cirleImageView:(XMCirleImageView *)view clickedAtIndex:(NSInteger)index{
    
    NSInteger selectIndex = _index;
    if (!index) {
        selectIndex = [self modfiyImagesIndex:selectIndex];
    } else if (2 == index){
        selectIndex = [self modfiyImagesIndex:selectIndex];
    }
    if ([self.delegate respondsToSelector:@selector(cirleView:clickedAtIndex:)]) {
        [self.delegate cirleView:self clickedAtIndex:selectIndex];
    }
}

- (void)textBtnAction:(id)sender{
    NSInteger selectIndex = [self modfiyImagesIndex:_index];
    if ([self.delegate respondsToSelector:@selector(cirleView:clickedTitleAtIndex:)]) {
        [self.delegate cirleView:self clickedTitleAtIndex:selectIndex];
    }
}

#pragma mark - 懒加载控件

- (NSTimeInterval)looptime{
    
    return _looptime ?: kLoopTime;
}

- (UIScrollView *)scrollView{
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        
        for (int i = 0; i < 3; i++) {
            XMCirleImageView *imageView = [XMCirleImageView new];
            imageView.index = i;
            imageView.delegate = self;
            [_scrollView addSubview:imageView];
            [self.imageViews addObject:imageView];
        }
    }
    return _scrollView;
}

- (NSMutableArray *)imageViews{
    
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (UIButton *)textBtn{
    if (!_textBtn) {
        _textBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _textBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        [_textBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_textBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_textBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f] forState:UIControlStateHighlighted];
        [_textBtn addTarget:self action:@selector(textBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _textBtn.hidden = YES;
    }
    return _textBtn;
}

- (UIPageControl *)pageContorl{
    
    if (!_pageContorl) {
        _pageContorl = [[UIPageControl alloc] init];
        _pageContorl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageContorl.currentPageIndicatorTintColor = [UIColor cyanColor];
        _pageContorl.userInteractionEnabled = NO;
    }
    return _pageContorl;
}

- (NSURLSession *)downloadSession{
    
    if (!_downloadSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration
                                                         delegate:nil
                                                    delegateQueue:self.downloadQueue];
    }
    return _downloadSession;
}

- (NSOperationQueue *)downloadQueue{
    
    if (!_downloadQueue) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
    }
    return _downloadQueue;
}

- (NSCache *)webImageCache{
    
    if (!_webImageCache) {
        _webImageCache = [[NSCache alloc] init];
        _webImageCache.countLimit = 10;
    }
    return _webImageCache;
}
@end

#pragma mark - CLASS 附带点击反馈功能的图片

@implementation XMCirleImageView

- (instancetype)init{
    
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if ([self.delegate respondsToSelector:@selector(cirleImageView:clickedAtIndex:)]) {
        [self.delegate cirleImageView:self clickedAtIndex:self.index];
    }
}
@end

