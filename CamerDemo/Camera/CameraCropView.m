//
//  CameraClipView.m
//  YjyxTeacher
//
//  Created by Yun Chen on 2017/6/21.
//  Copyright © 2017年 YJYX. All rights reserved.
//

#import "CameraCropView.h"


@interface CameraCropView()<HitViewDelegate>


@end
@implementation CameraCropView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

const static CGFloat hitViewSideLength = 40;
const static CGFloat hitViewSideLengthHalf = 20;

#pragma mark - Overrides
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cropView.layer.borderWidth = 1.0;
    self.cropView.layer.borderColor = UIColor.whiteColor.CGColor;
    
    self.topLeftHitView.delegate = self;
    self.topLeftHitView.indicatorCorner = HitViewIndicatorCornerTopLeft;
    self.topRightHitView.delegate = self;
    self.topRightHitView.indicatorCorner = HitViewIndicatorCornerTopRight;
    self.rightBottomHitView.delegate = self;
    self.rightBottomHitView.indicatorCorner = HitViewIndicatorCornerBottomRight;
    self.bottomLeftHitView.delegate = self;
    self.bottomLeftHitView.indicatorCorner = HitViewIndicatorCornerBottomLeft;
    
    self.topHitView.delegate = self;
    self.topHitView.movingDirection = HitViewMovingVertical;
    self.leftHitView.delegate = self;
    self.leftHitView.movingDirection = HitViewMovingHorizontal;
    self.rightHitView.delegate = self;
    self.rightHitView.movingDirection = HitViewMovingHorizontal;
    self.bottomHitView.delegate = self;
    self.bottomHitView.movingDirection = HitViewMovingVertical;
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self isInLeftTopCorner:point] || [self isInTopSide:point] || [self isInTopRightCorner:point] || [self isInRightSide:point]
        || [self isInRightBottomCorner:point] || [self isInLeftSide:point] || [self isInBottomLeftCorner:point] || [self isInBottomSide:point]) {
        return YES;
    }
    return NO;
}


#pragma mark - Custom Methods
- (void)layoutSubviewsInitially {
    self.cropView.frame = CGRectMake(0.0, 0.0, 200.0, self.frame.size.height * 0.85);
    self.cropView.center = CGPointMake((self.frame.size.width - 75) / 2.0, self.frame.size.height / 2.0);

    [self adjustRoundViewsFrame];
    [self adjustHitViewsFrame];
}

- (void)adjustRoundViewsFrame {
    self.topCoverView.frame = CGRectMake(0.0, 0.0, self.frame.size.width, self.cropView.frame.origin.y);
    self.leftCoverView.frame = CGRectMake(0.0, self.cropView.frame.origin.y, self.cropView.frame.origin.x, self.cropView.frame.size.height);
    self.rightCoverView.frame = CGRectMake(self.cropView.frame.origin.x + self.cropView.frame.size.width, self.cropView.frame.origin.y, self.frame.size.width - self.cropView.frame.size.width - self.cropView.frame.origin.x, self.cropView.frame.size.height);
    self.bottomCoverView.frame = CGRectMake(0.0, self.cropView.frame.origin.y + self.cropView.frame.size.height, self.frame.size.width, self.frame.size.height - self.cropView.frame.origin.y - self.cropView.frame.size.height);
}

- (void)adjustHitViewsFrame {
    self.topLeftHitView.frame = CGRectMake(self.cropView.frame.origin.x - hitViewSideLengthHalf, self.cropView.frame.origin.y - hitViewSideLengthHalf, hitViewSideLength, hitViewSideLength);
    self.topHitView.frame = CGRectMake(self.cropView.frame.origin.x + hitViewSideLengthHalf, self.topLeftHitView.frame.origin.y, self.cropView.frame.size.width - hitViewSideLength, hitViewSideLength);
    self.topRightHitView.frame = CGRectMake(self.cropView.frame.origin.x + self.cropView.frame.size.width - hitViewSideLengthHalf, self.topLeftHitView.frame.origin.y, hitViewSideLength, hitViewSideLength);
    self.rightHitView.frame = CGRectMake(self.topRightHitView.frame.origin.x, self.topRightHitView.frame.origin.y + self.topRightHitView.frame.size.height, hitViewSideLength, self.cropView.frame.size.height - hitViewSideLength);
    self.rightBottomHitView.frame = CGRectMake(self.topRightHitView.frame.origin.x, self.rightHitView.frame.origin.y + self.rightHitView.frame.size.height, hitViewSideLength, hitViewSideLength);
    self.leftHitView.frame = CGRectMake(self.topLeftHitView.frame.origin.x, self.topLeftHitView.frame.origin.y + self.topLeftHitView.frame.size.height, hitViewSideLength, self.cropView.frame.size.height - hitViewSideLength);
    self.bottomLeftHitView.frame = CGRectMake(self.leftHitView.frame.origin.x, self.leftHitView.frame.origin.y + self.leftHitView.frame.size.height, hitViewSideLength, hitViewSideLength);
    self.bottomHitView.frame = CGRectMake(self.topHitView.frame.origin.x, self.bottomLeftHitView.frame.origin.y, self.topHitView.frame.size.width, hitViewSideLength);
    
    self.topLeftHitView.limitRect = CGRectMake(0, 0, self.cropView.frame.origin.x + self.cropView.frame.size.width - 100, self.cropView.frame.origin.y + self.cropView.frame.size.height - 100);
    self.topHitView.limitRect = CGRectMake(0, 0, CGFLOAT_MAX, self.topLeftHitView.limitRect.size.height);
    self.topRightHitView.limitRect = CGRectMake(self.cropView.frame.origin.x + 100, 0, self.frame.size.width - self.cropView.frame.origin.x - 100, self.topLeftHitView.limitRect.size.height);
    self.rightHitView.limitRect = CGRectMake(self.topRightHitView.limitRect.origin.x, 0, self.topRightHitView.limitRect.size.width, CGFLOAT_MAX);
    self.rightBottomHitView.limitRect = CGRectMake(self.topRightHitView.limitRect.origin.x, self.cropView.frame.origin.y + 100, self.frame.size.width - self.cropView.frame.origin.x - 100, self.frame.size.height - self.cropView.frame.origin.y - 100);
    self.leftHitView.limitRect = CGRectMake(0, 0, self.topLeftHitView.limitRect.size.width, CGFLOAT_MAX);
    self.bottomLeftHitView.limitRect = CGRectMake(0, self.rightBottomHitView.limitRect.origin.y, self.topLeftHitView.limitRect.size.width, self.rightBottomHitView.limitRect.size.height);
    self.bottomHitView.limitRect = CGRectMake(0, self.rightBottomHitView.limitRect.origin.y, CGFLOAT_MAX, self.rightBottomHitView.limitRect.size.height);

}

- (BOOL)isInLeftTopCorner:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.topLeftHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.topLeftHitView.center.y);
    if (distanceHorizontal <= hitViewSideLengthHalf && distanceVertical <= hitViewSideLengthHalf) {
        return YES;
    }
    return NO;
}

- (BOOL)isInTopSide:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.topHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.topHitView.center.y);
    if (distanceHorizontal <= self.topHitView.frame.size.width * 0.5 && distanceVertical <= hitViewSideLengthHalf) {
        return YES;
    }
    return NO;
}

- (BOOL)isInTopRightCorner:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.topRightHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.topRightHitView.center.y);
    if (distanceHorizontal <= hitViewSideLengthHalf && distanceVertical <= hitViewSideLengthHalf) {
        return YES;
    }
    return NO;
}

- (BOOL)isInRightSide:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.rightHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.rightHitView.center.y);
    if (distanceHorizontal <= hitViewSideLengthHalf && distanceVertical <= self.rightHitView.frame.size.height * 0.5) {
        return YES;
    }
    return NO;
}

- (BOOL)isInRightBottomCorner:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.rightBottomHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.rightBottomHitView.center.y);
    if (distanceHorizontal <= hitViewSideLengthHalf && distanceVertical <= hitViewSideLengthHalf) {
        return YES;
    }
    return NO;
}

- (BOOL)isInLeftSide:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.leftHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.leftHitView.center.y);
    if (distanceHorizontal <= hitViewSideLengthHalf && distanceVertical <= self.leftHitView.frame.size.height * 0.5) {
        return YES;
    }
    return NO;
}

- (BOOL)isInBottomLeftCorner:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.bottomLeftHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.bottomLeftHitView.center.y);
    if (distanceHorizontal <= hitViewSideLengthHalf && distanceVertical <= hitViewSideLengthHalf) {
        return YES;
    }
    return NO;
}

- (BOOL)isInBottomSide:(CGPoint)point {
    CGFloat distanceHorizontal = fabs(point.x - self.bottomHitView.center.x);
    CGFloat distanceVertical = fabs(point.y - self.bottomHitView.center.y);
    if (distanceHorizontal <= self.bottomHitView.frame.size.width * 0.5 && distanceVertical <= hitViewSideLengthHalf) {
        return YES;
    }
    return NO;
}


#pragma mark - HitViewDelegate
-(void)centerChanged:(CGPoint)offset hitView:(HitView *)hitView {
    
    CGPoint origin = self.cropView.frame.origin;
    CGSize size = self.cropView.frame.size;
    NSLog(@"%@", NSStringFromCGPoint(origin) );
    
    if ([hitView isEqual:self.topLeftHitView]) {
        self.cropView.frame = CGRectMake(origin.x + offset.x, origin.y + offset.y, size.width - offset.x, size.height - offset.y);
    }
    else if ([hitView isEqual:self.topHitView]) {
        self.cropView.frame = CGRectMake(origin.x , origin.y + offset.y, size.width, size.height - offset.y);
    }
    else if ([hitView isEqual:self.topRightHitView]) {
        self.cropView.frame = CGRectMake(origin.x, origin.y + offset.y, size.width + offset.x, size.height - offset.y);
    }
    else if ([hitView isEqual:self.rightHitView]) {
        self.cropView.frame = CGRectMake(origin.x, origin.y, size.width + offset.x, size.height);
    }
    else if ([hitView isEqual:self.rightBottomHitView]) {
        self.cropView.frame = CGRectMake(origin.x, origin.y, size.width + offset.x, size.height + offset.y);
    }
    else if ([hitView isEqual:self.leftHitView]) {
        self.cropView.frame = CGRectMake(origin.x + offset.x, origin.y, size.width - offset.x, size.height);
    }
    else if ([hitView isEqual:self.bottomLeftHitView]) {
        self.cropView.frame = CGRectMake(origin.x + offset.x, origin.y, size.width - offset.x, size.height + offset.y);
    }
    else if ([hitView isEqual:self.bottomHitView]) {
        self.cropView.frame = CGRectMake(origin.x, origin.y, size.width, size.height + offset.y);
    }
    NSLog(@"%@", NSStringFromCGRect(self.cropView.frame));
    float SCREEN_WIDTH = [UIScreen mainScreen].bounds.size.width;
    if ([self.delegate respondsToSelector:@selector(isHiddenTipMessage:)]) {
        [self.delegate isHiddenTipMessage:CGRectGetMaxX(self.cropView.frame) > SCREEN_WIDTH - 75 - 2];
    }
    [self adjustRoundViewsFrame];
    [self adjustHitViewsFrame];
}

@end
