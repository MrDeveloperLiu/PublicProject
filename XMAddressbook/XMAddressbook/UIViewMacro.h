//
// UIViewMacro.h
// 功能: 简化代码量的实用辅助工具
// 作者: 刘杨
// 时间: 2016-12-01 16:53:20
//

#ifndef UIViewMacro_h
#define UIViewMacro_h


#define FColor(x) (x) / 255.0
#define UIColorFromRGB(r, g, b) [UIColor colorWithRed:FColor(r) green:FColor(g) blue:FColor(b) alpha:1]
#define UIColorFromHex(a) [UIColor colorWithRed:FColor((a & 0xFFFF00) >> 16)\
                                          green:FColor((a & 0xFF00) >> 8)\
                                           blue:FColor((a & 0xFF)) alpha:1]\
/**
 property

 @param cls 'class of object'
 @param name 'object name'
 */
#define UIViewPropertyStrong(cls, name)     @property (nonatomic, strong) cls *name;
#define UIViewPropertyWeak(cls, name)       @property (nonatomic, weak) cls *name;

#define NSObjectPropertyStrong(cls, name)   UIViewPropertyStrong(cls, name)
#define NSObjectPropertyWeak(cls, name)     UIViewPropertyWeak(cls, name)
#define NSObjectPropertyCopy(cls, name)     @property (nonatomic, copy) cls *name;


/**
 property setter

 @param block 'you want to set something for your element'
 @see  'UIViewPropertyLazyload(UIView, aView, NSObjectPropertySetter(^(  //...todo  )))'
 */
static inline dispatch_block_t NSObjectPropertySetter(dispatch_block_t block){ return block; }


/**
 property setter none
 */
static inline dispatch_block_t NSObjectPropertySetterNone(){ return nil; }

/**
 lazyload of UIView

 @param cls 'class'
 @param sel 'getter'
 @param name 'object member'
 @param block 'some config'
 */
#define UIViewPropertyLazyload(cls, sel, name, block)\
- (cls *)sel{\
if (!name) {\
name = [cls new];\
if(block) block();\
}\
return name;\
}\

#define NSObjectPropertyLazyload(cls, sel, name, block)  UIViewPropertyLazyload(cls, sel, name, block)

/**
 lazyload of UIView Not intailiazed
 
 @param cls 'class'
 @param sel 'getter'
 @param name 'object member'
 @param block 'some config'
 */
#define UIViewPropertyLazyloadAllocWithZone(cls, sel, name, block)\
- (cls *)sel{\
if (!name) {\
if(block) block();\
}\
return name;\
}\

#define NSObjectPropertyLazyloadAllocWithZone(cls, sel, name, block)  \
UIViewPropertyLazyloadAllocWithZone(cls, sel, name, block)


/**
 lazyload of UIButton
 
 @param cls 'class'
 @param sel 'getter'
 @param name 'object member'
 @param block 'some config'
 */
#define UIButtonPropertyLazyload(cls, sel, name, type, block)\
- (cls *)sel{\
if (!name) {\
name = [cls buttonWithType:type];\
if(block) block();\
}\
return name;\
}\

/**
 some CoreGraphics define's of UIView
 
 @param view 'view'
 */
#define VMaxX(view)                 CGRectGetMaxX(view.frame)
#define VMaxY(view)                 CGRectGetMaxY(view.frame)
#define VMinX(view)                 CGRectGetMinX(view.frame)
#define VMinY(view)                 CGRectGetMinY(view.frame)
#define VWidth(view)                CGRectGetWidth(view.frame)
#define VHeight(view)               CGRectGetHeight(view.frame)
#define VRect(x, y, w, h)           CGRectMake(x, y, w, h)
#define VSize(w, h)                 CGSizeMake(w, h)
#define VPoint(x, y)                CGPointMake(x, y)

#define USSize                      [[UIScreen mainScreen] bounds].size
#define USSizeW                     [[UIScreen mainScreen] bounds].size.width
#define USSizeH                     [[UIScreen mainScreen] bounds].size.height

/**
 a center rect of 'frame' and 'size'
 
 @param frame 'superview's frame'
 @param size 'size of it'
 */
#define VCenterRect(frame, size)    CenterRectMake(frame, size)
static inline CGRect CenterRectMake(CGRect frame, CGSize size){
    return VRect((frame.size.width - size.width) * 0.5 + frame.origin.x,
                 (frame.size.height - size.height) * 0.5 + frame.origin.y,
                 size.width, size.height);
}


#endif /* UIViewMacro_h */
