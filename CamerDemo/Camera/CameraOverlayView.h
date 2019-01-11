//
//  CameraOverlayView.h
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface CameraOverlayView : UIView

@property (weak, nonatomic) id<CameraDelegate> delegate;

- (void)cameraStartRunning;
- (void)cameraStopRunning;
- (void)cameraIsOpenLight:(BOOL)isOpen;

- (void)setButtonStatusWithCurrentQuestionIndex:(NSInteger)currentIndex andTotalQuestionCount:(NSInteger)totalCount;

@end

NS_ASSUME_NONNULL_END
