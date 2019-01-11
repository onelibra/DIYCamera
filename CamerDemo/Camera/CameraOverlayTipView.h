//
//  CameraOverlayTipView.h
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface CameraOverlayTipView : UIView

@property (weak, nonatomic) id<CameraDelegate> delegate;
@property (assign, nonatomic) BOOL isTakePhotoInterface; // 是否是拍照界面
//- (void)layoutSubviewsCustomed;
- (void)setQuestionType:(NSString *)qtype andQuestionIndex:(NSNumber *)qIndex andWriteprocessArrayCount:(NSInteger)count;


@end

NS_ASSUME_NONNULL_END
