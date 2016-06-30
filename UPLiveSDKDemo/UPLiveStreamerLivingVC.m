//
//  UPLiveStreamerLivingVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLiveStreamerLivingVC.h"
#import <UPLiveSDK/UPAVCapturer.h>
#import "AppDelegate.h"
#import "BeautifyFilter.h"


@interface UPLiveStreamerLivingVC () <UPAVCapturerDelegate>
{
    NSString *_videoOrientationDescription;
    NSString *_pushStreamStadusDescription;
    BeautifyFilter *_fliter;
}

@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *streamingSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *flashSwitch;
@property (weak, nonatomic) IBOutlet UIView *panel;
@property (weak, nonatomic) IBOutlet UITextView *dashboard;
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
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 200, 44)];
    self.descriptionLabel.backgroundColor = [UIColor blackColor];
    self.descriptionLabel.alpha = 0.5;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    switch (_settings.videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            _videoOrientationDescription = @"竖屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation(0);
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            _videoOrientationDescription = @"竖屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            _videoOrientationDescription = @"横屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation( M_PI_2);
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            _videoOrientationDescription = @"横屏拍摄";
            self.descriptionLabel.transform = CGAffineTransformMakeRotation(- M_PI_2);
            break;
        default:
            break;
    }
    self.descriptionLabel.text = _videoOrientationDescription;
    [self.videoPreview  addSubview:self.descriptionLabel];
    [self.view insertSubview:self.videoPreview atIndex:0];
    
    //开启 debug 信息
    [UPLiveSDKConfig setLogLevel:UP_Level_error];

    
    //设置代理，采集状态推流信息回调
    [UPAVCapturer sharedInstance].delegate = self;
    
    //设置滤镜
    _fliter = [BeautifyFilter new];
    [UPAVCapturer sharedInstance].videoFiler = _fliter;
}

- (void)viewWillAppear:(BOOL)animated {
    self.filterSwitch.on = _settings.filter;
    self.streamingSwitch.on = _settings.streamingOn;
    self.flashSwitch.on = _settings.camaraTorchOn;
}

- (void)viewDidAppear:(BOOL)animated {
    [self start];
}

- (void)start {
    [[UPAVCapturer sharedInstance] stop];
    [UPAVCapturer sharedInstance].capturerPresetLevel = _settings.level;
    [UPAVCapturer sharedInstance].camaraPosition = _settings.camaraPosition;
    [UPAVCapturer sharedInstance].streamingOn = _settings.streamingOn;
    [UPAVCapturer sharedInstance].filterOn = _settings.filter;
    [UPAVCapturer sharedInstance].camaraTorchOn = _settings.camaraTorchOn;
    [UPAVCapturer sharedInstance].videoOrientation = _settings.videoOrientation;
    [UPAVCapturer sharedInstance].fps = _settings.fps;
    _fliter.level = _settings.filterLevel;
//    [UPAVCapturer sharedInstance].bitrate = 400000;

    //推流地址
    NSString *rtmpPushUrl = [NSString stringWithFormat:@"%@%@", _settings.rtmpServerPushPath, _settings.streamId];
    
    //计算 upToken
    NSString *upToken = [UPAVCapturer tokenWithKey:@"password"
                                            bucket:@"testlivesdk"
                                        expiration:86400
                                   applicationName:_settings.rtmpServerPushPath.lastPathComponent
                                        streamName:_settings.streamId];
    
    rtmpPushUrl = [NSString stringWithFormat:@"%@?_upt=%@", rtmpPushUrl, upToken];
    NSLog(@"rtmpPushUrl: %@", rtmpPushUrl);
    [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
    [[UPAVCapturer sharedInstance] start];
    [self updateDashboard];
}


- (IBAction)streamingSwitch:(id)sender {
    [UPAVCapturer sharedInstance].streamingOn = ![UPAVCapturer sharedInstance].streamingOn;
}

- (IBAction)filterSwitch:(id)sender {
    [UPAVCapturer sharedInstance].filterOn = ![UPAVCapturer sharedInstance].filterOn;
}

- (IBAction)flashSwitch:(id)sender {
    
    
    [UPAVCapturer sharedInstance].camaraTorchOn = ![UPAVCapturer sharedInstance].camaraTorchOn ;
}

- (IBAction)stop:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[UPAVCapturer sharedInstance] stop];
    }];
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


#pragma mark UPAVCapturerDelegate

//capturer status
- (void)UPAVCapturer:(UPAVCapturer *)capturer capturerStatusDidChange:(UPAVCapturerStatus)capturerStatus {
    
    switch (capturerStatus) {
        case UPAVCapturerStatusStopped: {
            NSLog(@"===UPAVCapturerStatusStopped");
        }
            break;
        case UPAVCapturerStatusLiving: {
            NSLog(@"===UPAVCapturerStatusLiving");

        }
            break;
        case UPAVCapturerStatusError: {
            NSLog(@"===UPAVCapturerStatusError");
        }
            break;
        default:
            break;
    }
}

- (void)UPAVCapturer:(UPAVCapturer *)capturer capturerError:(NSError *)error {
    if (error) {
        NSString *s = [NSString stringWithFormat:@"%@", error];
        [self errorAlert:s];
    }
}

//push stream status
- (void)UPAVCapturer:(UPAVCapturer *)capturer pushStreamStatusDidChange:(UPPushAVStreamStatus)streamStatus {
    
    switch (streamStatus) {
        case UPPushAVStreamStatusClosed:
            NSLog(@"===UPPushAVStreamStatusClosed");
            _pushStreamStadusDescription = @"连接关闭";
            break;
        case UPPushAVStreamStatusConnecting:
            NSLog(@"===UPPushAVStreamStatusConnecting");
            _pushStreamStadusDescription = @"连接中...";
            break;
        case UPPushAVStreamStatusReady:
            _pushStreamStadusDescription = @"准备直播";
            NSLog(@"===UPPushAVStreamStatusReady");

            break;
        case UPPushAVStreamStatusPushing:
            NSLog(@"===UPPushAVStreamStatusPushing");
            _pushStreamStadusDescription = @"直播中...";
            self.descriptionLabel.text = @"竖屏拍摄";

            break;
        case UPPushAVStreamStatusError: {
            _pushStreamStadusDescription = @"连接错误";
            NSLog(@"===UPPushAVStreamStatusError");
        }
            break;
        default:
            break;
    }
    self.descriptionLabel.text = [NSString stringWithFormat:@"%@%@", _videoOrientationDescription, _pushStreamStadusDescription];
}


- (void)updateDashboard{
    
    self.dashboard.text = [NSString stringWithFormat:@"%@", [UPAVCapturer sharedInstance].dashboard];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    __weak UPLiveStreamerLivingVC *weakself = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakself updateDashboard];
    });
}



@end
