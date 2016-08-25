//
//  UPVideoSource.m
//  UPLiveSDKDemo
//
//  Created by 林港 on 16/8/15.
//  Copyright © 2016年 upyun.com. All rights reserved.
//

#import "UPVideoCapture.h"

#import "GPUImageFramebuffer.h"
#import "LFGPUImageBeautyFilter.h"


#import "UPCustonFilters.h"
#import "GPUImageBeautifyFilter.h"


@interface UPVideoCapture() {
    
    //videoCapture
    AVCaptureSession *_captureSession;
    AVCaptureDevicePosition _camaraPosition;

    
    NSError *_capturerError;
    
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

@property (nonatomic, copy) NSString *sessionPreset;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
//@property (nonatomic, strong) LFGPUImageBeautyFilter *beautifyFilter;
@property (nonatomic, strong) GPUImageBeautifyFilter *beautifyFilter;

@property (nonatomic, strong) GPUImageCropFilter *cropfilter;
@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImageUIElement *uielement;

@property (nonatomic, strong) NSMutableArray *filtersArray;

@end


@implementation UPVideoCapture


- (id)init {
    self = [super init];
    if (self) {
        _filtersArray = [NSMutableArray array];
        _camaraPosition = AVCaptureDevicePositionBack;
        _videoOrientation = AVCaptureVideoOrientationPortrait;
        self.capturerPresetLevel = UPAVCapturerPreset_640x480;
        _capturerPresetLevelFrameCropRect = CGRectZero;
        _fps = 24;
        _viewZoomScale = 1;
        _filterOn = NO;
        
    }
    return self;
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
    
    // 设置美颜滤镜
    [_beautifyFilter removeAllTargets];
    [_cropfilter removeAllTargets];
    [_videoCamera removeAllTargets];
    [_uielement removeAllTargets];
    
//    _beautifyFilter = [[LFGPUImageBeautyFilter alloc] init];
//    _beautifyFilter.beautyLevel = 0.5;
    
    _beautifyFilter = [[GPUImageBeautifyFilter alloc] init];

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
        
        GPUImageOutput<GPUImageInput> *lastFilter = _beautifyFilter;
        
        for (GPUImageOutput<GPUImageInput> *cusFilter in _filtersArray) {
            [lastFilter addTarget:cusFilter];
            lastFilter = cusFilter;
        }

        [lastFilter addTarget:blendFilter];
        [_uielement addTarget:blendFilter];
        [blendFilter addTarget:_gpuImageView];
        __weak GPUImageUIElement *weakUielement = _uielement;
        [_beautifyFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *outPut, CMTime time) {
            label.text = [NSString stringWithFormat:@"%@", [NSDate date]];
            [weakUielement update];
        }];
        finalOutput = blendFilter;
        
    } else {
        
        GPUImageOutput<GPUImageInput> *lastFilter = _beautifyFilter;
        
        for (GPUImageOutput<GPUImageInput> *cusFilter in _filtersArray) {
            [lastFilter addTarget:cusFilter];
            lastFilter = cusFilter;
        }
        
        [lastFilter addTarget:nFilter];
        [nFilter addTarget:_gpuImageView];
        finalOutput = nFilter;
    }
    
    if (!self.filterOn) {
        _beautifyFilter.level = 0.4;
//        _beautifyFilter.beautyLevel = 0;
    }
    
    __weak typeof(self) weakself = self;
    //设置视频结果回调
    [finalOutput setFrameProcessingCompletionBlock:^(GPUImageOutput *outPut, CMTime time) {
        GPUImageFramebuffer *imageFramebuffer = outPut.framebufferForOutput;
        CVPixelBufferRef pixelBuffer = [imageFramebuffer pixelBuffer];
        if (weakself.delegate) {
            [weakself.delegate didCapturePixelBuffer:pixelBuffer];
        }
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

- (void)setCamaraPosition:(AVCaptureDevicePosition)camaraPosition {
    if (AVCaptureDevicePositionUnspecified == camaraPosition) {
        return;
    }
    if (_camaraPosition == camaraPosition) {
        return;
    }
    _camaraPosition = camaraPosition;
    
    [self.videoCamera stopCameraCapture];
    [self gpuImageCameraSetup];
    [self.videoCamera startCameraCapture];
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
            break;
        }
        case UPAVCapturerPreset_640x480:{
            _sessionPreset = AVCaptureSessionPreset640x480;
            break;
        }
        case UPAVCapturerPreset_1280x720:{
            _sessionPreset = AVCaptureSessionPreset1280x720;
            break;
        }
        default:{
            _sessionPreset = AVCaptureSessionPreset640x480;
            break;
        }
    }
}

- (void)setFps:(int32_t)fps{
    _fps = fps;
    if (_videoCamera) {
        _videoCamera.frameRate = fps;
    }
}

- (void)setFilterOn:(BOOL)filterOn {
    _filterOn = filterOn;
    CGFloat aa = _beautifyFilter.level+0.1;
    _beautifyFilter.level = aa;
}

- (UIView *)previewWithFrame:(CGRect)frame contentMode:(UIViewContentMode)mode {
    _previewContentMode = mode;
    _preview = [[UIView alloc] initWithFrame:frame];
    _preview.frame = frame;
    
    //记录preview的UI方向，如果UI方向和拍摄方向不一致时候，拍摄画面需要旋转
    _previewOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    [self preViewAddTapGesture];
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
    [self gpuImageCameraSetup];
    [self.videoCamera startCameraCapture];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)stop {
    [self.videoCamera stopCameraCapture];
    [self previewRemoveGpuImageView];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)restart {
    [self.videoCamera stopCameraCapture];
    [self gpuImageCameraSetup];
    [self.videoCamera startCameraCapture];
}

- (void)dealloc {
    
}


- (void)setCamaraTorchOn:(BOOL)camaraTorchOn {
    _camaraTorchOn = camaraTorchOn;
    AVCaptureTorchMode torchMode = camaraTorchOn ? AVCaptureTorchModeOn:AVCaptureTorchModeOff;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setTorchMode: torchMode];
        [device unlockForConfiguration];
    }
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

#pragma mark-- filter 滤镜


- (void)setFilter:(GPUImageOutput<GPUImageInput> *)filter {
    [_filtersArray removeAllObjects];
    [_filtersArray addObject:filter];
}

- (void)setFilterName:(UPCustomFilter)filterName {
    [_filtersArray removeAllObjects];
    [self addFilterName:filterName];
}

- (void)setFilters:(NSArray *)filters {
    [_filtersArray removeAllObjects];
    _filtersArray = [filters mutableCopy];
}

- (void)setFilterNames:(NSArray *)filterNames {
    [_filtersArray removeAllObjects];
    for (NSString *filterName in filterNames) {
        UPCustomFilter name = filterName.integerValue;
        [self addFilterName:name];
    }
}


- (void)addFilterName:(UPCustomFilter)filterName {
    
    
    GPUImageOutput<GPUImageInput> *filter = nil;
    
    switch (filterName) {
        case UPCustomFilter1977:{
            filter = [[FW1977Filter alloc] init];
            break;
        }
        case UPCustomFilterHefe:{
            filter = [[FWHefeFilter alloc] init];
            break;
        }
        case UPCustomFilterRise:{
            filter = [[FWRiseFilter alloc] init];
            break;
        }
        case UPCustomFilterSutro:{
            filter = [[FWSutroFilter alloc] init];
            break;
        }
        case UPCustomFilterHudson:{
            filter = [[FWHudsonFilter alloc] init];
            break;
        }
        case UPCustomFilterLomofi:{
            filter = [[FWLomofiFilter alloc] init];
            break;
        }
        case UPCustomFilterSierra:{
            filter = [[FWSierraFilter alloc] init];
            break;
        }
        case UPCustomFilterSketch:{
            filter = [[GPUImageSketchFilter alloc] init];
            break;
        }
        case UPCustomFilterWalden:{
            filter = [[FWWaldenFilter alloc] init];
            break;
        }
        case UPCustomFilterXproII:{
            filter = [[FWXproIIFilter alloc] init];
            break;
        }
        case UPCustomFilterBrannan:{
            filter = [[FWBrannanFilter alloc] init];
            break;
        }
        case UPCustomFilterInkwell:{
            filter = [[FWInkwellFilter alloc] init];
            break;
        }
        case UPCustomFilterToaster:{
            filter = [[FWToasterFilter alloc] init];
            break;
        }
        case UPCustomFilterAmatorka:{
            filter = [[GPUImageAmatorkaFilter alloc] init];
            break;
        }
        case UPCustomFilterValencia:{
            filter = [[FWValenciaFilter alloc] init];
            break;
        }
        case UPCustomFilterEarlybird:{
            filter = [[FWEarlybirdFilter alloc] init];
            break;
        }
        case UPCustomFilterNashville:{
            filter = [[FWNashvilleFilter alloc] init];
            break;
        }
        case UPCustomFilterLordKelvin:{
            filter = [[FWLordKelvinFilter alloc] init];
            break;
        }
        case UPCustomFilterMissEtikate:{
            filter = [[GPUImageMissEtikateFilter alloc] init];
            break;
        }
        case UPCustomFilterSoftElegance:{
            filter = [[GPUImageSoftEleganceFilter alloc] init];
            break;
        }
    }
    
    if (![_filtersArray containsObject:filter] && filter) {
        [_filtersArray addObject:filter];
    } else {
        NSLog(@"filter ==nil or filterNamerange error ==%ld", (long)filterName);
    }
}

#pragma mark-- 点击自动对焦

- (void)cameraViewTapAction:(UITapGestureRecognizer *)tgr {
    if (tgr.state == UIGestureRecognizerStateRecognized
        && (_focusLayer == NO || _focusLayer.hidden)) {
    CGPoint location = [tgr locationInView:_preview];
    [self setfocusImage];
    [self layerAnimationWithPoint:location];
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:self.camaraPosition];
    
    CGSize frameSize = _preview.frame.size;
    
    if (self.camaraPosition == AVCaptureDevicePositionFront) {
        location.x = frameSize.width - location.x;
    }
    
    CGPoint pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
    
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
    
    if (_focusLayer) {
        _focusLayer.hidden = YES;
        [_preview.layer addSublayer:_focusLayer];
        return;
    }
    
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
/// 增加点击对焦事件
- (void)preViewAddTapGesture {
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [_preview addGestureRecognizer:singleFingerOne];
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    } return nil;
}
@end
