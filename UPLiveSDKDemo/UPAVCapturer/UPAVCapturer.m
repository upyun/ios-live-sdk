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
#import "UPAudioUnitKit.h"
#import "GPUImage.h"
#import "GPUImageFramebuffer.h"
#import "LFGPUImageBeautyFilter.h"



@import  Accelerate;


#define ViaGPUImage YES
#define UPAVCapturerError @"UPAVCapturerError"
#define UPAVCapturerDebugOn YES


@interface UPAVCapturer()<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UPAVStreamerDelegate, UPAudioUnitKitProtocol> {
    //videoCapture
    AVCaptureSession *_captureSession;
    AVCaptureDevicePosition _camaraPosition;
    
    //audioCapture
    UPAudioUnitKit *_audioUnitRecorder;
    
    NSError *_capturerError;
    int64_t _bitrate;
    
    //backgroud push
    BOOL _applicationActive;
    CVPixelBufferRef _backGroundPixBuffer;
    int _backGroundFrameSendloopid;
    BOOL _backGroundFrameSendloopOn;
    
    //video preview
    UIView *_preview;
    UIViewContentMode _previewContentMode;
    
    //video size, capture size
    CGRect _capturerPresetLevelFrameCropRect;
    CGRect _presetVideoFrameRect;
    
    //camera focus
    CALayer *_focusLayer;
    
    UIInterfaceOrientation _previewOrientation;
}

@property (nonatomic, assign) int pushStreamReconnectCount;
@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic, strong) UPAVStreamer *rtmpStreamer;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) LFGPUImageBeautyFilter *beautifyFilter;
@property (nonatomic, strong) GPUImageCropFilter *cropfilter;
@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageUIElement *uielement;




@end

@interface UPAVCapturerDashboard()

@property(nonatomic, weak) UPAVCapturer *infoSource_Capturer;

@end

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
        _camaraPosition = AVCaptureDevicePositionBack;
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
        _audioUnitRecorder = [[UPAudioUnitKit alloc] initWith:UPAudioUnitCategory_recorder];
        _audioUnitRecorder.delegate = self;
        
        
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
        
        
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


- (void)gpuImageCameraSetup {
    
    // 初始化 GPUImageVideoCamera
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:_sessionPreset cameraPosition:_camaraPosition];

    // 设置横竖屏拍摄
    UIInterfaceOrientation videoCameraOrientation = UIInterfaceOrientationUnknown;
    switch (_videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            videoCameraOrientation = UIInterfaceOrientationPortrait;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            videoCameraOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            videoCameraOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            videoCameraOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
    }
    _videoCamera.outputImageOrientation = videoCameraOrientation;
    
    // 设置拍摄帧频
    _videoCamera.frameRate = _fps;
    
    // 设置拍摄预览画面
    if (!_preview) {
        _preview = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _preview.backgroundColor = [UIColor blackColor];
    }
    
    _gpuImageView = [[GPUImageView alloc] initWithFrame:_preview.bounds];
    switch (_previewContentMode) {
        case UIViewContentModeScaleToFill:
            [_gpuImageView setFillMode:kGPUImageFillModeStretch];
            break;
        case UIViewContentModeScaleAspectFit:
            [_gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatio];
            break;
        case UIViewContentModeScaleAspectFill:
            [_gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatioAndFill];
            break;
        default:
            [_gpuImageView setFillMode:kGPUImageFillModePreserveAspectRatio];
            break;
    }
    [self previewRemoveGpuImageView];
    [_preview insertSubview:_gpuImageView atIndex:0];
    [self preViewAddTapGesture];
    
    // 设置美颜滤镜
    [_beautifyFilter removeAllTargets];
    [_cropfilter removeAllTargets];
    [_videoCamera removeAllTargets];
    [_uielement removeAllTargets];
    
    _beautifyFilter = [[LFGPUImageBeautyFilter alloc] init];
    _beautifyFilter.beautyLevel = 0.5;

    //视频尺寸剪裁
    CGFloat cropX = _capturerPresetLevelFrameCropRect.origin.x / _presetVideoFrameRect.size.width;
    CGFloat cropY = _capturerPresetLevelFrameCropRect.origin.y / _presetVideoFrameRect.size.height;
    CGFloat cropW = _capturerPresetLevelFrameCropRect.size.width / _presetVideoFrameRect.size.width;
    CGFloat cropH = _capturerPresetLevelFrameCropRect.size.height / _presetVideoFrameRect.size.height;
    _cropfilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(cropX, cropY, cropW, cropH)];
    
    // 水印
    CGSize size = [UIScreen mainScreen].bounds.size;
    __block UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 44)];
    label.text = @"我是水印";
    label.textAlignment = NSTextAlignmentRight;
    
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    [subView addSubview:label];
    
    _uielement = [[GPUImageUIElement alloc] initWithView:subView];
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    blendFilter.mix = 1.0;
    //滤镜链
    GPUImageOutput *finalOutput = _videoCamera;
    [_videoCamera addTarget:_cropfilter];
    [_cropfilter addTarget:_beautifyFilter];
    
    BOOL addWaterMark = NO;
    
    GPUImageFilter *nFilter = [[GPUImageFilter alloc]init];
    
    if (addWaterMark) {
        [_beautifyFilter addTarget:blendFilter];
        [_uielement addTarget:blendFilter];
        [blendFilter addTarget:_gpuImageView];
        __weak GPUImageUIElement *weakUielement = _uielement;
        [_beautifyFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *outPut, CMTime time) {
            label.text = [NSString stringWithFormat:@"%@", [NSDate date]];
            [weakUielement update];
        }];
        finalOutput = blendFilter;
        
    } else {
        [_beautifyFilter addTarget:nFilter];
        [nFilter addTarget:_gpuImageView];
        finalOutput = nFilter;
    }
    
    if (!self.filterOn) {
        _beautifyFilter.beautyLevel = 0;
    }
    
    __weak typeof(self) weakself = self;
    //设置视频结果回调
    [finalOutput setFrameProcessingCompletionBlock:^(GPUImageOutput *outPut, CMTime time) {
        GPUImageFramebuffer *imageFramebuffer = outPut.framebufferForOutput;
        CVPixelBufferRef pixelBuffer = [imageFramebuffer pixelBuffer];
        [weakself didCapturePixelBuffer:pixelBuffer];
    }];

    
    //横屏旋转和前置拍摄镜面效果
    BOOL needRotation = NO;
    
    float  pviewOrientation_ = 0;
    float  videoOrientation_ = 0;
    switch (_previewOrientation) {
        case UIInterfaceOrientationUnknown: pviewOrientation_ =  0;
            break;
        case UIInterfaceOrientationPortrait: pviewOrientation_ =  0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown: pviewOrientation_ =  M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft: pviewOrientation_ =  M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight: pviewOrientation_ = - M_PI_2;
            break;
        default: pviewOrientation_ =  0;
            break;
    }
    
    switch (_videoOrientation) {
        case AVCaptureVideoOrientationPortrait: videoOrientation_ =  0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown: videoOrientation_ =  M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft: videoOrientation_ =  M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight: videoOrientation_ = - M_PI_2;
            break;
        default: videoOrientation_ =  0;
            break;
    }
    
    if (pviewOrientation_ != videoOrientation_) {
        needRotation = YES;
    }
    
    if (needRotation) {
        float deltaR = pviewOrientation_ - videoOrientation_;
        _gpuImageView.transform = CGAffineTransformMakeRotation(deltaR);
        //长宽需要对调
        if (fabs(deltaR) >= M_PI_4 && fabs(deltaR) <= (M_PI_4 + M_PI_2)) {
            CGRect oldRect = _gpuImageView.frame;
            _gpuImageView.frame = CGRectMake(0, 0, oldRect.size.height, oldRect.size.width);
        }
    }
    
    BOOL needFlip = NO;
    if (_camaraPosition == AVCaptureDevicePositionFront) {
        needFlip = YES;
    }
    if (needFlip) {
        [_gpuImageView setInputRotation:kGPUImageFlipHorizonal atIndex:0];
    }
}

- (void)setFilterOn:(BOOL)filterOn {
    _filterOn = filterOn;
    if (_filterOn) {
        _beautifyFilter.beautyLevel = 0.5;
    } else {
        _beautifyFilter.beautyLevel = 0;
    }
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
                if (UPAVCapturerDebugOn) {
                    NSLog(@"%@",message);
                }
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
        [self.videoCamera stopCameraCapture];
        [self gpuImageCameraSetup];
        [self.videoCamera startCameraCapture];
    }
}

- (AVCaptureSession *)captureSession {
    return self.videoCamera.captureSession;
}


- (void)resetCapturerPresetLevelFrameSizeWithCropRect:(CGRect)cropRect {
    
    BOOL portrait = YES;
    if (_videoOrientation == AVCaptureVideoOrientationLandscapeRight
        || _videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        portrait = NO;
    }
    
    CGFloat presetWidth = 640;
    CGFloat presetHeight = 480;
    switch (_capturerPresetLevel) {
        case UPAVCapturerPreset_480x360:{
            presetWidth = 480;
            presetHeight = 360;
            break;
        }
        case UPAVCapturerPreset_640x480:{
            presetWidth = 640;
            presetHeight = 480;
            break;
        }
        case UPAVCapturerPreset_1280x720:{
            presetWidth = 1280;
            presetHeight = 720;
            break;
        }
    }
    
    if (portrait) {
        CGFloat w = MIN(presetHeight, presetWidth);
        CGFloat h = MAX(presetHeight, presetWidth);
        presetWidth = w;
        presetHeight = h;
    }
    _presetVideoFrameRect = CGRectMake(0, 0, presetWidth, presetHeight);
    if (cropRect.origin.x + cropRect.size.width > presetWidth
        || cropRect.origin.y + cropRect.size.height > presetHeight) {
        //超出范围，设置不成功；
        _capturerPresetLevelFrameCropRect = _presetVideoFrameRect;
    } else {
        _capturerPresetLevelFrameCropRect = cropRect;
    }
    
    if (_capturerPresetLevelFrameCropRect.size.width * _capturerPresetLevelFrameCropRect.size.height == 0) {
        //大小为0，设置不成功；
        _capturerPresetLevelFrameCropRect = _presetVideoFrameRect;
    }
}

- (void)setCapturerPresetLevelFrameCropRect:(CGRect)capturerPresetLevelFrameCropRect {
    [self resetCapturerPresetLevelFrameSizeWithCropRect:capturerPresetLevelFrameCropRect];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    _videoOrientation = videoOrientation;
    [self resetCapturerPresetLevelFrameSizeWithCropRect:_capturerPresetLevelFrameCropRect];
}

- (void)setCapturerPresetLevel:(UPAVCapturerPresetLevel)capturerPresetLevel {
    _capturerPresetLevel = capturerPresetLevel;
    [self resetCapturerPresetLevelFrameSizeWithCropRect:_capturerPresetLevelFrameCropRect];
    
    switch (_capturerPresetLevel) {
        case UPAVCapturerPreset_480x360:{
            _sessionPreset = AVCaptureSessionPresetMedium;
            _bitrate = 400000;
            break;
        }
        case UPAVCapturerPreset_640x480:{
            _sessionPreset = AVCaptureSessionPreset640x480;
            _bitrate = 600000;
            break;
        }
        case UPAVCapturerPreset_1280x720:{
            _sessionPreset = AVCaptureSessionPreset1280x720;
            _bitrate = 1200000;
            break;
        }
        default:{
            _sessionPreset = AVCaptureSessionPreset640x480;
            _bitrate = 600000;
            break;
        }
    }
    [self setBitrate:_bitrate];
}

- (void)setFps:(int32_t)fps{
    _fps = fps;
}


- (CGFloat)fpsCapture {
    return _rtmpStreamer.fps_capturer;
}

- (UIView *)previewWithFrame:(CGRect)frame contentMode:(UIViewContentMode)mode {
    _previewContentMode = mode;
    _preview = [[UIView alloc] initWithFrame:frame];
    _preview.frame = frame;
    
    //记录preview的UI方向，如果UI方向和拍摄方向不一致时候，拍摄画面需要旋转
    _previewOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    return _preview;
}

- (void)previewRemoveGpuImageView {
    for (UIView *view in _preview.subviews) {
        if ([view isKindOfClass:[GPUImageView class]]) {
            [view removeFromSuperview];
        }
    }
}

- (void)start {
    [self.videoCamera stopCameraCapture];
    self.rtmpStreamer.audioOnly = self.audioOnly;
    [self gpuImageCameraSetup];
    [self.videoCamera startCameraCapture];
    [_audioUnitRecorder start];
    self.capturerStatus = UPAVCapturerStatusLiving;
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)stop {
    [self.videoCamera stopCameraCapture];
    [self previewRemoveGpuImageView];
    [_audioUnitRecorder stop];
    self.capturerStatus = UPAVCapturerStatusStopped;
    [_rtmpStreamer stop];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)dealloc {
    [self removeNotifications];
    NSString *message = [NSString stringWithFormat:@"dealloc %@", self];
    if (UPAVCapturerDebugOn) {
        NSLog(@"%@",message);
    }
}


- (void)setCamaraTorchOn:(BOOL)camaraTorchOn {
    _camaraTorchOn = camaraTorchOn;
    AVCaptureTorchMode torchMode = AVCaptureTorchModeOff;
    if (camaraTorchOn) {
        torchMode = AVCaptureTorchModeOn;
    }
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: torchMode];
        [device unlockForConfiguration];
    }
}

- (void)setBitrate:(int64_t)bitrate {
    _bitrate = bitrate < 0 ? 600000 :bitrate;
    _rtmpStreamer.bitrate = _bitrate;
}

- (int64_t)bitrate {
    return _bitrate;
}


- (void)setViewZoomScale:(CGFloat)viewZoomScale {
    if (self.videoCamera && self.videoCamera.inputCamera) {
        AVCaptureDevice *device = (AVCaptureDevice *)self.videoCamera.inputCamera;
        if ([device lockForConfiguration:nil]) {
            device.videoZoomFactor = viewZoomScale;
            [device unlockForConfiguration];
            _viewZoomScale = viewZoomScale;
        }
    }
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
        default:
            break;
    }
}

#pragma mark UPAudioUnitKitProtocol

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
    if (!_backGroundFrameSendloopOn) {
        _backGroundFrameSendloopOn = YES;
    } else {
        return;
    }
    [self backGroundFrameSendLoopStart:loopid];
}

- (void)backGroundFrameSendLoopStart:(int)loopid {
    if (_backGroundFrameSendloopid != loopid) {
        return;
    }
    double delayInSeconds = 1.0 / self.fps;
    __weak UPAVCapturer *weakself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_rtmpStreamer pushPixelBuffer:_backGroundPixBuffer];
        [weakself backGroundFrameSendLoopStart:loopid];
    });
}

#pragma mark output audio/video buffer
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



#pragma mark--点击对焦

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    } return nil;
}

-(void)cameraViewTapAction:(UITapGestureRecognizer *)tgr {
    if (tgr.state == UIGestureRecognizerStateRecognized
        && (_focusLayer == NO || _focusLayer.hidden)) {
        CGPoint location = [tgr locationInView:_preview];
        [self setfocusImage];
        [self layerAnimationWithPoint:location];
        AVCaptureDevice *device = [self getCameraDeviceWithPosition:self.camaraPosition];
        CGPoint pointOfInterest = CGPointMake(0.5f, 0.5f);
        CGSize frameSize = _preview.frame.size;
        
        if (self.camaraPosition == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
        }
        
        pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        
        if ([device isFocusPointOfInterestSupported]
            && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                
                [device setFocusPointOfInterest:pointOfInterest];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                
                if([device isExposurePointOfInterestSupported]
                   && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    
                    [device setExposurePointOfInterest:pointOfInterest];
                    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                }
                [device unlockForConfiguration];
            } else {
                NSLog(@"ERROR = %@", error);
            }
        }
    }
}

- (void)setfocusImage {
    UIImage *focusImage = [UIImage imageNamed:@"focus"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, focusImage.size.width, focusImage.size.height)];
    imageView.image = focusImage;
    CALayer *layer = imageView.layer;
    layer.hidden = YES;
    _focusLayer = layer;
    [_preview.layer addSublayer:layer];
}

- (void)layerAnimationWithPoint:(CGPoint)point {
    if (_focusLayer) {
        CALayer *focusLayer = _focusLayer;
        focusLayer.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [focusLayer setPosition:point];
        focusLayer.transform = CATransform3DMakeScale(2.0f,2.0f,1.0f);
        [CATransaction commit];
        
        
        CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath: @"transform" ];
        animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(1.0f,1.0f,1.0f)];
        animation.delegate = self;
        animation.duration = 0.3f;
        animation.repeatCount = 1;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [focusLayer addAnimation: animation forKey:@"animation"];
        
        // 0.5秒钟延时
        [self performSelector:@selector(focusLayerNormal) withObject:self afterDelay:0.5f];
    }
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [_focusLayer removeFromSuperlayer];
    
}

- (void)focusLayerNormal {
    _preview.userInteractionEnabled = YES;
    _focusLayer.hidden = YES;
}

- (void)preViewAddTapGesture {
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [_preview addGestureRecognizer:singleFingerOne];
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
