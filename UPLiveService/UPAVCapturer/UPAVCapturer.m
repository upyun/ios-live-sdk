//
//  UPAVCapturer.m
//  UPAVCaptureDemo
//
//  Created by DING FENG on 3/31/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPAVCapturer.h"
#import <CommonCrypto/CommonDigest.h>
#import <UPLiveSDK/UPAVStreamer.h>

#import "GPUImage.h"
#import "GPUImageFramebuffer.h"
#import "LFGPUImageBeautyFilter.h"

@import  Accelerate;


@interface UPAVCapturer()<UPAVStreamerDelegate, UPAudioCaptureProtocol, UPVideoCaptureProtocol> {
    NSError *_capturerError;
    //backgroud push
    BOOL _applicationActive;
    CVPixelBufferRef _backGroundPixBuffer;
    int _backGroundFrameSendloopid;
    BOOL _backGroundFrameSendloopOn;
    
    //video size, capture size
    CGRect _capturerPresetLevelFrameCropRect;
}

@property (nonatomic, assign) int pushStreamReconnectCount;
@property (nonatomic, strong) UPAVStreamer *rtmpStreamer;
@property (nonatomic, strong) UPVideoCapture *upVideoCapture;
@property (nonatomic, strong) UPAudioCapture *audioUnitRecorder;

@end


#pragma mark capturer dash

@interface UPAVCapturerDashboard()

@property(nonatomic, weak) UPAVCapturer *infoSource_Capturer;

@end

@class UPAVCapturer;

@implementation UPAVCapturerDashboard

- (float)fps_capturer {
    return self.infoSource_Capturer.rtmpStreamer.fps_capturer;
}

- (float)fps_streaming {
    return self.infoSource_Capturer.rtmpStreamer.fps_streaming;
}

- (float)bps {
    return self.infoSource_Capturer.rtmpStreamer.bps;
}

- (int64_t)vFrames_didSend {
    return self.infoSource_Capturer.rtmpStreamer.vFrames_didSend;
}
- (int64_t)aFrames_didSend {
    return self.infoSource_Capturer.rtmpStreamer.aFrames_didSend;
}

- (int64_t)streamSize_didSend {
    return self.infoSource_Capturer.rtmpStreamer.streamSize_didSend;
}

- (int64_t)streamTime_lasting {
    return self.infoSource_Capturer.rtmpStreamer.streamTime_lasting;
}

- (int64_t)cachedFrames {
    return self.infoSource_Capturer.rtmpStreamer.cachedFrames;
}

- (int64_t)dropedFrames {
    return self.infoSource_Capturer.rtmpStreamer.dropedFrames;
}

- (NSString *)description {
    NSString *descriptionString = [NSString stringWithFormat:@"fps_capturer: %f \nfps_streaming: %f \nbps: %f \nvFrames_didSend: %lld \naFrames_didSend:%lld \nstreamSize_didSend: %lld \nstreamTime_lasting: %lld \ncachedFrames: %lld \ndropedFrames:%lld",
                                   self.fps_capturer,
                                   self.fps_streaming,
                                   self.bps,
                                   self.vFrames_didSend,
                                   self.aFrames_didSend,
                                   self.streamSize_didSend,
                                   self.streamTime_lasting,
                                   self.cachedFrames,
                                   self.dropedFrames];
    return descriptionString;
}

@end

@implementation UPAVCapturer

+ (UPAVCapturer *)sharedInstance {
    static UPAVCapturer *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[UPAVCapturer alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        self.capturerPresetLevel = UPAVCapturerPreset_640x480;
        _capturerPresetLevelFrameCropRect = CGRectZero;
        _fps = 24;
        _viewZoomScale = 1;
        _applicationActive = YES;
        _streamingOn = YES;
        _filterOn = NO;
        
        _dashboard = [UPAVCapturerDashboard new];
        _dashboard.infoSource_Capturer = self;
        
        _audioUnitRecorder = [[UPAudioCapture alloc] initWith:UPAudioUnitCategory_recorder];
        _audioUnitRecorder.delegate = self;
        
        _upVideoCapture = [[UPVideoCapture alloc]init];
        _upVideoCapture.delegate = self;
        [self addNotifications];
    }
    return self;
}

- (void)addNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidResignActive:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:[UIApplication sharedApplication]];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:[UIApplication sharedApplication]];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setFilterOn:(BOOL)filterOn {
    _filterOn = filterOn;
    _upVideoCapture.filterOn = filterOn;
}

- (void)setCapturerStatus:(UPAVCapturerStatus)capturerStatus {
    if (_capturerStatus == capturerStatus) {
        return;
    }
    _capturerStatus = capturerStatus;
    //代理方式回调采集器状态
    dispatch_async(dispatch_get_main_queue(), ^(){
        if ([self.delegate respondsToSelector:@selector(UPAVCapturer:capturerStatusDidChange:)]) {
            [self.delegate UPAVCapturer:self capturerStatusDidChange:_capturerStatus];
        }
        
        switch (_capturerStatus) {
            case UPAVCapturerStatusStopped:
                break;
            case UPAVCapturerStatusLiving:
                break;
            case UPAVCapturerStatusError: {
                [self stop];
                if ([self.delegate respondsToSelector:@selector(UPAVCapturer:capturerError:)]) {
                    [self.delegate UPAVCapturer:self capturerError:_capturerError];
                }
            }
                break;
            default:
                break;
        }
    });
}

- (void)setPushStreamStatus:(UPPushAVStreamStatus)pushStreamStatus {
    
    if (_pushStreamStatus == pushStreamStatus) {
        return;
    }
    _pushStreamStatus = pushStreamStatus;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        if ([self.delegate respondsToSelector:@selector(UPAVCapturer:pushStreamStatusDidChange:)]) {
            [self.delegate UPAVCapturer:self pushStreamStatusDidChange:_pushStreamStatus];
        }
        
        switch (_pushStreamStatus) {
            case UPPushAVStreamStatusClosed:
                break;
            case UPPushAVStreamStatusConnecting:
                break;
            case UPPushAVStreamStatusReady:
                break;
            case UPPushAVStreamStatusPushing:
                break;
            case UPPushAVStreamStatusError: {
                //失败重连尝试三次
                self.pushStreamReconnectCount = self.pushStreamReconnectCount + 1;
                NSString *message = [NSString stringWithFormat:@"UPAVPacketManagerStatusStreamWriteError %@, reconnect %d times", _capturerError, self.pushStreamReconnectCount];
                
                NSLog(@"%@",message);
                
                if (self.pushStreamReconnectCount < 3) {
                    [_rtmpStreamer reconnect];
                    return ;
                } else {
                    self.capturerStatus = UPAVCapturerStatusError;
                }
                break;
            }
        }
    });
}

- (void)setStreamingOn:(BOOL)streamingOn {
    _streamingOn = streamingOn;
    _rtmpStreamer.streamingOn = _streamingOn;
}

- (void)setOutStreamPath:(NSString *)outStreamPath {
    _rtmpStreamer = [[UPAVStreamer alloc] initWithUrl:outStreamPath];
    _rtmpStreamer.audioOnly = self.audioOnly;
    _rtmpStreamer.bitrate = _bitrate;
    _rtmpStreamer.delegate = self;
    _rtmpStreamer.streamingOn = _streamingOn;
}

- (void)setCamaraPosition:(AVCaptureDevicePosition)camaraPosition {
    if (AVCaptureDevicePositionUnspecified == camaraPosition) {
        return;
    }
    if (_camaraPosition == camaraPosition) {
        return;
    }
    _camaraPosition = camaraPosition;
    if (self.capturerStatus == UPAVCapturerStatusLiving) {
        [_upVideoCapture setCamaraPosition:camaraPosition];
    }
}

- (void)resetCapturerPresetLevelFrameSizeWithCropRect:(CGRect)cropRect {
    [_upVideoCapture resetCapturerPresetLevelFrameSizeWithCropRect:cropRect];
}

- (void)setCapturerPresetLevelFrameCropRect:(CGRect)capturerPresetLevelFrameCropRect {
    [self resetCapturerPresetLevelFrameSizeWithCropRect:capturerPresetLevelFrameCropRect];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    _videoOrientation = videoOrientation;
    [_upVideoCapture setVideoOrientation:videoOrientation];
}

- (void)setCapturerPresetLevel:(UPAVCapturerPresetLevel)capturerPresetLevel {
    _capturerPresetLevel = capturerPresetLevel;
    [_upVideoCapture setCapturerPresetLevel:capturerPresetLevel];
    
    switch (_capturerPresetLevel) {
        case UPAVCapturerPreset_480x360:{
            _bitrate = 400000;
            break;
        }
        case UPAVCapturerPreset_640x480:{
            _bitrate = 600000;
            break;
        }
        case UPAVCapturerPreset_1280x720:{
            _bitrate = 1200000;
            break;
        }
        default:{
            _bitrate = 600000;
            break;
        }
    }
    [self setBitrate:_bitrate];
}

- (void)setFps:(int32_t)fps{
    _fps = fps;
    _upVideoCapture.fps = fps;
}

- (CGFloat)fpsCapture {
    return _rtmpStreamer.fps_capturer;
}

- (void)setIncreaserRate:(int)increaserRate {
    _increaserRate = increaserRate;
    _audioUnitRecorder.increaserRate = increaserRate;
}

- (void)setDeNoise:(BOOL)deNoise {
    _deNoise = deNoise;
    _audioUnitRecorder.deNoise = deNoise;
}


- (UIView *)previewWithFrame:(CGRect)frame contentMode:(UIViewContentMode)mode {
    return [_upVideoCapture previewWithFrame:frame contentMode:mode];
}

- (void)start {
    _rtmpStreamer.audioOnly = self.audioOnly;
    [_upVideoCapture start];
    [_audioUnitRecorder start];
    self.capturerStatus = UPAVCapturerStatusLiving;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)stop {
    [_upVideoCapture stop];
    [_audioUnitRecorder stop];
    self.capturerStatus = UPAVCapturerStatusStopped;
    [_rtmpStreamer stop];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dealloc {
    [self removeNotifications];
    NSString *message = [NSString stringWithFormat:@"dealloc %@", self];
    NSLog(@"%@",message);
}


- (void)setCamaraTorchOn:(BOOL)camaraTorchOn {
    _camaraTorchOn = camaraTorchOn;
    [_upVideoCapture setCamaraTorchOn:camaraTorchOn];
}

- (void)setBitrate:(int64_t)bitrate {
    if (bitrate < 0) {
        return;
    }
    _bitrate = bitrate;
    _rtmpStreamer.bitrate = _bitrate;
}

- (void)setViewZoomScale:(CGFloat)viewZoomScale {
    _upVideoCapture.viewZoomScale = viewZoomScale;
}

#pragma mark-- filter 滤镜


- (void)setFilter:(GPUImageOutput<GPUImageInput> *)filter {
    [_upVideoCapture setFilter:filter];
}

- (void)setFilterName:(UPCustomFilter)filterName {
    [_upVideoCapture setFilterName:filterName];
}

- (void)setFilters:(NSArray *)filters {
    [_upVideoCapture setFilters:filters];
}

- (void)setFilterNames:(NSArray *)filterNames {
    [_upVideoCapture setFilterNames:filterNames];
}

#pragma mark UPAVStreamerDelegate

- (void)UPAVStreamer:(UPAVStreamer *)streamer statusDidChange:(UPAVStreamerStatus)status error:(NSError *)error {
    
    switch (status) {
        case UPAVStreamerStatusConnecting: {
            self.pushStreamStatus = UPPushAVStreamStatusConnecting;
        }
            break;
        case UPAVStreamerStatusWriting: {
            self.pushStreamStatus = UPPushAVStreamStatusPushing;
            self.pushStreamReconnectCount = 0;
        }
            break;
        case UPAVStreamerStatusConnected: {
            self.pushStreamStatus = UPPushAVStreamStatusReady;
        }
            break;
        case UPAVStreamerStatusWriteError: {
            _capturerError = error;
            self.pushStreamStatus = UPPushAVStreamStatusError;
        }
            break;
        case UPAVStreamerStatusOpenError: {
            _capturerError = error;
            self.pushStreamStatus = UPPushAVStreamStatusError;
        }
        case UPAVStreamerStatusClosed: {
            self.pushStreamStatus = UPPushAVStreamStatusClosed;
        }
            break;
    }
}

#pragma mark UPAudioCaptureProtocol

- (void)didReceiveBuffer:(AudioBuffer)audioBuffer info:(AudioStreamBasicDescription)asbd {
    [self didCaptureAudioBuffer:audioBuffer withInfo:asbd];
    if(!_applicationActive) {
        [self startFrameSendLoopWith:_backGroundFrameSendloopid];
    } else {
        [self stopFrameSendLoop];
    }
}

#pragma mark applicationActiveSwitch

- (void)applicationDidResignActive:(NSNotification *)notification {
    _applicationActive = NO;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    _applicationActive = YES;
}

#pragma mark backgroud push frame loop

- (void)stopFrameSendLoop {
    _backGroundFrameSendloopOn = NO;
    _backGroundFrameSendloopid = _backGroundFrameSendloopid + 1;
}

- (void)startFrameSendLoopWith:(int)loopid {
    if (_backGroundFrameSendloopOn) {
        return;
    }
    _backGroundFrameSendloopOn = YES;
    [self backGroundFrameSendLoopStart:loopid];
}

- (void)backGroundFrameSendLoopStart:(int)loopid {
    if (_backGroundFrameSendloopid != loopid) {
        return;
    }
    double delayInSeconds = 1.0 / _fps;
    __weak UPAVCapturer *weakself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_rtmpStreamer pushPixelBuffer:_backGroundPixBuffer];
        [weakself backGroundFrameSendLoopStart:loopid];
    });
}

#pragma mark push Capture audio/video buffer

- (void)didCapturePixelBuffer:(CVPixelBufferRef)pixelBuffer {
    [_rtmpStreamer pushPixelBuffer:pixelBuffer];
    _backGroundPixBuffer = pixelBuffer;
}

- (void)didCaptureAudioBuffer:(AudioBuffer)audioBuffer withInfo:(AudioStreamBasicDescription)asbd{
    typedef struct AudioBuffer  AudioBuffer;
    if (self.audioMute) {
        if (audioBuffer.mData) {
            memset(audioBuffer.mData, 0, audioBuffer.mDataByteSize);
        }
    }
    [_rtmpStreamer pushAudioBuffer:audioBuffer info:asbd];
}


#pragma mark upyun token
+ (NSString *)tokenWithKey:(NSString *)key
                    bucket:(NSString *)bucket
                expiration:(int)expiration
           applicationName:(NSString *)appName
                streamName:(NSString *)streamName {
    NSTimeInterval expiration_ = [[NSDate date] timeIntervalSince1970];
    NSString *input = [NSString stringWithFormat:@"%@&%d&/%@/%@", key, (int)expiration_ + expiration, appName, streamName];
    NSString *md5string = [UPAVCapturer md5:input];
    if (md5string.length != 32) {
        return nil;
    }
    NSString *token = [NSString stringWithFormat:@"%@%d", [md5string substringWithRange:NSMakeRange(12, 8)], (int)expiration_ + expiration];
    return token;
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
}

@end
