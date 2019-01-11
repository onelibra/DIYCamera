//
//  CameraResultOverlayView.m
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "CameraResultOverlayView.h"

@interface CameraResultOverlayView()
@property (weak, nonatomic) IBOutlet UIScrollView *photoContainerView;


@property (weak, nonatomic) IBOutlet UIView *controllerContainerView;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;

@property (weak, nonatomic) IBOutlet UIButton *reTakePhotoBtn;

@end

@implementation CameraResultOverlayView

- (void)awakeFromNib {
    [super awakeFromNib];
    _finishTakeAndNextBtn.titleLabel.numberOfLines = 2;
    _finishTakeAndNextBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    // layer
    _continueTakePhotoBtn.layer.cornerRadius = _finishTakeAndNextBtn.layer.cornerRadius = _reTakePhotoBtn.layer.cornerRadius = _finishBtn.layer.cornerRadius = 4;
    _continueTakePhotoBtn.layer.borderColor = _finishTakeAndNextBtn.layer.borderColor = _reTakePhotoBtn.layer.borderColor = [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1].CGColor;
    _continueTakePhotoBtn.layer.borderWidth = _finishTakeAndNextBtn.layer.borderWidth = _reTakePhotoBtn.layer.borderWidth = 1;
    
    self.photoContainerView.zoomScale = 1;
    self.photoContainerView.minimumZoomScale = 0.5;
    self.photoContainerView.maximumZoomScale = 2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.finishBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.continueTakePhotoBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.finishTakeAndNextBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.reTakePhotoBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    [self layoutIfNeeded];
    float insetWidth = 50;
    float insetHieght = 80;
    _photoContainerView.contentInset = UIEdgeInsetsMake(insetHieght, insetWidth, insetHieght, insetWidth);
}

#pragma mark - Public Function
// 设置拍下一题的按钮状态
- (void)setTakeNextQuestionBtnStatusWithCurrentIndex:(NSInteger)currentIndex andTotalQuestionNum:(NSInteger)totalNum {
    if (currentIndex == totalNum - 1) {
        self.finishTakeAndNextBtn.enabled = NO;
        _finishTakeAndNextBtn.layer.borderColor = [UIColor colorWithRed:211.0 / 255 green:211.0 / 255 blue:211.0 / 255 alpha:1].CGColor;
    }else {
        self.finishTakeAndNextBtn.enabled = YES;
        _finishTakeAndNextBtn.layer.borderColor = [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1].CGColor;
    }
}
// 拍下一张的按钮状态
- (void)takeNextPaperBtnStatusWithCurrentCount:(NSInteger)currentCount andAllowCount:(NSInteger)allowCount {
    if (currentCount == allowCount - 1) {
        self.continueTakePhotoBtn.enabled = NO;
         _continueTakePhotoBtn.layer.borderColor = [UIColor colorWithRed:211.0 / 255 green:211.0 / 255 blue:211.0 / 255 alpha:1].CGColor;
    }else {
        self.continueTakePhotoBtn.enabled = YES;
        _continueTakePhotoBtn.layer.borderColor = [UIColor colorWithRed:187.0 / 255 green:187.0 / 255 blue:187.0 / 255 alpha:1].CGColor;
    }
    NSArray *arr = @[@"一", @"二", @"三", @"四", @"五"];
    if (currentCount == allowCount - 1) {
        currentCount--;
    }else if (currentCount == allowCount) {
        currentCount -= 2;
    }
    [self.continueTakePhotoBtn setTitle:[NSString stringWithFormat:@"拍第%@张", arr[currentCount + 1]] forState:UIControlStateNormal];
}
#pragma mark - IBAction
// 重拍
- (IBAction)reTakePhoneClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(takePhotoAgain)]) {
        [self.delegate takePhotoAgain];
    }
}
// 拍照完成
- (IBAction)finishTakePhotoClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(takePhotoFinish)]) {
        [self.delegate takePhotoFinish];
    }
}
// 拍第二张
- (IBAction)takeQuestionNextPhotoClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(takePhotoNextTheQuestionPhoto)]) {
        [self.delegate takePhotoNextTheQuestionPhoto];
    }
}
// 拍下一题
- (IBAction)takeNextQuestionClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(takePhotoNextQuestion)]) {
        [self.delegate takePhotoNextQuestion];
    }
}

#pragma mark - UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale {
    if (scale < 1) {
        CGFloat scaleWidth = self.frame.size.width - self.frame.size.width * scale;
        CGFloat scaleHeight = self.frame.size.height - 100 - (self.frame.size.height - 100) * scale;
        _photoContainerView.contentInset = UIEdgeInsetsMake(80 + scaleHeight, scaleWidth + 50, 80 + scaleHeight, scaleWidth + 50);
    }else{
        _photoContainerView.contentInset = UIEdgeInsetsMake(80, 50, 80, 50);
    }
}

@end
