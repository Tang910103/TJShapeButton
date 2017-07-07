//
//  ShapeButton.m
//  ADdrawRect
//
//  Created by Tang杰 on 2017/6/30.
//  Copyright © 2017年 andong. All rights reserved.
//

#import "ShapeButton.h"

@interface ShapeButton ()
@property(nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) CAShapeLayer *shapLayer;
@end

@implementation ShapeButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init
{
    if (self = [super init]) {
        _shapLayer = [CAShapeLayer layer];
        _shapLayer.strokeColor = [UIColor clearColor].CGColor;
        _shapLayer.lineWidth = 1;
        _shapLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_shapLayer];
    }
    
    return self;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    UIBezierPath* path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(width*0.5, 0)];
    [path addLineToPoint:CGPointMake(0, height*0.5)];
    [path addLineToPoint:CGPointMake(width*0.5, height)];
    [path addLineToPoint:CGPointMake(width, height*0.5)];
    [path closePath];
    _path = path;
    self.shapLayer.path = self.path.CGPath;
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
//    创建CGContextRef
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();

    //创建CGMutablePathRef
    CGMutablePathRef path = CGPathCreateMutable();
    path = CGPathCreateMutableCopy(self.path.CGPath);

    //绘制渐变
    [self drawRadialGradient:gc path:path startColor:[backgroundColor colorWithAlphaComponent:0.07].CGColor endColor:[backgroundColor colorWithAlphaComponent:0.6].CGColor];

    //注意释放CGMutablePathRef
    CGPathRelease(path);

    //从Context中获取图像，并显示在界面上
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self setBackgroundImage:img forState:UIControlStateNormal];
}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL res = [super pointInside:point withEvent:event];
    if (res) {
        if ([self.path containsPoint:point]) {
            return YES;
        }
        return NO;
    }
    return NO;
}
- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMaxY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
- (void)drawRadialGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint center = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMidY(pathRect));
    CGFloat radius = MAX(pathRect.size.width / 2.0, pathRect.size.height / 2.0) * sqrt(2);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}
@end
