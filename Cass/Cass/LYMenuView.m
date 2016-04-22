//
//  MenuView.m
//  Cass
//
//  Created by 刘杨 on 16/3/29.
//  Copyright © 2016年 刘杨. All rights reserved.
//

#import "LYMenuView.h"

typedef NS_ENUM(NSInteger, ShowType) {
    ShowTypeInitial = -1,
    ShowTypeArrowLeftAndTop,
    ShowTypeArrowRightAndTop,
    ShowTypeArrowLeftAndBottom,
    ShowTypeArrowRightAndBottom
};

#define kMenuViewWidth  140
#define kMenuViewHeight 30
#define kMenuCellLength 20
#define kMenuCellMargin 5
#define kMenuOverFar    20
#define kDefaultMenuBackgroundColor [UIColor clearColor]

@interface LYMenuView ()<UITableViewDelegate>{
    UIColor *_menuColor;
    BOOL     _scrollEnable;
}
@property (nonatomic, assign) ShowType showType;
@property (nonatomic, weak) id<LYMenuViewDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LYMenuViewDataSource *dataSource;
@end

@implementation LYMenuView

- (BOOL)scrollEnable{
    return self.tableView.scrollEnabled;
}

- (void)setScrollEnable:(BOOL)scrollEnable{
    _scrollEnable = scrollEnable;
    self.tableView.scrollEnabled = scrollEnable;
}

- (UIColor *)menuColor{
    return (_menuColor) ? _menuColor : kDefaultMenuBackgroundColor;
}

- (void)setMenuColor:(UIColor *)menuColor{
    _menuColor = menuColor;
    self.backgroundColor = _menuColor;
}

+ (LYMenuView *)menuViewWithDelegate:(id<LYMenuViewDelegate>)delegate items:(NSArray<LYMenuViewItem *> *)items{
    return [[LYMenuView alloc] initWithDelegate:delegate items:items];
}

- (instancetype)initWithDelegate:(id<LYMenuViewDelegate>)delegate
                           items:(NSArray <LYMenuViewItem *> *)items{
    if (self = [super init]) {
        self.delegate = delegate;
        self.showType = ShowTypeInitial;
        [self initalizedWithDataSource:items];
        
        self.backgroundColor = self.menuColor;
    }
    return self;
}

- (void)initalizedWithDataSource:(NSArray <LYMenuViewItem *> *)source{
    //interface
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStylePlain];
    //datasource
    self.dataSource = [[LYMenuViewDataSource alloc] initWithItems:source tableView:self.tableView];
    
    self.tableView.rowHeight = 0;
    self.tableView.tableFooterView = 0;
    self.tableView.tableHeaderView = 0;
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.tableView.rowHeight = kMenuViewHeight;
    self.tableView.scrollEnabled = NO;
    
    [self addSubview:self.tableView];
}

- (void)show:(BOOL)animate fromView:(UIView *)fromView toView:(UIView *)toView{
    
    [self configSubViewsWithFromView:fromView toView:toView];
    
    if (animate) {
        self.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 1;
        }completion:^(BOOL finished) {
            self.hidden = NO;
        }];
    }else{
        self.alpha = 1;
        self.hidden = NO;
    }
    
}

- (void)configSubViewsWithFromView:(UIView *)fromView toView:(UIView *)toView{
    NSInteger row = [self.tableView numberOfRowsInSection:0];
    CGRect viewRect = fromView.frame;
    CGRect windowsRect = [UIScreen mainScreen].bounds;
    
    CGFloat tableOffsetX = 0;
    CGFloat selfOffsetX = 0;
    
    UICollectionView *collectionView = nil;
    if ([fromView isKindOfClass:[UICollectionViewCell class]]) {
        for (UICollectionView *collect in toView.subviews) {
            if ([collect isKindOfClass:[UICollectionView class]]) {
                collectionView = collect;
                break;
            }
        }
    }
    
    CGFloat viewRectOffsetX = (viewRect.origin.x + viewRect.size.width);
    CGFloat viewRectOffsetY = (viewRect.origin.y + viewRect.size.height);
    
    if (windowsRect.size.width - viewRectOffsetX > kMenuViewWidth) {
        
        if (collectionView) {
            //screenH + contentOffsetY = contentSize.height

            if (windowsRect.size.height - collectionView.frame.origin.y - viewRectOffsetY + collectionView.contentOffset.y > kMenuOverFar) {
                self.showType = ShowTypeArrowLeftAndTop;
            }else{
                self.showType = ShowTypeArrowLeftAndBottom;
            }
        }else{
            if (windowsRect.size.height - viewRectOffsetY > kMenuOverFar) {
                self.showType = ShowTypeArrowLeftAndTop;
            }else{

                self.showType = ShowTypeArrowLeftAndBottom;
            }
        }
        tableOffsetX = 10;
        selfOffsetX = viewRect.size.width;
        
    }else{
        
        if (collectionView) {
            //screenH + contentOffsetY = contentSize.height

            if (windowsRect.size.height - collectionView.frame.origin.y - viewRectOffsetY + collectionView.contentOffset.y > kMenuOverFar) {
                self.showType = ShowTypeArrowRightAndTop;
            }else{
                self.showType = ShowTypeArrowRightAndBottom;
            }
        }else{
            if (windowsRect.size.height - viewRectOffsetY > kMenuOverFar) {
                self.showType = ShowTypeArrowRightAndTop;
            }else{

                self.showType = ShowTypeArrowRightAndBottom;
            }
        }
        selfOffsetX = -(kMenuViewWidth + 10);
        
    }
    
    self.frame = CGRectMake(selfOffsetX,
                            0,
                            kMenuViewWidth + 10,
                            kMenuViewHeight * row);
    
    self.tableView.frame = CGRectMake(tableOffsetX,
                                      0,
                                      kMenuViewWidth,
                                      kMenuViewHeight * row);
    
    self.frame = [fromView convertRect:self.frame toView:toView];
    
    // modify frame if over screen or collectionView
    
    if (collectionView) {
        
        if (self.frame.origin.y - collectionView.frame.origin.y <= 0)
            [self modifyViewY:self withValue:collectionView.frame.origin.y + 10];
    }else{
        if (self.frame.origin.y <= 0) [self modifyViewY:self withValue:kMenuOverFar];
    }
    if (self.frame.origin.y + self.frame.size.height > windowsRect.size.height)
        [self modifyViewY:self withValue:windowsRect.size.height - (self.frame.size.height + kMenuOverFar)];

    [self setNeedsDisplay];//to call drawRect
}

- (void)modifyViewY:(UIView *)viewY withValue:(CGFloat)value{
    CGRect temp = viewY.frame;
    temp.origin.y = value;
    viewY.frame = temp;
}

- (void)drawRect:(CGRect)rect{
    
    CGPoint arrow_sharp;
    CGPoint arrow_top;
    CGPoint arrow_bottom;
    
    CGFloat sharp = 15;
    CGFloat top = 5;
    CGFloat bottom = 25;
    
    if (self.showType == ShowTypeArrowLeftAndTop) {
        arrow_sharp = CGPointMake(0, sharp);
        arrow_top = CGPointMake(sharp, top);
        arrow_bottom = CGPointMake(sharp, bottom);
    }else if (self.showType == ShowTypeArrowLeftAndBottom){
        arrow_sharp = CGPointMake(0, self.bounds.size.height - sharp);
        arrow_top = CGPointMake(sharp, self.bounds.size.height - bottom);
        arrow_bottom = CGPointMake(sharp, self.bounds.size.height - top);
    }else if (self.showType == ShowTypeArrowRightAndTop){
        arrow_sharp = CGPointMake(self.bounds.size.width, sharp);
        arrow_top = CGPointMake(self.bounds.size.width - sharp, top);
        arrow_bottom = CGPointMake(self.bounds.size.width - sharp, bottom);
    }else if (self.showType == ShowTypeArrowRightAndBottom){
        arrow_sharp = CGPointMake(self.bounds.size.width,
                                  self.bounds.size.height - sharp);
        arrow_top = CGPointMake(self.bounds.size.width - sharp,
                                self.bounds.size.height - bottom);
        arrow_bottom = CGPointMake(self.bounds.size.width - sharp,
                                   self.bounds.size.height - top);
    }
    
    //that is draw arrow
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextMoveToPoint(context, arrow_sharp.x, arrow_sharp.y);
    CGContextAddLineToPoint(context, arrow_top.x, arrow_top.y);
    CGContextAddLineToPoint(context, arrow_bottom.x, arrow_bottom.y);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillPath(context);
    
}

- (void)hide:(BOOL)animate{
    if (animate) {
        [UIView animateWithDuration:0.38 animations:^{
            self.alpha = 0;
        }completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }else{
        self.alpha = 0;
        self.hidden = YES;
    }
}

//call delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(menuView:tableView:didSelectedRowAtIndexPath:dataSource:)]) {
        [self.delegate menuView:self tableView:tableView
      didSelectedRowAtIndexPath:indexPath dataSource:self.dataSource];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end

@implementation LYMenuViewItem
@end

@implementation LYMenuViewDataSource

- (instancetype)initWithItems:(NSArray<LYMenuViewItem *> *)items tableView:(UITableView *)tableView{
    if (self = [super init]) {
        [tableView registerClass:[LYMenuCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
        self.datas = items;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LYMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class)
                                                            forIndexPath:indexPath];
    LYMenuViewItem *item = self.datas[indexPath.row];
    cell.iconView.image = (item.isSelected) ? item.selectedImage : item.image;
    cell.titleLabel.text = (item.isSelected) ? item.selectedTitle : item.title;
    return cell;
}
@end

@implementation LYMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initialized];
    }
    return self;
}

- (void)initialized{
    self.iconView = nil;
    self.titleLabel = nil;
    //avoid reuse
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.titleLabel];
}

- (void)layoutSubviews{
    
    self.iconView.frame = CGRectMake(kMenuCellMargin,
                                     (self.bounds.size.height - kMenuCellLength) * 0.5,
                                     kMenuCellLength,
                                     kMenuCellLength);
    self.titleLabel.frame = CGRectMake(kMenuCellMargin + kMenuCellLength,
                                       0,
                                       self.bounds.size.width - (kMenuCellMargin + kMenuCellLength),
                                       self.bounds.size.height);
    [super layoutSubviews];
}

- (UIImageView *)iconView{
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end