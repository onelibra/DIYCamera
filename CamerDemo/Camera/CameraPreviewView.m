//
//  CameraPreviewView.m
//  CamerDemo
//
//  Created by yangbo on 2018/12/28.
//  Copyright © 2018年 yang. All rights reserved.
//

#import "CameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>
@implementation CameraPreviewView

+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    ((AVCaptureVideoPreviewLayer *)self.layer).videoGravity = AVLayerVideoGravityResizeAspectFill;
}

@end
