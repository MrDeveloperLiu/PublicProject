//
//  QuartzView.m
//  CoreGraphics
//
//  Created by 刘杨 on 16/2/4.
//  Copyright © 2016年 刘杨. All rights reserved.
//

#import "QuartzView.h"

//一.使用CoreGraphics绘制一个方形

void drawView(void *info, CGContextRef context){
    
    CGContextSetRGBFillColor(context, 0.5, 1, 0.9, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 50, 50));
}

/**
 *  设置着色模式的颜色空间
 */
/*
//create a pattern
CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
//set fill color
CGContextSetFillColorSpace(context, patternSpace);
//release space
CGColorSpaceRelease(patternSpace);
*/

/**
 *  设置着色模式的骨架
 */
/*
static const CGPatternCallbacks callback = {0, &drawView, NULL};
CGPatternRef pattern = CGPatternCreate(NULL,
                                       CGRectMake(0, 100, 100, 100),
                                       CGAffineTransformIdentity,
                                       10,
                                       10,
                                       kCGPatternTilingNoDistortion,
                                       true,
                                       &callback);
CGFloat aphla = 1.0f;
CGContextSetFillPattern(context, pattern, &aphla);
CGPatternRelease(pattern);
*/

/*
 运算原理：原坐标设为（X,Y,1）;
                |a    b    0|
 [X，Y, 1]      |c    d    0|     =     [aX + cY + tx   bX + dY + ty  1] ;
                |tx    ty  1|
 
 1弧度=180/π度
 1度=π/180弧度
 */

//二.使用模式空间绘制

void colorPatternPainting(CGContextRef context, CGRect rect){
    CGPatternRef pattern;
    CGColorSpaceRef baseSpace;
    CGColorSpaceRef space;
    //颜色不以这个为控制
    static const CGFloat color[4] = {1, 0, 0, 1};
    //回调函数(结构体指针)
    static const CGPatternCallbacks callback = {0, &drawView, NULL};
    //保存当前的转换矩阵
    CGContextSaveGState(context);
    //基础设备的RGB颜色空间
    baseSpace = CGColorSpaceCreateDeviceRGB();
    //初始化颜色空间
    space = CGColorSpaceCreatePattern(baseSpace);
    CGColorSpaceRelease(baseSpace);
    //设置填充的颜色空间
    CGContextSetFillColorSpace(context, space);
    CGColorSpaceRelease(space);
    //创建绘制模式
    pattern = CGPatternCreate(NULL,
                              CGRectMake(0, 0, 1, 1),
                              CGAffineTransformIdentity,
                              1,
                              1,
                              kCGPatternTilingConstantSpacing,
                              false,
                              &callback);
    //填充模式
    CGContextSetFillPattern(context, pattern, color);
    CGPatternRelease(pattern);
    //填充rect
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
}

static void drawStar(void *info, CGContextRef context){
    double r, theta;
    
    r = 0.8 * 16 / 2;
    
    theta = 2 * M_PI * (2.0 / 5.0);
    CGContextTranslateCTM(context, 16/2, 16/2);
    
    CGContextMoveToPoint(context, 0, r);
    
    for (int k = 1; k < 5; k ++) {
        CGContextAddLineToPoint(context,
                                r * sin(k * theta),
                                r * cos(k * theta));
    }
    
    CGContextClosePath(context);
    CGContextFillPath(context);
}

//画星星
void drawStarsView(CGContextRef context,CGRect frame){
    CGPatternRef pattern;
    CGColorSpaceRef baseSpace;
    CGColorSpaceRef patternSpace;
    
    static const CGFloat color[4] = {1, 0, 0, 1};
    static const CGPatternCallbacks callback = {0, &drawStar, NULL};
    
    baseSpace = CGColorSpaceCreateDeviceRGB();
    patternSpace = CGColorSpaceCreatePattern(baseSpace);
    
    CGContextSetFillColorSpace(context, patternSpace);

    CGColorSpaceRelease(baseSpace);
    CGColorSpaceRelease(patternSpace);
    
    pattern = CGPatternCreate(NULL,
                              CGRectMake(0, 0, 16, 16),
                              CGAffineTransformIdentity,
                              16,
                              16,
                              kCGPatternTilingConstantSpacing,
                              false,
                              &callback);
    
    CGContextSetFillPattern(context, pattern, color);
    CGPatternRelease(pattern);
    
    CGContextFillRect(context, frame);
}

//三.绘制阴影

void drawShadow(CGContextRef context, float tx, float ty){
    CGSize shadowSize = CGSizeMake(-15, 20);
    CGFloat color[] = {0, 0, 0, 0.6};
    
    CGColorRef colorRef;
    CGColorSpaceRef colorSpaceRef;
    
    //保存图形状态
    CGContextSaveGState(context);
    //设置阴影(模糊值5)
    CGContextSetShadow(context, shadowSize, 5);
    
    //drawing
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(tx / 3 + 75, ty / 2, tx / 4, ty / 4));
    //颜色
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    colorRef = CGColorCreate(colorSpaceRef, color);
    CGContextSetShadowWithColor(context, shadowSize, 5, colorRef);
    //drawing
    CGContextSetRGBFillColor(context, 0, 0, 1, 1);
    CGContextFillRect(context, CGRectMake(tx / 3 - 75, ty / 2 - 100, tx / 4, ty / 4));
    
    CGColorRelease(colorRef);
    CGColorSpaceRelease(colorSpaceRef);
    //重新储存状态
    CGContextRestoreGState(context);
}

//四.绘制渐变
/**
 CGShading / CGGradient
 
 
 使用CGShadingRef前,必须创建一个CGFunctionRef对象
 当创建一个CGShading对象时，我们指定其是轴向还是径向。除了计算函数外，我们还需要提供一个颜色空间、起始点和结束点或者是半径，这取决于是绘制轴向还是径向渐变。在绘制时，我们只是简单地传递CGShading对象及绘制上下文给CGContextDrawShading函数。Quartz为渐变上的每个点调用渐变计算函数。
 
 一个CGGradient对象是CGShading对象的子集
 */


void drawShading(CGContextRef context){
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t num_locations = 2;
    
    CGFloat locations[2] = {0, 1.0};
    CGFloat compents[8] = {0.95, 0.3, 0.4, 1.0,
                           0.95, 0.3, 0.4, 0.1};
    
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

    //创建CGGradientRef对象需要参数 1.颜色空间 2.颜色对象 3.终止位置 4.颜色数量
    gradient = CGGradientCreateWithColorComponents(colorSpace, compents, locations, num_locations);
    
    CGColorSpaceRelease(colorSpace);
    
    CGPoint start, end;
    CGFloat startRadius, endRadius;
    start.x = 0;
    start.y = 0;
    end.x = 1.0;
    end.y = 1.0;
    
    
    startRadius = 0.1;
    endRadius = 0.25;
    
    //线性的渐变
//    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    //放射性的渐变
    CGContextDrawRadialGradient(context, gradient, start, startRadius, end, endRadius, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(gradient);
}

/**
 步骤
 */

//1.回调计算颜色
void calculateShadingValues(void *info, const CGFloat *init, CGFloat *outit){
    CGFloat value;
    size_t k, components;
    static const CGFloat color[] = {1, 0, 0.5, 0};
    
    components = (size_t)info;
    
    value = *init;
    for (k = 0; k < components - 1; k ++) {
        *outit++ = color[k] * value;
    }
    *outit++ = 1;
}

//2.回调的function对象
static CGFunctionRef getFunction(CGColorSpaceRef colorSpace){

    size_t components;
    static const CGFloat input_value_range[2] = {0, 1};
    static const CGFloat output_value_range[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    static const CGFunctionCallbacks callback = {0, &calculateShadingValues, NULL};
    
    components = 1 + CGColorSpaceGetNumberOfComponents(colorSpace);
    
    return CGFunctionCreate((void *)components,
                            1,
                            input_value_range,
                            components,
                            output_value_range,
                            &callback);
}

//4.剪裁上下文

CGFloat radius(CGFloat r){
    return (M_PI/180) * r;
}

void clipContext(CGContextRef context){
    CGContextBeginPath(context);
    CGContextAddArc(context, 0.5, 0.5, 0.3, 0, radius(180), 0);
    CGContextClosePath(context);
    CGContextClip(context);
}

//3.创建一个轴向渐变的CGShading对象
void drawShadingAxial(CGContextRef context){

    CGColorSpaceRef colorSpace;
    CGPoint start, end;
    CGFunctionRef function;
    CGShadingRef shading;
    
    start = CGPointMake(0, 0.5);
    end = CGPointMake(1, 0.5);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    function = getFunction(colorSpace);
    
    
    shading = CGShadingCreateAxial(colorSpace, start, end, function, false, false);
    
    CGFunctionRelease(function);//release
    
    CGColorSpaceRelease(colorSpace);
    
    //剪裁
    clipContext(context);
    //绘制
    CGContextDrawShading(context, shading);
    
    CGShadingRelease(shading);
}

//完整的示例

void paintAxialShading(CGContextRef context, CGRect bounds){

    CGPoint start, end;
    CGAffineTransform transform;
    CGColorSpaceRef colorSpace;
    CGFunctionRef function;
    CGShadingRef shading;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    start = CGPointMake(0, 0.5);
    end = CGPointMake(1, 0.5);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    function = getFunction(colorSpace);
    shading = CGShadingCreateAxial(colorSpace, start, end, function, false, false);
    
    transform = CGAffineTransformMakeScale(width, height);
    CGContextConcatCTM(context, transform);
    CGContextSaveGState(context);
    
    CGContextClipToRect(context, CGRectMake(0, 0, 1, 1));
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    
    CGContextBeginPath(context);
    CGContextAddArc(context, 0.5, 0.5, 0.3, 0, radius(180), 0);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawShading(context, shading);
    
    CGColorSpaceRelease(colorSpace);
    CGFunctionRelease(function);
    CGShadingRelease(shading);
    
    CGContextRestoreGState(context);
}

/**
 径向渐变
 */
//他是一个回调函数, info指针说明了颜色组件的个数, 每个函数获取一个输入值并计算N个值，即颜色空间的每个颜色组件加一个alpha值
void calculateValues(void *info, const CGFloat *init, CGFloat *outit){
    size_t k, components;
    double frequency[4] = {55, 200, 110, 0};
    components = (size_t)info;
    for (k = 0; k < components - 1; k ++) {
        *outit++ = (1 + sin(*init * frequency[k]));
    }
    *outit++ = 1;//alpha
}

static CGFunctionRef getRadialFunction(CGContextRef context, CGColorSpaceRef colorSpace){
    
    size_t components;
    static const CGFloat input_value_range[2] = {0, 1};
    static const CGFloat output_value_range[8] = {0, 1, 0, 1, 0, 1, 0, 1};
    static const CGFunctionCallbacks callback = {0, &calculateValues, NULL};
    
    components = 1 + CGColorSpaceGetNumberOfComponents(colorSpace);
    
    return CGFunctionCreate((void *)components,
                            1,
                            input_value_range,
                            components,
                            output_value_range,
                            &callback);
}

void paintRadialShading(CGContextRef context, CGRect bounds){
    
    CGPoint start, end;
    CGFloat startRadius, endRadius;
    CGColorSpaceRef colorSpace;
    CGFunctionRef function;
    CGShadingRef shading;
    CGAffineTransform transform;
    CGFloat width = bounds.size.width;
    CGFloat height = bounds.size.height;
    
    start = CGPointMake(0.25, 0.3);
    end = CGPointMake(0.7, 0.7);
    startRadius = 0.1;
    endRadius = 0.25;

    colorSpace = CGColorSpaceCreateDeviceRGB();
    function = getRadialFunction(context, colorSpace);
    shading = CGShadingCreateRadial(colorSpace, start, startRadius, end, endRadius, function, false, false);
    
    transform = CGAffineTransformMakeScale(width, height);
    CGContextConcatCTM(context, transform);
    CGContextSaveGState(context);
    
    CGContextClipToRect(context, CGRectMake(0, 0, 1, 1));
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    
    CGContextDrawShading(context, shading);
    
    CGColorSpaceRelease(colorSpace);
    CGFunctionRelease(function);
    CGShadingRelease(shading);
    
    CGContextRestoreGState(context);
}

//五.透明层
/**
 步骤
 1.调用函数CGContextBeginTransparencyLayer
 2.在透明层中绘制需要组合的对象
 3.调用函数CGContextEndTransparencyLayer
 */
void drawTransparecyLayer(CGContextRef context, float width, float height){

    CGSize shadowOffset = CGSizeMake(-10, 20);
    CGContextSetShadow(context, shadowOffset, 10);
    
    CGContextBeginTransparencyLayer(context, NULL);
    
    //drawing
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextFillRect(context, CGRectMake(width / 3 + 50, height / 2, width / 4, height / 4));
    CGContextSetRGBFillColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(width / 3 - 50, height / 2 - 40, width / 4, height / 4));
    CGContextSetRGBFillColor(context, 0, 0, 1, 1);
    CGContextFillRect(context, CGRectMake(width / 3, height / 2 - 20, width / 4, height / 4));

    CGContextEndTransparencyLayer(context);
}

//六.位图
void drawImage(CGContextRef context){
    
    
    UIImage *img = [UIImage imageNamed:@"1.png"];
    CGImageRef source = img.CGImage;
    
    CGContextSaveGState(context);
    
    //旋转当前转化矩阵
    CGContextRotateCTM(context, M_PI);
    //翻转当前转化矩阵
    CGContextTranslateCTM(context, -img.size.width, -img.size.height);
    
    CGContextDrawImage(context, CGRectMake(-50, -100, img.size.width, img.size.height), source);
    
    CGContextRestoreGState(context);


    /*
    [img drawInRect:CGRectMake(50, 100, 200, 200)];
    
    NSString *text = @"这个一个图片啊";
    
    [text drawInRect:CGRectMake(50, 310, 200, 30) withAttributes:@{
                                                                   NSFontAttributeName : [UIFont systemFontOfSize:15.0f],
                                                                   NSForegroundColorAttributeName : [UIColor redColor],
                                                                   }];
     */
    
}

//graphics层绘制
void drawFlag(CGContextRef context, CGRect *rect){

    int i, j,
        num_six_star_rows = 5,
        num_five_star_rows = 4;
    
    CGFloat start_x = 5.0,
            start_y = 108.0,
            red_stripe_spacing = 34.0,
            h_spacing = 26.0,
            v_spacing = 22.0;
 
    CGContextRef layer_context_one,
                 layer_context_two;
    
    CGLayerRef stripe_layer,
               star_layer;
    
    CGRect bounding_box,
           stripe_rect,
           star_rect;
    
    CGPoint point_1 = {5, 5},
            point_2 = {10, 15},
            point_3 = {10, 15},
            point_4 = {15, 5},
            point_5 = {15, 5},
            point_6 = {2.5, 11},
            point_7 = {2.5, 11},
            point_8 = {16.5, 11},
            point_9 = {16.5, 11},
            point_10 = {5, 5};
    
    const CGPoint star_point[] = {point_1, point_2,
                                point_3, point_4,
                                point_5, point_6,
                                point_7, point_8,
                                point_9, point_10};
    
    stripe_rect = CGRectMake(0, 0, 400, 17);
    star_rect = CGRectMake(0, 102, 160, 119);
    
    bounding_box = CGRectMake(0, 0, rect->size.width, rect->size.height);
    
    //create layer and draw them
    stripe_layer = CGLayerCreateWithContext(context, stripe_rect.size, NULL);
    layer_context_one = CGLayerGetContext(stripe_layer);
    
    CGContextSetRGBFillColor(layer_context_one, 1.0, 0, 0, 1.0);
    CGContextFillRect(layer_context_one, stripe_rect);
    
    star_layer = CGLayerCreateWithContext(context, star_rect.size, NULL);
    layer_context_two = CGLayerGetContext(star_layer);
    
    CGContextSetRGBFillColor(layer_context_two, 1.0, 1.0, 1.0, 1.0);
    CGContextAddLines(layer_context_two, star_point, 10);
    CGContextFillPath(layer_context_two);
    
    //drawing to the window grahics context
    CGContextSaveGState(context);
    
    for (i = 0; i < 7; i ++) {
        CGContextDrawLayerAtPoint(context, CGPointZero, stripe_layer);
        CGContextTranslateCTM(context, 0, red_stripe_spacing);
    }
    CGContextRestoreGState(context);
    
    CGContextSetRGBFillColor(context, 0, 0, 0.329, 1.0);
    CGContextFillRect(context, star_rect);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, start_x, start_y);
    for (j = 0; j < num_six_star_rows; j ++) {
        for (i = 0; i < 6; i ++) {
            CGContextDrawLayerAtPoint(context, CGPointZero, star_layer);
            CGContextTranslateCTM(context, h_spacing, 0);
        }
        CGContextTranslateCTM(context, (-i * h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, start_x + h_spacing / 2, start_y + h_spacing / 2);
    
    for (j = 0; j < num_five_star_rows; j ++) {
        for (i = 0; i < 5; i ++) {
            CGContextDrawLayerAtPoint(context, CGPointZero, star_layer);
            CGContextTranslateCTM(context, h_spacing, 0);
        }
        CGContextTranslateCTM(context, (-i * h_spacing), v_spacing);
    }
    CGContextRestoreGState(context);
    
    CGLayerRelease(stripe_layer);
    CGLayerRelease(star_layer);
}

//简单的划线操作
void drawALine(CGContextRef context){
    //设置线条样式
    CGContextSetLineCap(context, kCGLineCapSquare);
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 1.0);
    //设置颜色
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    //开始一个起始路径
    CGContextBeginPath(context);
    //起始点设置为(0,0):注意这是上下文对应区域中的相对坐标，
    CGContextMoveToPoint(context, 200, 100);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, 200, 150);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, 100, 150);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, 100, 200);
    //连接上面定义的坐标点
    CGContextStrokePath(context);
}

//绘制矩形
void drawSquare(CGContextRef context){
    CGRect rect = CGRectMake(50, 100, 100, 100);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextSetLineWidth(context, 2.0f);
    CGContextStrokeRect(context, rect);
    
    //填充区域
    CGContextSetFillColorWithColor(context, [UIColor cyanColor].CGColor);
    CGContextFillRect(context, rect);
}

void drawLinesConnection(CGContextRef context){

    CGContextSetLineWidth(context, 10.0f);
    /*设置线条交汇处样式
    kCGLineJoinMiter——尖角
    kCGLineJoinBevel——平角
    kCGLineJoinRound——圆形
     */
    CGContextSetLineJoin(context, kCGLineJoinMiter);
    CGContextMoveToPoint(context, 20.0f, 150.0f);
    CGContextAddLineToPoint(context, 20.0f, 80.0f);
    CGContextAddLineToPoint(context, 100.0f, 80.0f);
    CGContextStrokePath(context);
}

@implementation QuartzView

- (instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //giant the current context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    drawSquare(context);
//    drawLinesConnection(context);
    
//    colorPatternPainting(context, CGRectMake(120, 200, 50, 200));
//    drawStarsView(context, CGRectMake(50, 100, 200, 200));
//    drawShadow(context, 100, 100);
//    drawShading(context);
//    paintAxialShading(context, CGRectMake(0, 0, 300, 300));
//    paintRadialShading(context, CGRectMake(0, 0, 300, 300));
//    drawTransparecyLayer(context, 200, 200);
    
//    drawImage(context);
//    drawALine(context);
    
    /*
    CGRect r = CGRectMake(0, 0, 300, 200);
    CGRect *flagRect = &r;
    drawFlag(context, flagRect);
     */
}

@end
