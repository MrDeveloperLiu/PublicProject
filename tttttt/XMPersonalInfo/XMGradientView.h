#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

struct Color {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};
typedef struct Color XMColor;

static inline XMColor XMColorMake(CGFloat r, CGFloat g, CGFloat b, CGFloat a){
    XMColor retVal; retVal.red = r / 255.0; retVal.green = g / 255.0; retVal.blue = b / 255.0; retVal.alpha = a;
    return retVal;
}

@interface XMGradientView : UIView

@property (nonatomic, assign) CGPoint fromPoint;
@property (nonatomic, assign) CGPoint toPoint;

@property (nonatomic, assign) XMColor from;
@property (nonatomic, assign) XMColor to;

@end
