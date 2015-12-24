//
//  ETBubbing.m
//  StickRendering
//
//  Created by etund on 15/7/7.
//  Copyright (c) 2015年 etund. All rights reserved.
//
//CGPoint point = CGPointMake(10, 10);
#import "ETBubbing.h"
 
@interface ETBubbing()

@property (nonatomic, strong) UIView *smalCirView;
@property (nonatomic, assign) NSInteger oriRadius;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end
@implementation ETBubbing

#pragma mark - 数据懒加载

- (UIView *)smalCirView{
    if (!_smalCirView) {
        //    新建一个圆
        UIView *smalCirView = [[UIView alloc] init];
        smalCirView.backgroundColor = self.backgroundColor;
        _smalCirView = smalCirView;
    }
    return _smalCirView;
}

- (CAShapeLayer *)shapeLayer{
    if (!_shapeLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:shapeLayer below:self.layer];
        _shapeLayer = shapeLayer;
    }
    return _shapeLayer;
}



#pragma mark - 在移动到控件的时候调用
- (void)didMoveToSuperview{
    [self.superview insertSubview:self.smalCirView belowSubview:self];
    [self setUp];
}

- (void)setUp{
//    基本属性设置 颜色 大小 位置 
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    CGFloat w = self.bounds.size.width;
    self.layer.cornerRadius = w / 2;
    self.smalCirView.layer.cornerRadius = w/2;
    //    记录半径
    _oriRadius = w/2;
    _smalCirView.frame = self.frame;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    [self AddAniamtionLikeGameCenterBubble];
    NSLog(@"%@===",self.superview);
    
}

#pragma mark - 自定义方法
#pragma mark - 手势触发方法
#define MaxDistance 100
- (void)pan:(UIPanGestureRecognizer *)pan{
    
    //  移动
    CGPoint transPoint = [pan translationInView:self];
    CGPoint center = self.center;
    center.x += transPoint.x;
    center.y += transPoint.y;
    self.center = center;
    [pan setTranslation:CGPointZero inView:self];
    
    //  设置小圆变化的值
    CGFloat cirDistance = [self distanceWithPointA:self.center andPointB:self.smalCirView.center];
    CGFloat smallCirRadius = _oriRadius - cirDistance/10.0;
    if(smallCirRadius<0) smallCirRadius = 0;
    _smalCirView.bounds = CGRectMake(0, 0, smallCirRadius * 2, smallCirRadius * 2);
    self.smalCirView.layer.cornerRadius = smallCirRadius;
    
    //    画图
    if (cirDistance > MaxDistance) {
        self.smalCirView.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
        //        self.smalCirView  = nil;
        self.shapeLayer = nil;
    }else if(self.smalCirView.hidden == NO && cirDistance > 0){
        self.shapeLayer.path = [self getBezierPathWithSmallCir:self andBigCir:self.smalCirView].CGPath;
    }
    //    爆炸或还原
    if(pan.state == UIGestureRecognizerStateBegan){
        [self RemoveAniamtionLikeGameCenterBubble];
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (cirDistance > MaxDistance){
            CABasicAnimation *anima = [CABasicAnimation animation];
            anima.duration = 1.0;
            anima.keyPath = @"opacity";
            anima.toValue = @0;
            [self.layer addAnimation:anima forKey:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //                移除控件
                [self removeFromSuperview];
            });
        }else{
            //            回弹
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.center = self.smalCirView.center;
            } completion:^(BOOL finished) {
                self.smalCirView.hidden = NO;
                [self AddAniamtionLikeGameCenterBubble];
            }];
        }
    }
}

#pragma mark - 获取圆心距离
- (CGFloat)distanceWithPointA:(CGPoint)pointA  andPointB:(CGPoint)pointB{
    CGFloat offSetX = pointA.x - pointB.x;
    CGFloat offSetY = pointA.y - pointB.y;
    return sqrt(offSetX*offSetX + offSetY*offSetY);
}


#pragma mark - 添加动画
-(void)AddAniamtionLikeGameCenterBubble{
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.repeatCount = INFINITY;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 5.0;
    
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer = CGRectInset(self.frame, self.bounds.size.width / 2 - 3, self.bounds.size.width / 2 - 3);
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    [self.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    scaleX.duration = 1;
    scaleX.values = @[@1.0, @1.1, @1.0];
    scaleX.keyTimes = @[@0.0, @0.5, @1.0];
    scaleX.repeatCount = INFINITY;
    scaleX.autoreverses = YES;
    
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
    
    
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5;
    scaleY.values = @[@1.0, @1.1, @1.0];
    scaleY.keyTimes = @[@0.0, @0.5, @1.0];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
}

#pragma mark - 移除动画
-(void)RemoveAniamtionLikeGameCenterBubble{
    [self.layer removeAllAnimations];
}

#pragma mark - 获取贝塞尔曲线
- (UIBezierPath *)getBezierPathWithSmallCir:(UIView *)smallCir andBigCir:(UIView *)bigCir{
    //    获取最小的圆
    if (bigCir.frame.size.width < smallCir.frame.size.width) {
        UIView *view = bigCir;
        bigCir = smallCir;
        smallCir = view;
    }
    //    获取小圆的信息
    CGFloat d = [self distanceWithPointA:smallCir.center andPointB:bigCir.center];
    CGFloat x1 = smallCir.center.x;
    CGFloat y1 = smallCir.center.y;
    CGFloat r1 = smallCir.bounds.size.width/2;
    
    //    获取大圆的信息
    CGFloat x2 = bigCir.center.x;
    CGFloat y2 = bigCir.center.y;
    CGFloat r2 = bigCir.bounds.size.width/2;
    
    //    获取三角函数
    CGFloat sinA = (y2 - y1)/d;
    CGFloat cosA = (x2 - x1)/d;
    
    //    获取矩形四个点
    CGPoint pointA = CGPointMake(x1 - sinA*r1, y1 + cosA * r1);
    CGPoint pointB = CGPointMake(x1 + sinA*r1, y1 - cosA * r1);
    CGPoint pointC = CGPointMake(x2 + sinA*r2, y2 - cosA * r2);
    CGPoint pointD = CGPointMake(x2 - sinA*r2, y2 + cosA * r2);
    
    //    获取控制点，以便画出曲线
    CGPoint pointO = CGPointMake(pointA.x + d / 2 * cosA , pointA.y + d / 2 * sinA);
    CGPoint pointP =  CGPointMake(pointB.x + d / 2 * cosA , pointB.y + d / 2 * sinA);
    
    //    创建路径
    UIBezierPath *path =[UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointP];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointO];
    return path;
}

@end
