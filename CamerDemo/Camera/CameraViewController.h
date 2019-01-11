//
//  CameraViewController.h
//  CamerDemo
//
//  Created by yangbo on 2018/12/27.
//  Copyright © 2018年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraDelegate.h"
@class QuestionPhotoModel;
NS_ASSUME_NONNULL_BEGIN

@interface CameraViewController : UIViewController

@property (weak, nonatomic) id<CameraDelegate> delegate;
@property (strong, nonatomic) NSArray <QuestionPhotoModel *>*questionBierfArray;
@property (assign, nonatomic) NSInteger currentQuestionBierfArrayIndex; // questionBierfArray索引值

@end

NS_ASSUME_NONNULL_END


@interface QuestionPhotoModel : NSObject

@property (strong, nonatomic) NSNumber *questionIndex;     // 题号
@property (strong, nonatomic) NSString *questionType;      // 题型 (填空题, 解答题)
@property (assign, nonatomic) BOOL isComplexQuestion;      // 是否是复合题
@property (strong, nonatomic) NSArray<UIImage *> *writeprocess;       // 解题过程
@property (assign, nonatomic) BOOL isChangeWriteProcess;   // 是否进行过拍照图片的更改

+ (instancetype)createModelWithDic:(NSDictionary *)dic;
@end


