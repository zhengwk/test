//
//  SpeedLimitBoard.m
//  test
//
//  Created by apple on 16/10/14.
//  Copyright © 2016年 truckbubba. All rights reserved.
//

#import "SpeedLimitBoard.h"

const NSInteger kSLDialDefautLabelFontSize = 10;

const NSInteger kSLDialMajorTickCount = 9;//有多少个大格子
const NSInteger kSLDialMajorTickDivisions = 2;//一大格包含多少小格
const CGFloat kSLDefaultStartAngle = 0;
const CGFloat kSLDefaultEndAngle = M_PI;

const CGFloat kSLDefalutMajorLength = 15.0;
const CGFloat kSLDefaultInner = 40.0;//最外面的圆和最里面的圆的半径差

const NSInteger kSLDefaultValue = 180;

@interface SpeedLimitBoard ()


@end


@implementation SpeedLimitBoard


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat radius = (rect.size.width>rect.size.height?MIN(rect.size.width/2, rect.size.height):MIN(rect.size.width, rect.size.height/2))-8;
    CGPoint center = CGPointMake(rect.size.width/2, rect.size.height);
    //裁切view为半圆状态
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath addArcWithCenter:center radius:radius+8 startAngle:0 endAngle:-M_PI clockwise:0];
    [maskPath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -2.0);
    self.layer.shadowRadius = 3.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//    CGContextFillRect(context, rect);
    
    [self drawCircleWithContext:context Center:center Raidus:radius startAngle:kSLDefaultStartAngle endAngle:kSLDefaultEndAngle color:[UIColor colorWithRed:0/255.0 green:126/255.0 blue:244/255.0 alpha:1]];
    
    [self drawCircleWithContext:context Center:center Raidus:radius startAngle:kSLDefaultStartAngle endAngle:[self getAngleWithSpeed:self.speed] color:[UIColor greenColor]];
    
    [self drawCircleWithContext:context Center:center Raidus:radius-kSLDefalutMajorLength startAngle:kSLDefaultStartAngle endAngle:kSLDefaultEndAngle color:[UIColor colorWithRed:0/255.0 green:113/255.0 blue:219/255.0 alpha:1]];
    
    [self drawCircleWithContext:context Center:center Raidus:radius-kSLDefalutMajorLength startAngle:kSLDefaultStartAngle endAngle:[self getAngleWithSpeed:self.limitSpeed] color:[UIColor colorWithRed:26/255.0 green:139/255.0 blue:245/255.0 alpha:1.0]];
    
    [self drawCircleWithContext:context Center:center Raidus:radius-kSLDefaultInner startAngle:kSLDefaultStartAngle endAngle:kSLDefaultEndAngle color:[UIColor colorWithRed:0/255.0 green:88/255.0 blue:170/255.0 alpha:1]];
    
    [self drawDialWithContext:context Center:center Raidus:radius];
    [self drawSpeedLimitWithContext:context Center:center Radius:radius-kSLDefaultInner LimitSpeed:self.limitSpeed];
    
}

- (void)drawCircleWithContext:(CGContextRef)context Center:(CGPoint)center Raidus:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle color:(UIColor *)color
{
    startAngle = startAngle - M_PI;
    endAngle = endAngle - M_PI;
    CGContextSetFillColorWithColor(context, color.CGColor);
    UIBezierPath *scaleCircle = [UIBezierPath bezierPath];
    [scaleCircle addArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:1];
    [scaleCircle addLineToPoint:center];
    [scaleCircle closePath];
    [scaleCircle fill];
}

- (void)drawDialWithContext:(CGContextRef)context Center:(CGPoint)center Raidus:(CGFloat)radius
{
    CGFloat sumAngle = fabs(kSLDefaultEndAngle-kSLDefaultStartAngle);
    CGFloat averageAngle = sumAngle/(kSLDialMajorTickCount*kSLDialMajorTickDivisions);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    UIBezierPath *scaleCircle = [UIBezierPath bezierPath];
    [scaleCircle addArcWithCenter:center radius:radius startAngle:kSLDefaultStartAngle endAngle:kSLDefaultEndAngle clockwise:0];
    [scaleCircle addArcWithCenter:center radius:radius-kSLDefalutMajorLength startAngle:kSLDefaultStartAngle endAngle:kSLDefaultEndAngle clockwise:0];
    [scaleCircle stroke];
    NSInteger textAverage = kSLDefaultValue/kSLDialMajorTickCount;
    NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init];//段落样式
    NSTextAlignment align=NSTextAlignmentCenter;//对齐方式
    style.alignment=align;
    for (int i=0; i<kSLDialMajorTickCount*kSLDialMajorTickDivisions+1; i++) {
        //弧外面的位置
        CGFloat fx = center.x - radius*cos(averageAngle*i);
        CGFloat fy = center.y - radius*sin(averageAngle*i);
        
        CGFloat innerLength = kSLDefalutMajorLength;
        if (i%kSLDialMajorTickDivisions!=0) {
            CGContextSetLineWidth(context, 1);
            innerLength = kSLDefalutMajorLength/2;
        }else{
            CGContextSetLineWidth(context, 1.5);
            
            NSString *text = [NSString stringWithFormat:@"%ld",(long)textAverage*i/kSLDialMajorTickDivisions];
            
            //text的位置
            CGFloat tx = center.x - (radius-1.8*kSLDefalutMajorLength)*cos(averageAngle*i);
            CGFloat ty = center.y - (radius-1.8*kSLDefalutMajorLength)*sin(averageAngle*i);
            if (i==0||i==kSLDialMajorTickCount*kSLDialMajorTickDivisions) {
                ty -= 6;
            }
            [text drawInRect:CGRectMake(tx-9, ty-5, 18, 10) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10.0],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:style}];
        }
        //弧里面的位置
        CGFloat ix = center.x - (radius-innerLength)*cos(averageAngle*i);
        CGFloat iy = center.y - (radius-innerLength)*sin(averageAngle*i);
        CGContextMoveToPoint(context, fx, fy);
        CGContextAddLineToPoint(context, ix, iy);
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)drawSpeedLimitWithContext:(CGContextRef)context Center:(CGPoint)center Radius:(CGFloat)radius LimitSpeed:(NSInteger)limitSpeed
{
    CGFloat angle = [self getAngleWithSpeed:limitSpeed];
    CGFloat x1 = center.x - radius*cos(angle);
    CGFloat y1 = center.y - radius*sin(angle);
    CGFloat x2 = center.x - (radius-8)*cos(angle);
    CGFloat y2 = center.y - (radius-8)*sin(angle);
    CGFloat x3 = center.x - (radius-10)*cos(angle-0.1);
    CGFloat y3 = center.y - (radius-10)*sin(angle-0.1);
    CGFloat x4 = center.x - (radius-10)*cos(angle+0.1);
    CGFloat y4 = center.y - (radius-10)*sin(angle+0.1);
    CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, x1, y1);
    CGContextAddLineToPoint(context, x3, y3);
    CGContextAddLineToPoint(context, x2, y2);
    CGContextAddLineToPoint(context, x4, y4);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    NSString *speedString = [NSString stringWithFormat:@"%ld",(long)limitSpeed];
    CGFloat width = radius/2*3;
    CGFloat height = radius/2;
    NSMutableParagraphStyle *style=[[NSMutableParagraphStyle alloc]init];//段落样式
    NSTextAlignment align=NSTextAlignmentCenter;//对齐方式
    style.alignment=align;
    [speedString drawInRect:CGRectMake(center.x-width/2, center.y-height, width, height) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:25.0],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:style}];
    [@"KM/H" drawInRect:CGRectMake(center.x-width/2, center.y-height-10, width, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:style}];
}

- (void)setSpeed:(NSInteger)speed
{
    _speed = speed;
    [self setNeedsDisplay];
}

- (void)setLimitSpeed:(NSInteger)limitSpeed
{
    _limitSpeed = limitSpeed;
    [self setNeedsDisplay];
}

- (CGFloat)getAngleWithSpeed:(NSInteger)speed
{
    return fabs(kSLDefaultEndAngle-kSLDefaultStartAngle)/kSLDefaultValue*speed;
}

@end
