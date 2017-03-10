#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface XMGradientView : UIView

/**
 *  default is from bottom to top gradient if both point is CGPointZero
 */
@property (nonatomic, assign) CGPoint fromPoint;
@property (nonatomic, assign) CGPoint toPoint;

/**
 *  We provide from'UIColor to to'UIcolor  locations[0, 1]  gradient
 */
@property (nonatomic, strong) UIColor *from;
@property (nonatomic, strong) UIColor *to;

@end
