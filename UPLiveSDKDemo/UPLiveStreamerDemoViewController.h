//
//  UPLiveStreamerDemoViewController.h
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPAVCapturer.h"

@interface Settings : NSObject


@property (nonatomic, strong) NSString *streamId;
@property (nonatomic, strong) NSString *rtmpServerPushPath;
@property (nonatomic, strong) NSString *rtmpServerPlayPath;
@property (nonatomic) int fps;//设置帧频率
@property (nonatomic) BOOL beautifyOn;//美颜滤镜开关
@property (nonatomic) BOOL streamingOn;//推流是否开启（Off 状态下，虽然有视频捕捉但是不会推流）
@property (nonatomic) BOOL camaraTorchOn;//闪光灯
@property (nonatomic) AVCaptureDevicePosition camaraPosition;//设置前置后置摄像头
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;//设置拍摄横屏竖屏幕
@property (nonatomic) UPAVCapturerPresetLevel level;
@property (nonatomic, assign) int filterLevel;
@property (nonatomic) BOOL fullScreenPreviewOn;

@end


@interface UPLiveStreamerDemoViewController : UIViewController
@property (nonatomic, strong) Settings *settings;
@end
