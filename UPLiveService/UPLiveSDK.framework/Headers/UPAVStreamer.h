//
//  UPAVStreamer.h
//  UPLiveSDKLib
//
//  Created by DING FENG on 6/15/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UPLiveSDKConfig.h"


typedef NS_ENUM(NSInteger, UPAVStreamerStatus) {
    UPAVStreamerStatusIdle,
    UPAVStreamerStatusConnecting,
    UPAVStreamerStatusConnected,
    UPAVStreamerStatusWriting,
    UPAVStreamerStatusOpenError,
    UPAVStreamerStatusWriteError,
    UPAVStreamerStatusClosed
};


@class UPAVStreamer;
@protocol UPAVStreamerDelegate <NSObject>
- (void)UPAVStreamer:(UPAVStreamer *)streamer statusDidChange:(UPAVStreamerStatus)status error:(NSError *)error;
@end


@interface UPAVStreamer : NSObject

@property (nonatomic) BOOL streamingOn;
@property (nonatomic, readonly) UPAVStreamerStatus streamerStatus;
@property (nonatomic, weak) id<UPAVStreamerDelegate> delegate;
@property (nonatomic) int64_t bitrate;
@property (nonatomic) BOOL audioOnly;// 单音频推流，默认值 NO

//dashboard
@property (nonatomic, readonly) CGFloat fps_capturer;
@property (nonatomic, readonly) CGFloat fps_streaming;
@property (nonatomic, readonly) CGFloat bps;
@property (nonatomic, readonly) int64_t vFrames_didSend;
@property (nonatomic, readonly) int64_t aFrames_didSend;
@property (nonatomic, readonly) int64_t streamSize_didSend;// bit
@property (nonatomic, readonly) int64_t streamTime_lasting;// ms
@property (nonatomic, readonly) int64_t cachedFrames;// video & audio
@property (nonatomic, readonly) int64_t dropedFrames;// video & audio



//推流器初始化
- (instancetype)initWithUrl:(NSString *)url;

//用于推流 AVCaptureSession 采集的 CMSampleBufferRef
- (void)pushVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)pushAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

//用于推流原始图像和声音数据(或者滤镜处理之后)
- (void)pushPixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (void)pushAudioBuffer:(AudioBuffer)audioBuffer info:(AudioStreamBasicDescription)asbd;

//用于推流 h264, aac 已经压缩编码的音视频数据
- (void)setVideoSpsPpsInfo:(NSData *)spspps;
- (void)setAudioAsbdInfo:(AudioStreamBasicDescription)asbd;
- (void)pushH264Frame:(NSData *)data isKeyFrame:(BOOL)keyFrame;
- (void)pushAACFrame:(NSData *)data;

//关闭推流
- (void)stop;

//推流重连
- (void)reconnect;

@end




