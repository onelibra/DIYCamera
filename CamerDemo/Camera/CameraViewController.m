//
//  CameraViewController.m
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "CameraViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>

#import "CameraOverlayView.h"
#import "CameraOverlayTipView.h"
#import "CameraResultOverlayView.h"
#import "CameraCropView.h"

#import "UIImage+Rotating.h"


@interface CameraViewController ()<CameraDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    CameraResultOverlayView *resultOverlayView;
    CameraOverlayView *overlayView;
    CameraOverlayTipView *tipOverlayView;
    
}
@property (weak, nonatomic) CameraCropView *cameraCropView;
@property (weak, nonatomic) UILabel *tipMessageLabel;
@property (assign, nonatomic) UIDeviceOrientation takePhotoOrientation;
@property (assign, nonatomic) BOOL isFromGallery;
@property (assign, nonatomic) BOOL isHiddenStatusBar;
@property (assign, nonatomic) BOOL theQuestionIsHasWriteProcess;

@end

@implementation CameraViewController

#pragma mark - Lazy
- (CameraCropView *)cameraCropView {
    if (!_cameraCropView) {
        // 刘海机型适配
        float remainSpace = 0;
        float minY = 0;
        if ([UIApplication sharedApplication].statusBarFrame.size.height > 20) {
            remainSpace = 44 + 34;
            minY = 44;
        }
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        float fixWidth = 105;    // 底部工具栏高度
        CameraCropView *cropView = [[[NSBundle mainBundle] loadNibNamed:@"CameraCropView" owner:self options:nil] firstObject];
        cropView.delegate = self;
        _cameraCropView = cropView;
        cropView.frame = CGRectMake(0, minY, screenSize.width, screenSize.height - remainSpace - fixWidth);
        [cropView layoutSubviewsInitially];
        [self.view addSubview:cropView];
    }
    return _cameraCropView;
}

- (UILabel *)tipMessageLabel {
    if (!_tipMessageLabel) {
        UILabel *label = [[UILabel alloc] init];
        _tipMessageLabel = label;
        label.text = @"当前题目已拍过,将覆盖原拍图片";
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:16];
        label.layer.cornerRadius = 4;
        label.layer.masksToBounds = YES;
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.view insertSubview:label atIndex:self.view.subviews.count - 1];
        [label sizeToFit];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(-50);
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(label.frame.size.width + 50);
            make.height.mas_equalTo(40);
        }];
        label.transform = CGAffineTransformMakeRotation(M_PI_2);
        label.alpha = 0.0;
        [UIView animateWithDuration:1.0 animations:^{
            label.alpha = 0.99;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:5.0 animations:^{
                label.alpha = 0.0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }];
    }
    return _tipMessageLabel;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // 重置数组的值是否改变
    for (QuestionPhotoModel *model in _questionBierfArray) {
        if (model.isChangeWriteProcess) {
            model.isChangeWriteProcess = NO;
        }
    }
    self.view.backgroundColor = [UIColor blackColor];
    if ([self cameraAuthorRequest]) {   // 请求相机权限
        [self setupUI];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (overlayView) {
        [overlayView cameraStartRunning];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isHiddenStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height <= 20;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isHiddenStatusBar = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    if (overlayView) {
        [overlayView cameraStopRunning];
    }
}

- (BOOL)prefersStatusBarHidden {
    return _isHiddenStatusBar;// [UIApplication sharedApplication].statusBarFrame.size.height <= 20;
}

- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - Setup
- (void)setupUI {
    float remainSpace = 0;   // 刘海机型适配
    float minY = 0;
    if ([UIApplication sharedApplication].statusBarFrame.size.height > 20) {
        remainSpace = 44 + 34;
        minY = 44;
    }
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    float fixWidth = 105;    // 底部工具栏高度
    float tipHeight = 75;    // 标题栏高度
    // 相机预览view and 工具view
    overlayView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CameraOverlayView class]) owner:nil options:nil].firstObject;
    overlayView.delegate = self;
    overlayView.frame = CGRectMake(0, minY, screenSize.width, screenSize.height - remainSpace);
    [overlayView setButtonStatusWithCurrentQuestionIndex:_currentQuestionBierfArrayIndex andTotalQuestionCount:_questionBierfArray.count];
    [self.view addSubview:overlayView];    
 
    // 提示信息view
    tipOverlayView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CameraOverlayView class]) owner:nil options:nil][1];
    tipOverlayView.delegate = self;
    tipOverlayView.frame = CGRectMake(screenSize.width - tipHeight, 0, tipHeight, screenSize.height - remainSpace - fixWidth);
    [self.view addSubview:tipOverlayView];
    QuestionPhotoModel *model = self.questionBierfArray[_currentQuestionBierfArrayIndex];
    [tipOverlayView setQuestionType:model.questionType andQuestionIndex:model.questionIndex andWriteprocessArrayCount:model.writeprocess.count];

    // 选择照片/拍照结果view
    resultOverlayView = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([CameraResultOverlayView class]) owner:nil options:nil].firstObject;
    resultOverlayView.delegate = self;
    resultOverlayView.frame = CGRectMake(0, minY, screenSize.width, screenSize.height - remainSpace);
    [self.view insertSubview:resultOverlayView belowSubview:tipOverlayView];
    resultOverlayView.hidden = YES;
}

#pragma mark - Private Function
// 相机授权
- (BOOL)cameraAuthorRequest {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined:// 未做决定
        {
            __block BOOL isAuthor = YES;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!granted) {
                        isAuthor = NO;
                        [self cameraNeedAuthorization:YES];
                    }
                });
            }];
            if (isAuthor) {
                return YES;
            }
        }
            break;
        case AVAuthorizationStatusRestricted: // 未被授权
        case AVAuthorizationStatusDenied: // 被拒绝
        {
            [self cameraNeedAuthorization:YES];
        }
            break;
        default:
            return YES;
            break;
    }
    return NO;
}
// 授权提示,引导开启
- (void)cameraNeedAuthorization:(BOOL)isCamera {
    NSString *message = @"请您设置允许APP访问您的相册->设置->隐私->相册,立即前往?";
    if (isCamera) {
        message = @"请您设置允许APP访问您的相机->设置->隐私->相机,立即前往?";
    }
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication]openURL:url];
        }
    }];
    [alertVC addAction:cancelAction];
    [alertVC addAction:yesAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

/********************** 两个界面的切换(拍摄/选取照片界面) *********************/
// 拍摄照片的ui界面
- (void)takeCameraUI {
    resultOverlayView.hidden = YES;
    overlayView.hidden = NO;
    tipOverlayView.hidden = NO;
    tipOverlayView.isTakePhotoInterface = YES;
    [_cameraCropView removeFromSuperview];
}
// 图片选取界面(是从相册还是相机获取的照片)
- (void)pickerImageUIFromGallery:(BOOL)isGallery {
    _isFromGallery = isGallery;
    tipOverlayView.isTakePhotoInterface = NO;
    resultOverlayView.hidden = NO;
    overlayView.hidden = YES;
    // 添加裁剪view
    [_cameraCropView removeFromSuperview];
    [self cameraCropView];
}
// 将裁剪好的图片保存到questionBierfArray的writeProcess
- (void)saveCropPhotoToArray {
    CGRect croppingRect = [self.view convertRect:_cameraCropView.cropView.frame toView:resultOverlayView.photoImageView];
    float screenW = [UIScreen mainScreen].bounds.size.width;
    float previewH = tipOverlayView.frame.size.height;
    float imageWHRatio = resultOverlayView.photoImageView.image.size.width * 1.0 / resultOverlayView.photoImageView.image.size.height;
    float previewWHRatio = screenW * 1.0 / previewH;
    CGFloat scale = 1.0;
    if (imageWHRatio > previewWHRatio) {
        scale = resultOverlayView.photoImageView.image.size.height / resultOverlayView.photoImageView.bounds.size.height;
        croppingRect.origin.x += (previewH * imageWHRatio - screenW) / 2.0;
    }else{
        scale = resultOverlayView.photoImageView.image.size.width / resultOverlayView.photoImageView.bounds.size.width;
        croppingRect.origin.y += (screenW / imageWHRatio - previewH) / 2.0;
    }
    croppingRect.origin.x *= scale;
    croppingRect.origin.y *= scale;
    croppingRect.size.width *= scale;
    croppingRect.size.height *= scale;
    UIImage *croppedImage = [self cropImage:resultOverlayView.photoImageView.image inFrame:croppingRect];
    NSLog(@"%@", NSStringFromCGSize(croppedImage.size));
    // 保存裁剪好的图片
    QuestionPhotoModel *model = _questionBierfArray[_currentQuestionBierfArrayIndex];
    model.isChangeWriteProcess = YES;
    if (model.writeprocess.count) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:model.writeprocess];
        [arr addObject:croppedImage];
        model.writeprocess = arr;
    }else {
        NSMutableArray *arr = [NSMutableArray arrayWithObject:croppedImage];
        model.writeprocess = arr;
    }
}
// 裁剪图片
-(UIImage*)cropImage:(UIImage *)image inFrame:(CGRect)frame{
    NSInteger isImageOrientation = UIImageOrientationUp;
    if (image.imageOrientation == UIImageOrientationRight) { //之前图片旋转过，切割时需要旋转回来
        isImageOrientation = UIImageOrientationRight;
        image = [image rotateInDegrees:-90];
    } else if (image.imageOrientation == UIImageOrientationLeft) {
        isImageOrientation = UIImageOrientationLeft;
        image = [image rotateInDegrees:90];
    } else if (image.imageOrientation == UIImageOrientationDown) {
        isImageOrientation = UIImageOrientationDown;
        image = [image rotateInDegrees:180];
    }
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    // 相机拍摄的照片,将图片进行自适应旋转
    if (!_isFromGallery) {
       if(_takePhotoOrientation == UIDeviceOrientationLandscapeRight || _takePhotoOrientation == UIDeviceOrientationUnknown) {
            croppedImage = [croppedImage rotateInDegrees:90];
        }else if (_takePhotoOrientation == UIDeviceOrientationLandscapeLeft) {
            croppedImage = [croppedImage rotateInDegrees:-90];
        }else if (_takePhotoOrientation == UIDeviceOrientationPortraitUpsideDown) {
            croppedImage = [croppedImage rotateInDegrees:180];
        }
    }
    return croppedImage;
}
// 更新界面
- (void)updatePhotoResultInterfaceDataWithQuestionIndex:(NSInteger)questionArrayIndex andIsClickNextQuestion:(BOOL)isClickNextQuestion {
    [_tipMessageLabel removeFromSuperview];
    QuestionPhotoModel *model = _questionBierfArray[questionArrayIndex];
    [tipOverlayView setQuestionType:model.questionType andQuestionIndex:model.questionIndex andWriteprocessArrayCount:model.writeprocess.count];
    [overlayView setButtonStatusWithCurrentQuestionIndex:questionArrayIndex andTotalQuestionCount:_questionBierfArray.count];
    [resultOverlayView setTakeNextQuestionBtnStatusWithCurrentIndex:questionArrayIndex andTotalQuestionNum:_questionBierfArray.count];
    [resultOverlayView takeNextPaperBtnStatusWithCurrentCount:model.writeprocess.count andAllowCount:model.isComplexQuestion ? 5 : 2];
    if (model.writeprocess.count && isClickNextQuestion) {
        _theQuestionIsHasWriteProcess = YES;
        NSInteger tmpIndex = _currentQuestionBierfArrayIndex;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 防止快速点击
            if (tmpIndex == self->_currentQuestionBierfArrayIndex) {
                [self tipMessageLabel];
            }
        });
    }else {
        _theQuestionIsHasWriteProcess = NO;
    }
}
#pragma mark - CameraDelegate
// 取消拍照
- (void)clickBackBtn {
    // 退出界面,返回信息
    if ([self.delegate respondsToSelector:@selector(allQuestionImagePickerFinishAndMediaInfo:)]) {
        [self.delegate allQuestionImagePickerFinishAndMediaInfo:_questionBierfArray];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 开启/关闭闪光灯
- (void)exchangeLightStatus:(BOOL)isOpen {
    [overlayView cameraIsOpenLight:isOpen];
}
/************************   拍照界面事件交互   ******************************/
// 去到相册选取图片
- (void)takePhotoFromGallery {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}
// 拍摄照片完成,进入图片裁剪
- (void)takeCameraFinishImage:(UIImage *)image orientation:(UIDeviceOrientation)deviceOrientation {
    _takePhotoOrientation = deviceOrientation;
    if (_theQuestionIsHasWriteProcess) {  // 提示过后,用户还是重拍了,移除之前拍的照片
        QuestionPhotoModel *model = _questionBierfArray[_currentQuestionBierfArrayIndex];
        model.writeprocess = nil;
    }
    [self updatePhotoResultInterfaceDataWithQuestionIndex:_currentQuestionBierfArrayIndex andIsClickNextQuestion:NO];
    [self pickerImageUIFromGallery:NO];
    resultOverlayView.photoImageView.image = image;
}
// 上一题
- (void)clickPreQuestion {
    _currentQuestionBierfArrayIndex--;
    [self updatePhotoResultInterfaceDataWithQuestionIndex:_currentQuestionBierfArrayIndex andIsClickNextQuestion:YES];
}
// 下一题
- (void)clickNextQuestion {
    _currentQuestionBierfArrayIndex++;
    [self updatePhotoResultInterfaceDataWithQuestionIndex:_currentQuestionBierfArrayIndex andIsClickNextQuestion:YES];
}
/************************    拍照结果界面事件交互  ************************/
// 重拍
- (void)takePhotoAgain {
    [self takeCameraUI];
}
// 裁剪完成回传图片
- (void)takePhotoFinish {
    [self saveCropPhotoToArray];
    [self clickBackBtn];
}
// 拍这道题的下一张照片
- (void)takePhotoNextTheQuestionPhoto {
    [self saveCropPhotoToArray];
    QuestionPhotoModel *model = _questionBierfArray[_currentQuestionBierfArrayIndex];
    [tipOverlayView setQuestionType:model.questionType andQuestionIndex:model.questionIndex andWriteprocessArrayCount:model.writeprocess.count];
    [self takeCameraUI];
}
// 拍下一题照片
- (void)takePhotoNextQuestion {
    [self saveCropPhotoToArray];
    _currentQuestionBierfArrayIndex++;
    [self takeCameraUI];
    [self updatePhotoResultInterfaceDataWithQuestionIndex:_currentQuestionBierfArrayIndex andIsClickNextQuestion:YES];
}
/**********************  裁剪view的操作交互<拖拽选取框> **********************/
// 裁剪图片时,隐藏提示标题
- (void)isHiddenTipMessage:(BOOL)isHidden {
    tipOverlayView.hidden = isHidden;
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (_theQuestionIsHasWriteProcess) {  // 提示过后,用户还是从相册选取了照片
        QuestionPhotoModel *model = _questionBierfArray[_currentQuestionBierfArrayIndex];
        model.writeprocess = nil;
    }
    [self updatePhotoResultInterfaceDataWithQuestionIndex:_currentQuestionBierfArrayIndex andIsClickNextQuestion:NO];
    [self pickerImageUIFromGallery:YES];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    resultOverlayView.photoImageView.image = image;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
@end


@implementation QuestionPhotoModel

+ (instancetype)createModelWithDic:(NSDictionary *)dic {
    QuestionPhotoModel *model = [[QuestionPhotoModel alloc] init];
    model.questionIndex = dic[@"questionIndex"];
    model.questionType = dic[@"questionType"];
    model.isComplexQuestion = [dic[@"isComplexQuestion"] boolValue];
    return model;
}
@end
