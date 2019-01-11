//
//  HitView.m
//  YjyxTeacher
//
//  Created by Yun Chen on 2017/6/21.
//  Copyright © 2017年 YJYX. All rights reserved.
//

#import "HitView.h"

@implementation HitView


#pragma mark - Overrides
- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panningAction:)];
    gesture.maximumNumberOfTouches = 1;
    gesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:gesture];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (self.indicatorCorner != HitViewIndicatorCornerNone) {
        CGPoint centerPoint = CGPointMake(rect.size.width * 0.5, rect.size.height * 0.5);
        switch (self.indicatorCorner) {
            case HitViewIndicatorCornerTopLeft:
                [self drawIndicatorLineFromPoint:centerPoint toPoint:CGPointMake(rect.size.width, centerPoint.y) toPoint:CGPointMake(centerPoint.x, rect.size.height)];
                break;
            case HitViewIndicatorCornerTopRight:
                [self drawIndicatorLineFromPoint:centerPoint toPoint:CGPointMake(0, centerPoint.y) toPoint:CGPointMake(centerPoint.x, rect.size.height)];
                break;
            case HitViewIndicatorCornerBottomLeft:
                [self drawIndicatorLineFromPoint:centerPoint toPoint:CGPointMake(centerPoint.x, 0) toPoint:CGPointMake(rect.size.width, centerPoint.y)];
                break;
            case HitViewIndicatorCornerBottomRight:
                [self drawIndicatorLineFromPoint:centerPoint toPoint:CGPointMake(centerPoint.x, 0) toPoint:CGPointMake(0, centerPoint.y)];
                break;
            default:
                break;
        }
    }
}


#pragma mark - Custom Methods
- (void)drawIndicatorLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint1 toPoint:(CGPoint)toPoint2 {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 4.0f);
    
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint1.x, toPoint1.y);
    
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(context, toPoint2.x, toPoint2.y);
    
    CGContextMoveToPoint(context, fromPoint.x - 2, fromPoint.y);
    CGContextAddLineToPoint(context, fromPoint.x + 2, fromPoint.y);
    
    CGContextStrokePath(context);
}


- (void)panningAction:(UIPanGestureRecognizer *)gesture {
    CGPoint point = CGPointMake([gesture locationInView:self.superview].x, [gesture locationInView:self.superview].y);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        beginningPoint = point;
    }
    else{
        CGPoint offset;
        CGPoint newCenter;
        
        switch (self.movingDirection) {
            case HitViewMovingVertical:
                offset = CGPointMake(0, point.y - beginningPoint.y);
                newCenter = CGPointMake(self.center.x ,self.center.y + offset.y);
                break;
            case HitViewMovingHorizontal:
                offset = CGPointMake(point.x - beginningPoint.x, 0);
                newCenter = CGPointMake(self.center.x + offset.x,self.center.y);
                break;
            case HitViewMovingAny:
            default:
                offset = CGPointMake(point.x - beginningPoint.x, point.y - beginningPoint.y);
                newCenter = CGPointMake(self.center.x + offset.x,self.center.y + offset.y);
                break;
        }
        
        if (CGRectContainsPoint(self.limitRect,newCenter)) {
            self.center = newCenter;
            
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(centerChanged: hitView:)]) {
                [self.delegate centerChanged:offset hitView:self];
            }
            
            beginningPoint = point;
        }
    }
}


@end
