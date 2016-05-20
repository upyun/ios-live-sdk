//
//  UPLiveStreamerDemoViewController.h
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UPLiveSDK/UPAVCapturer.h>

@interface Settings : NSObject

/*
 rtmpServerPushPath + streamId 组合为完整的推流地址如: rtmp://testlivesdk.v0.upaiyun.com/live/123
 
 例如上面的地址，其中：
 rtmp                            为URL Scheme
 testlivesdk.v0.upaiyun.com      为推流服务器 host
 live                            为应用名
 123                             为流id
 
 以上组成一个完整的 rtmp 推流 url
 */
@property (nonatomic, strong) NSString *streamId;
@property (nonatomic, strong) NSString *rtmpServerPushPath;
@property (nonatomic, strong) NSString *rtmpServerPlayPath;
@property (nonatomic) int fps;//设置帧频率
@property (nonatomic) BOOL filter;//美颜滤镜开关
@property (nonatomic) BOOL streamingOnOff;//推流是否开启（Off 状态下，虽然有视频捕捉但是不会推流）
@property (nonatomic) BOOL camaraTorchOn;//闪光灯
@property (nonatomic) AVCaptureDevicePosition camaraPosition;//设置前置后置摄像头
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;//设置拍摄横屏竖屏幕
@property (nonatomic) UPAVCapturerPresetLevel level;
@property (nonatomic, assign) UPBeautifyFilterLevel filterLevel;

@end


@interface UPLiveStreamerDemoViewController : UIViewController
@property (nonatomic, strong) Settings *settings;
@end
