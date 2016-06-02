//
//  UPLiveStreamerLivingVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLiveStreamerLivingVC.h"
#import <UPLiveSDK/UPAVCapturer.h>

@interface UPLiveStreamerLivingVC ()
{
    AVCaptureVideoPreviewLayer *_previewLayer;
}
@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *streamingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *flashSwitch;
@property (weak, nonatomic) IBOutlet UIView *panel;
@property (nonatomic, strong) UIView *videoPreview;
@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation UPLiveStreamerLivingVC

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    //获取和设置视频预览视图 videoPreview
    UIViewContentMode previewContentMode = UIViewContentModeScaleAspectFit;
    if (_settings.fullScreenPreviewOn) {
        previewContentMode = UIViewContentModeScaleAspectFill;
    }
    CGFloat videoPreviewWidth = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    CGFloat videoPreviewHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    self.videoPreview = [[UPAVCapturer sharedInstance] previewWithFrame:CGRectMake(0, 0, videoPreviewWidth, videoPreviewHeight) contentMode:previewContentMode];
    self.videoPreview.backgroundColor = [UIColor blackColor];
    
    //将预览视图初始化旋转到 Portrait 位置，且固定在 Portrait 位置效果类似系统自带 camera app）
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
        self.videoPreview.transform = CGAffineTransformMakeRotation(0);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            self.videoPreview.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case UIDeviceOrientationLandscapeLeft:
            self.videoPreview.transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIDeviceOrientationLandscapeRight:
            self.videoPreview.transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        default:
            break;
    }
    
    //横屏拍摄竖屏拍摄提示 label
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.descriptionLabel.textColor = [UIColor lightGrayColor];
    switch (_settings.videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            self.descriptionLabel.text = @"竖屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation(0);
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            self.descriptionLabel.text = @"竖屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            self.descriptionLabel.text = @"横屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation( M_PI_2);
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            self.descriptionLabel.text = @"横屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation(- M_PI_2);
            break;
        default:
            break;
    }

    [self.videoPreview  addSubview:self.descriptionLabel];
    [self.view insertSubview:self.videoPreview atIndex:0];
    
    //开启 debug 信息
    [UPAVCapturer setLogLevel:UPAVCapturerLogger_level_debug];
    
    //直播推流状态回调
    __weak UPLiveStreamerLivingVC *weakself = self;
    [UPAVCapturer sharedInstance].uPAVCapturerStatusBlock = ^(UPAVCapturerStatus status, NSError *error) {
        if (error) {
            NSString *s = [NSString stringWithFormat:@"%@", error];
            [weakself errorAlert:s];
        }
    };
}

- (void)viewWillAppear:(BOOL)animated {
    self.filterSwitch.on = _settings.filter;
    self.streamingSwitch.on = _settings.streamingOnOff;
    self.flashSwitch.on = _settings.camaraTorchOn;
}

- (void)viewDidAppear:(BOOL)animated {
    [self start];
}

- (void)start {
    [[UPAVCapturer sharedInstance] stop];
    [UPAVCapturer sharedInstance].capturerPresetLevel = _settings.level;
    [UPAVCapturer sharedInstance].camaraPosition = _settings.camaraPosition;
    [UPAVCapturer sharedInstance].streamingOnOff = _settings.streamingOnOff;
    [UPAVCapturer sharedInstance].filter = _settings.filter;
    [UPAVCapturer sharedInstance].filterLevel = _settings.filterLevel ;
    [UPAVCapturer sharedInstance].camaraTorchOn = _settings.camaraTorchOn;
    [UPAVCapturer sharedInstance].videoOrientation = _settings.videoOrientation;
    [UPAVCapturer sharedInstance].fps = _settings.fps;

    //推流地址
    NSString *rtmpPushUrl = [NSString stringWithFormat:@"%@%@", _settings.rtmpServerPushPath, _settings.streamId];
    
    //计算 upToken
    NSString *upToken = [UPAVCapturer tokenWithKey:@"password"
                                            bucket:@"testlivesdk"
                                        expiration:86400
                                   applicationName:@"live"
                                        streamName:@"streamhz"];
    
    rtmpPushUrl = [NSString stringWithFormat:@"%@?_upt=%@", rtmpPushUrl, upToken];
    NSLog(@"rtmpPushUrl: %@", rtmpPushUrl);
    [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
    [[UPAVCapturer sharedInstance] start];
}


- (IBAction)streamingSwitch:(id)sender {
    [UPAVCapturer sharedInstance].streamingOnOff = ![UPAVCapturer sharedInstance].streamingOnOff;
}

- (IBAction)filterSwitch:(id)sender {
    [UPAVCapturer sharedInstance].filter = ![UPAVCapturer sharedInstance].filter;
}

- (IBAction)flashSwitch:(id)sender {
    
    [UPAVCapturer sharedInstance].camaraTorchOn = ![UPAVCapturer sharedInstance].camaraTorchOn ;
}

- (IBAction)stop:(id)sender {
    [[UPAVCapturer sharedInstance] stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)errorAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"推流错误，请检查网络重试，或者更换一个流id后重试"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

//将预览视图固定到 Portrait， 位置效果类似系统自带 camera app）https://developer.apple.com/library/ios/qa/qa1890/_index.html
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.videoPreview.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        CGAffineTransform deltaTransform = coordinator.targetTransform;
        CGFloat deltaAngle = atan2f(deltaTransform.b, deltaTransform.a);
        
        CGFloat currentRotation = [[self.videoPreview.layer valueForKeyPath:@"transform.rotation.z"] floatValue];
        // Adding a small value to the rotation angle forces the animation to occur in a the desired direction, preventing an issue where the view would appear to rotate 2PI radians during a rotation from LandscapeRight -> LandscapeLeft.
        currentRotation += -1 * deltaAngle + 0.0001;
        [self.videoPreview.layer setValue:@(currentRotation) forKeyPath:@"transform.rotation.z"];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Integralize the transform to undo the extra 0.0001 added to the rotation angle.
        CGAffineTransform currentTransform = self.videoPreview.transform;
        currentTransform.a = round(currentTransform.a);
        currentTransform.b = round(currentTransform.b);
        currentTransform.c = round(currentTransform.c);
        currentTransform.d = round(currentTransform.d);
        self.videoPreview.transform = currentTransform;
    }];
}

@end
