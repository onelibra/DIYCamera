//
//  HitView.h
//  YjyxTeacher
//
//  Created by Yun Chen on 2017/6/21.
//  Copyright © 2017年 YJYX. All rights reserved.
//

#import <UIKit/UIKit.h>


enum HitViewMovingDirection {
    HitViewMovingAny = 0,
    HitViewMovingHorizontal,
    HitViewMovingVertical,
};

enum HitViewIndicatorCorner {
    HitViewIndicatorCornerNone = 0,
    HitViewIndicatorCornerTopLeft,
    HitViewIndicatorCornerTopRight,
    HitViewIndicatorCornerBottomLeft,
    HitViewIndicatorCornerBottomRight
};


@class HitView;

@protocol HitViewDelegate <NSObject>
-(void)centerChanged:(CGPoint)offset hitView:(HitView *)hitView;
@end


@interface HitView : UIView {
    CGPoint beginningPoint;
}

@property (nonatomic,assign) enum HitViewMovingDirection movingDirection;
@property (nonatomic,assign) enum HitViewIndicatorCorner indicatorCorner;
@property (nonatomic,assign) CGRect limitRect;
@property (nonatomic,weak) id<HitViewDelegate> delegate;

@end
