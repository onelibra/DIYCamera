//
//  ViewController.m
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "ViewController.h"
#import "Camera/CameraViewController.h"
#import "Camera/CameraOverlayView.h"
@interface ViewController ()<CameraDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",  NSStringFromCGRect([UIApplication sharedApplication].statusBarFrame));
}

- (NSArray *)createphotoData {
    NSArray *arr = @[@{@"questionIndex": @6, @"questionType": @"填空题", @"isComplexQuestion": @NO},
                     @{@"questionIndex": @7, @"questionType": @"填空题", @"isComplexQuestion": @NO},
                     @{@"questionIndex": @8, @"questionType": @"解答题", @"isComplexQuestion": @NO},
                     @{@"questionIndex": @9, @"questionType": @"填空题", @"isComplexQuestion": @YES},
                     @{@"questionIndex": @10, @"questionType": @"填空题", @"isComplexQuestion": @NO}];
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (NSDictionary *dic in arr) {
        QuestionPhotoModel *model = [QuestionPhotoModel createModelWithDic:dic];
        [tmpArray addObject:model];
    }
    return tmpArray;
}

- (IBAction)clickup:(id)sender {
    CameraViewController *vc = [[CameraViewController alloc] init];
    vc.delegate = self;
    vc.questionBierfArray = [self createphotoData];
    vc.currentQuestionBierfArrayIndex = 2;
    [self presentViewController:vc animated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)allQuestionImagePickerFinishAndMediaInfo:(NSArray *)info {
    QuestionPhotoModel *model1 = info[0];
    QuestionPhotoModel *model2 = info[1];
    QuestionPhotoModel *model3 = info[2];
    QuestionPhotoModel *model4 = info[3];
    QuestionPhotoModel *model5 = info[4];
    if (model1.writeprocess.count) {
        if (model1.writeprocess.count > 0) {
            _imageV11.image = model1.writeprocess[0];
        }
        if (model1.writeprocess.count > 1) {
            _imageV12.image = model1.writeprocess[1];
        }
    }
    if (model2.writeprocess.count) {
        if (model2.writeprocess.count > 0) {
            _imageV21.image = model2.writeprocess[0];
        }
        if (model2.writeprocess.count > 1) {
            _imageV22.image = model2.writeprocess[1];
        }
    }
    if (model3.writeprocess.count) {
        if (model3.writeprocess.count > 0) {
            _imageV31.image = model3.writeprocess[0];
        }
        if (model3.writeprocess.count > 1) {
            _imageV32.image = model3.writeprocess[1];
        }
    }
    if (model4.writeprocess.count) {
        if (model4.writeprocess.count > 0) {
            _imageV41.image = model4.writeprocess[0];
        }
        if (model4.writeprocess.count > 1) {
            _imageV42.image = model4.writeprocess[1];
        }
        if (model4.writeprocess.count > 2) {
            _imageV43.image = model4.writeprocess[2];
        }
        if (model4.writeprocess.count > 3) {
            _imageV44.image = model4.writeprocess[3];
        }
        if (model4.writeprocess.count > 4) {
            _imageV45.image = model4.writeprocess[4];
        }
    }
    if (model5.writeprocess.count) {
        if (model5.writeprocess.count > 0) {
            _imageV51.image = model5.writeprocess[0];
        }
        if (model3.writeprocess.count > 1) {
            _imageV52.image = model5.writeprocess[1];
        }
    }
}

@end
