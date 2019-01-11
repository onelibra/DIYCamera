//
//  CameraOverlayTipView.m
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "CameraOverlayTipView.h"

@interface CameraOverlayTipView()
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *questionIndexMsgLabel;
@property (weak, nonatomic) IBOutlet UIButton *lightBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipMsgLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *questionIndexCenterX;

@end

@implementation CameraOverlayTipView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.questionIndexMsgLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.lightBtn.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.tipMsgLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
}

#pragma mark - Public Fuction
- (void)setIsTakePhotoInterface:(BOOL)isTakePhotoInterface {
    _isTakePhotoInterface = isTakePhotoInterface;
    _questionIndexCenterX.constant = isTakePhotoInterface ? 0 : 10;
    _lightBtn.hidden = !isTakePhotoInterface;
    _tipMsgLabel.hidden = isTakePhotoInterface;
}
// 标题label赋值
- (void)setQuestionType:(NSString *)qtype andQuestionIndex:(NSNumber *)qIndex andWriteprocessArrayCount:(NSInteger)count {

    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"当前题号：%@ 第%@题", qtype, qIndex] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    if (count > 0) {
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" (第" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", count + 1] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor colorWithRed:80.0 / 255 green:209.0 / 255 blue:114.0 / 255 alpha:1]}]];
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@"张)" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    }
    _questionIndexMsgLabel.attributedText = attrString;
}

#pragma mark - IBAction
// 取消拍照
- (IBAction)backBtnClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(clickBackBtn)]) {
        [self.delegate clickBackBtn];
    }
}

// 闪光灯状态
- (IBAction)lightOnOrOffClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if ([self.delegate respondsToSelector:@selector(exchangeLightStatus:)]) {
        [self.delegate exchangeLightStatus:sender.selected];
    }
}
@end
