//
//  CameraResultOverlayView.h
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface CameraResultOverlayView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *continueTakePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *finishTakeAndNextBtn;

@property (weak, nonatomic) id<CameraDelegate> delegate;

- (void)setTakeNextQuestionBtnStatusWithCurrentIndex:(NSInteger)currentIndex andTotalQuestionNum:(NSInteger)totalNum;
- (void)takeNextPaperBtnStatusWithCurrentCount:(NSInteger)currentCount andAllowCount:(NSInteger)allowCount;

@end

NS_ASSUME_NONNULL_END
