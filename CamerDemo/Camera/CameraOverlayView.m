//
//  CameraOverlayView.m
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "CameraOverlayView.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <CoreMotion/CoreMotion.h>

@interface CameraOverlayView()

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property(nonatomic)AVCaptureDevice *device;
//AVCaptureDeviceInput 代表输入设备，他使用AVCaptureDevice 来初始化
@property(nonatomic)AVCaptureDeviceInput *input;
//当启动摄像头开始捕获输入
@property(nonatomic)AVCaptureMetadataOutput *output;
//照片输出流
@property (nonatomic)AVCaptureStillImageOutput *ImageOutPut;
//session：由他把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property(nonatomic)AVCaptureSession *session;
//图像预览层，实时显示捕获的图像
@property(nonatomic)AVCaptureVideoPreviewLayer *previewLayer;

@property (strong, nonatomic) CMMotionManager *motionManager;  // 陀螺仪
@property (assign, nonatomic) NSInteger deviceOrientention;

@property (strong, nonatomic) AVCaptureConnection * videoConnection;

@property (weak, nonatomic) IBOutlet UIButton *photoBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *tipMsgLabel;

@property (strong, nonatomic) UIView *focusView;
@property (nonatomic, assign) CGFloat effectiveScale;
@property (assign, nonatomic) CGFloat maxScale;


@end
@implementation CameraOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    // layer
    _preBtn.layer.cornerRadius = _nextBtn.layer.cornerRadius = _cameraBtn.layer.cornerRadius = _photoBtn.layer.cornerRadius = 4;
    _preBtn.layer.borderWidth = _nextBtn.layer.borderWidth = _cameraBtn.layer.borderWidth = _photoBtn.layer.borderWidth = 1;
    _preBtn.layer.borderColor = _nextBtn.layer.borderColor = _cameraBtn.layer.borderColor = _photoBtn.layer.borderColor = [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1].CGColor;
    
    // 聚焦
    self.focusView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
    self.focusView.layer.borderWidth = 1.0;
    self.focusView.layer.borderColor = [UIColor blueColor].CGColor;
    [self.cameraPreview addSubview:self.focusView];
    self.focusView.hidden = YES;
    // 单击聚焦
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusGesture:)];
    [self.cameraPreview addGestureRecognizer:tapGesture];
    // 捏合调焦
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinGestureAction:)];
    [self.cameraPreview addGestureRecognizer:pinGesture];
    // 添加相机输入输出
    [self customCamera];
}

- (void)customCamera
{
    //使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //使用设备初始化输入
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //生成输出对象
    self.output = [[AVCaptureMetadataOutput alloc]init];
    
    self.ImageOutPut = [[AVCaptureStillImageOutput alloc]init];
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
//    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
//        [self.session setSessionPreset:AVCaptureSessionPreset1280x720];
//    }
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.ImageOutPut]) {
        [self.session addOutput:self.ImageOutPut];
    }
    
    //使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
//    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
//    [self.cameraPreview.layer addSublayer:self.previewLayer];
//    self.previewLayer.frame = self.cameraPreview.bounds;// CGRectMake(0, 0, self.frame.size.width - 100, self.frame.size.height);
    ((AVCaptureVideoPreviewLayer *)self.cameraPreview.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
    ((AVCaptureVideoPreviewLayer *)self.cameraPreview.layer).session = self.session;

    //修改设备的属性，先加锁
    if ([self.device lockForConfiguration:nil]) {
        //闪光灯自动
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        //自动白平衡
        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        //解锁
        [self.device unlockForConfiguration];
    }
    
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection ==  nil) {
        return;
    }
    self.videoConnection = videoConnection;
//    if ([self.videoConnection isVideoOrientationSupported]) {
//        [self.videoConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//    }
    self.maxScale = [self.videoConnection videoMaxScaleAndCropFactor];
    
    // 陀螺仪
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 1/10.f;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.cameraBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.preBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.nextBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.tipMsgLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
}

#pragma mark - Button Function
// 拍照按钮
- (IBAction)takeCameraBtnClick:(UIButton *)sender {
    [self shutterCamera];
}
// 相册选择
- (IBAction)clickPhotoFromGalleryBtn:(UIButton *)sender {
    if (@available(iOS 11.0, *)) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoFromGallery)]) {
            [self.delegate takePhotoFromGallery];
        }
    }else {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            // 无权限
            if (self.delegate && [self.delegate respondsToSelector:@selector(cameraNeedAuthorization:)]) {
                [self.delegate cameraNeedAuthorization:NO];
            }
        }else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(takePhotoFromGallery)]) {
                [self.delegate takePhotoFromGallery];
            }
        }
    }
}
// 下一题
- (IBAction)nextQuestionClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickNextQuestion)]) {
        [self.delegate clickNextQuestion];
    }
}
// 上一题
- (IBAction)preQuestionClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickPreQuestion)]) {
        [self.delegate clickPreQuestion];
    }
}
#pragma mark - Public Function
- (void)cameraStartRunning {
    [self.session startRunning];
    if (_motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [self performSelectorOnMainThread:@selector(deviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
}

- (void)deviceMotion:(CMDeviceMotion *)motion {
    double x = motion.gravity.x;
    double y = motion.gravity.y;
    double z = motion.gravity.z;
    float sensitive = 0.5;
    _deviceOrientention = UIDeviceOrientationUnknown;
    if (x > sensitive && fabs(y) < 0.5) {
        _deviceOrientention = UIDeviceOrientationLandscapeLeft;
    }else if (x < -sensitive && fabs(y) < 0.5){
        _deviceOrientention = UIDeviceOrientationLandscapeRight;
    }else if (fabs(x) < 0.2 && y < -0.5 && fabs(z) < 0.6){
        _deviceOrientention = UIDeviceOrientationPortrait;
    }else if (fabs(x) < 0.2 && y > 0.5 && fabs(z) < 0.6) {
        _deviceOrientention = UIDeviceOrientationPortraitUpsideDown;
    }
}

- (void)cameraStopRunning {
    [self.session stopRunning];
}

- (void)cameraIsOpenLight:(BOOL)isOpen {
    // 闪光灯
    if ([self.device lockForConfiguration:nil]) {
        if (isOpen) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        }else {
            [_device setTorchMode:AVCaptureTorchModeOff];
        }
        // 聚焦
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        // 曝光量调节
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [self.device setExposurePointOfInterest:CGPointMake(0.5, 0.5)];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        //解锁
        [self.device unlockForConfiguration];
    };
}

- (void)setButtonStatusWithCurrentQuestionIndex:(NSInteger)currentIndex andTotalQuestionCount:(NSInteger)totalCount {
    if (currentIndex == 0) {
        _preBtn.enabled = NO;
        _preBtn.layer.borderColor = [UIColor colorWithRed:211.0 / 255 green:211.0 / 255 blue:211.0 / 255 alpha:1].CGColor;
    }else {
        _preBtn.layer.borderColor = [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1].CGColor;
        _preBtn.enabled = YES;
    }
    if (currentIndex == totalCount - 1) {
        _nextBtn.enabled = NO;
        _nextBtn.layer.borderColor = [UIColor colorWithRed:211.0 / 255 green:211.0 / 255 blue:211.0 / 255 alpha:1].CGColor;
    }else{
        _nextBtn.layer.borderColor = [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1].CGColor;
        _nextBtn.enabled = YES;
    }
}

#pragma mark - GestureRecognizer
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.cameraPreview.bounds.size;
    // focusPoint 函数后面Point取值范围是取景框左上角（0，0）到取景框右下角（1，1）之间,按这个来但位置就是不对，只能按上面的写法才可以。前面是点击位置的y/PreviewLayer的高度，后面是1-点击位置的x/PreviewLayer的宽度
    CGPoint focusPoint = CGPointMake(point.y /size.height ,1 - point.x/size.width );
    
    if ([self.device lockForConfiguration:nil]) {
        // 聚焦
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        // 曝光量调节
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                weakSelf.focusView.hidden = YES;
            }];
        }];
    }
    
}

- (void)pinGestureAction:(UIPinchGestureRecognizer *)gesture {
    
    self.effectiveScale = self.effectiveScale *gesture.scale;
    if (self.effectiveScale < 1.0) {
        self.effectiveScale = 1.0;
    }
    if (self.effectiveScale > self.maxScale) {
        self.effectiveScale = self.maxScale;
    }
    
    CGFloat zoom = self.effectiveScale / _videoConnection.videoScaleAndCropFactor;
    
    if ([self.device lockForConfiguration:nil]) {
        _videoConnection.videoScaleAndCropFactor = self.effectiveScale;
        [self.device unlockForConfiguration];
    }
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [self.cameraPreview.layer setAffineTransform:CGAffineTransformScale(self.cameraPreview.layer.affineTransform, zoom, zoom)];
    [CATransaction commit];
    gesture.scale = 1.0;
    
}
#pragma mark- 拍照
- (void)shutterCamera
{
    AVCaptureConnection * videoConnection = [self.ImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection ==  nil) {
        return;
    }
    [self.ImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == nil) {
            return;
        }
        
        NSData *imageData =  [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        if ([self.delegate respondsToSelector:@selector(takeCameraFinishImage:orientation:)]) {
            [self.delegate takeCameraFinishImage:image orientation:self->_deviceOrientention];
        }
    }];
    
}



@end
