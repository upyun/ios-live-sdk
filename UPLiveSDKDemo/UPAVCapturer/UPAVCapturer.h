//
//  UPAVCapturer.h
//  UPAVCaptureDemo
//
//  Created by DING FENG on 3/31/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, UPAVCapturerStatus) {
    UPAVCapturerStatusStopped,
    UPAVCapturerStatusLiving,
    UPAVCapturerStatusError
};

typedef NS_ENUM(NSInteger, UPPushAVStreamStatus) {
    UPPushAVStreamStatusClosed,
    UPPushAVStreamStatusConnecting,
    UPPushAVStreamStatusReady,
    UPPushAVStreamStatusPushing,
    UPPushAVStreamStatusError
};

typedef NS_ENUM(NSInteger, UPAVCapturerPresetLevel) {
    UPAVCapturerPreset_480x360,
    UPAVCapturerPreset_640x480,
    UPAVCapturerPreset_1280x720
};

@interface UPAVCapturerDashboard: NSObject
@property (nonatomic, readonly) float fps_capturer;
@property (nonatomic, readonly) float fps_streaming;
@property (nonatomic, readonly) float bps;
@property (nonatomic, readonly) int64_t vFrames_didSend;
@property (nonatomic, readonly) int64_t aFrames_didSend;
@property (nonatomic, readonly) int64_t streamSize_didSend;
@property (nonatomic, readonly) int64_t streamTime_lasting;
@property (nonatomic, readonly) int64_t cachedFrames;
@property (nonatomic, readonly) int64_t dropedFrames;
@end

@class UPAVCapturer;
@protocol UPAVCapturerDelegate <NSObject>

//采集状态回调
- (void)UPAVCapturer:(UPAVCapturer *)capturer capturerStatusDidChange:(UPAVCapturerStatus)capturerStatus;
- (void)UPAVCapturer:(UPAVCapturer *)capturer capturerError:(NSError *)error;

//推流状态会回调
- (void)UPAVCapturer:(UPAVCapturer *)capturer pushStreamStatusDidChange:(UPPushAVStreamStatus)streamStatus;
@end


@interface UPAVCapturer : NSObject

@property (nonatomic, strong) NSString *outStreamPath;
@property (nonatomic) AVCaptureDevicePosition camaraPosition;
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic) UPAVCapturerPresetLevel capturerPresetLevel;
@property (nonatomic) CGRect capturerPresetLevelFrameCropRect;
@property (nonatomic) int32_t fps;//设置采集帧频
@property (nonatomic) int64_t bitrate;//设置目标推流比特率
@property (nonatomic) BOOL streamingOn;//默认为 YES，即 UPAVCapturer start 之后会立即推流直播;
@property (nonatomic) BOOL camaraTorchOn;
@property (nonatomic) BOOL filterOn;
/**The torch control camera zoom scale default 1.0, between 1.0 ~ 3.0*/
@property (nonatomic, assign) CGFloat viewZoomScale;

@property (nonatomic, weak) id<UPAVCapturerDelegate> delegate;
@property (nonatomic, readonly) UPAVCapturerStatus capturerStatus;
@property (nonatomic, readonly) UPPushAVStreamStatus pushStreamStatus;
@property (nonatomic, strong, readonly) UPAVCapturerDashboard *dashboard;
@property (nonatomic) BOOL audioOnly;// 单音频推流，默认值 NO
@property (nonatomic) BOOL audioMute;// 静音推流，默认值 NO


+ (UPAVCapturer *)sharedInstance;
- (void)start;
- (void)stop;
- (UIView *)previewWithFrame:(CGRect)frame contentMode:(UIViewContentMode)mode;



/*** 生成推流 token
 例如推流地址：rtmp://bucket.v0.upaiyun.com/live/abc?_upt=abcdefgh1370000600
 其中：
 bucket 为 bucket name；
 live 为 appName；
 abc 为 streamName；
 abcdefgh1370000600 为推流token 可以用此方法计算生成。
 ****/
+ (NSString *)tokenWithKey:(NSString *)key //空间密钥
                    bucket:(NSString *)bucket //空间名
                expiration:(int)expiration //token 过期时间
           applicationName:(NSString *)appName //应用名，比如示例推流地址中的 live
                streamName:(NSString *)streamName; //流名， 比如示例推流地址中的 abc

@end

