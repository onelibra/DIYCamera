//
//  CameraClipView.h
//  YjyxTeacher
//
//  Created by Yun Chen on 2017/6/21.
//  Copyright © 2017年 YJYX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HitView.h"
#import "CameraDelegate.h"

@interface CameraCropView : UIView<HitViewDelegate,CameraDelegate>

@property(nonatomic,weak) IBOutlet UIView *cropView;
@property(nonatomic,weak) IBOutlet UIView *topCoverView;
@property(nonatomic,weak) IBOutlet UIView *leftCoverView;
@property(nonatomic,weak) IBOutlet UIView *rightCoverView;
@property(nonatomic,weak) IBOutlet UIView *bottomCoverView;

@property(nonatomic,weak) IBOutlet HitView *leftHitView;
@property(nonatomic,weak) IBOutlet HitView *topLeftHitView;
@property(nonatomic,weak) IBOutlet HitView *topHitView;
@property(nonatomic,weak) IBOutlet HitView *topRightHitView;
@property(nonatomic,weak) IBOutlet HitView *rightHitView;
@property(nonatomic,weak) IBOutlet HitView *rightBottomHitView;
@property(nonatomic,weak) IBOutlet HitView *bottomHitView;
@property(nonatomic,weak) IBOutlet HitView *bottomLeftHitView;

@property (weak, nonatomic) id<CameraDelegate> delegate;



- (void)layoutSubviewsInitially;

@end
