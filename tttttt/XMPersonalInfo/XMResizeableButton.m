#import "XMResizeableButton.h"

@interface XMResizeableButton () {
    CGRect (^_titleRectBlock)(CGRect contectRect, CGRect imageRect);
    CGRect (^_imageRectBlock)(CGRect contectRect);
    CGRect _imageRect;
}
@end

@implementation XMResizeableButton

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageRect = CGRectZero;
    }
    return self;
}

- (void)resizeTitleWithBlock:(CGRect (^)(CGRect contectRect, CGRect imageRect))block{
    _titleRectBlock = [block copy];
}

- (void)resizeImageWithBlock:(CGRect (^)(CGRect contectRect))block{
    _imageRectBlock = [block copy];
}

- (void)dealloc{
    _titleRectBlock = nil;
    _imageRectBlock = nil;
}

- (void)addTouchUpInSideTarget:(id)target action:(SEL)action{
    [self addTarget:target action:action
   forControlEvents:UIControlEventTouchUpInside];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return _imageRectBlock ?
    _imageRect = _imageRectBlock(contentRect) :
    [super imageRectForContentRect:contentRect];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return _titleRectBlock ?
    _titleRectBlock(contentRect, _imageRect) :
    [super titleRectForContentRect:contentRect];
}

@end
