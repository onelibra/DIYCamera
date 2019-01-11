//
//  CameraDelegate.h
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

@protocol CameraDelegate <NSObject>

@optional
/****************  tipMessage **************************************/
- (void)clickBackBtn;   // 取消拍照
- (void)exchangeLightStatus:(BOOL)isOpen;   // 闪光灯状态(打开/关闭)

/**************** takePhoto ****************************************/
- (void)clickPreQuestion;                   // 上一题
- (void)clickNextQuestion;                  // 下一题
- (void)takePhotoFromGallery;               // 从相册选取照片
- (void)takeCameraFinishImage:(UIImage *)image orientation:(UIDeviceOrientation)deviceOrientation;  // 拍摄的图片

/**************** resultPhoto **************************************/
- (void)takePhotoAgain;                     // 重拍
- (void)takePhotoFinish;                    // 拍照完成
- (void)takePhotoNextQuestion;              // 拍下一题照片
- (void)takePhotoNextTheQuestionPhoto;      // 拍摄这道题目第二张照片

/*************** handle CorpView  **********************************/
- (void)isHiddenTipMessage:(BOOL)isHidden;

/*********************  控制器回调 *******************/
- (void)imageFinishPickingMediaWithInfo:(NSArray *)info;

/* 授权 */
- (void)cameraNeedAuthorization:(BOOL)isCamera;

@end
