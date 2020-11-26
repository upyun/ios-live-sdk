//
//  UPLiveStreamerLivingVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLiveStreamerLivingVC.h"
#import "UPAVCapturer.h"
#import "AppDelegate.h"
#import <UPLiveSDKDll/UPLiveSDKConfig.h>
#import <UPLiveSDKDll/UPAVPlayer.h>


@interface UPLiveStreamerLivingVC () <UPAVCapturerDelegate>
{
    NSString *_videoOrientationDescription;
    NSString *_pushStreamStadusDescription;
    UPAVPlayer *_bgmPlayer;

}
@property (weak, nonatomic) IBOutlet UISwitch *mixerSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *beauytifySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *cameraSwitch;
@property (weak, nonatomic) IBOutlet UIView *panel;
@property (weak, nonatomic) IBOutlet UITextView *dashboard;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, assign) CGFloat lastScale;
@property (nonatomic, assign) NSInteger filterCode;
@property (nonatomic, strong) UIView *videoPreview;  //本地预览视图
@property (nonatomic, strong) UIView *rtcRemoteView0;//连麦远程视图0
@property (nonatomic, strong) UIView *rtcRemoteView1;//连麦远程视图1


@end

@implementation UPLiveStreamerLivingVC

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    //设置视频预览视图 videoPreview
    UIViewContentMode previewContentMode = UIViewContentModeScaleAspectFit;
    if (_settings.fullScreenPreviewOn) {
        previewContentMode = UIViewContentModeScaleAspectFill;
    }
    
    
    
    float w = [UIScreen mainScreen].bounds.size.width;
    float h = [UIScreen mainScreen].bounds.size.height;
    
    if (_settings.videoOrientation != AVCaptureVideoOrientationPortrait) {
        //横屏拍摄时候，宽是长边
        w = MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        h = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

    }
    self.videoPreview = [[UPAVCapturer sharedInstance] previewWithFrame:CGRectMake(0, 0, w, h)
                                                            contentMode:previewContentMode];
    
    self.videoPreview.backgroundColor = [UIColor blackColor];
    
    //横竖屏拍摄提示 label
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 200, 44)];
    self.descriptionLabel.backgroundColor = [UIColor blackColor];
    self.descriptionLabel.alpha = 0.5;
    self.descriptionLabel.textColor = [UIColor whiteColor];
    
    switch (_settings.videoOrientation) {
        case AVCaptureVideoOrientationPortrait:
            _videoOrientationDescription = @"竖屏拍摄";
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            _videoOrientationDescription = @"竖屏拍摄";
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            _videoOrientationDescription = @"横屏拍摄";
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            _videoOrientationDescription = @"横屏拍摄";
            break;
        default:
            break;
    }
    self.descriptionLabel.text = _videoOrientationDescription;
    [self.videoPreview  addSubview:self.descriptionLabel];
    [self.view insertSubview:self.videoPreview atIndex:0];
    
    //开启 debug 信息
    [UPLiveSDKConfig setLogLevel:UP_Level_debug];
    [UPLiveSDKConfig setStatistcsOn:YES];

    //设置代理，采集状态推流信息回调
    [UPAVCapturer sharedInstance].delegate = self;
    
    //拍摄 zoom 手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                                                 action:@selector(handlePinchGesture:)];
    [self.videoPreview addGestureRecognizer:pinchGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    self.filterSwitch.on = _settings.beautifyOn;
}

- (void)viewDidAppear:(BOOL)animated {
    [self start];
//    [self beautifyLevelTest];
}

- (void)start {
    [[UPAVCapturer sharedInstance] stop];
    [UPAVCapturer sharedInstance].openDynamicBitrate = YES;
    [UPAVCapturer sharedInstance].capturerPresetLevel = _settings.level;
    [UPAVCapturer sharedInstance].camaraPosition = _settings.camaraPosition;  
    [UPAVCapturer sharedInstance].camaraTorchOn = _settings.camaraTorchOn;
    [UPAVCapturer sharedInstance].videoOrientation = _settings.videoOrientation;
    [UPAVCapturer sharedInstance].fps = _settings.fps;
    [UPAVCapturer sharedInstance].beautifyOn = _settings.beautifyOn;

    //推流地址
    NSString *rtmpPushUrl = [NSString stringWithFormat:@"%@%@", _settings.rtmpServerPushPath, _settings.streamId];
    
    rtmpPushUrl = [NSString stringWithFormat:@"%@", rtmpPushUrl];
    NSLog(@"设置推流地址: %@", rtmpPushUrl);
    [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
    
    // 要调节成 16:9 的比例, 可以自行调整要裁剪的大小
    // 注意有些尺寸不支持连麦
    switch (_settings.level) {
        case UPAVCapturerPreset_480x360:
            [UPAVCapturer sharedInstance].capturerPresetLevelFrameCropSize = CGSizeMake(360, 480);
            break;
        case UPAVCapturerPreset_640x480:
            //剪裁为 16 : 9, 注意：横屏时候需要设置为 CGSizeMake(640, 360)
            [UPAVCapturer sharedInstance].capturerPresetLevelFrameCropSize= CGSizeMake(360, 640);
            break;
        case UPAVCapturerPreset_960x540:
            [UPAVCapturer sharedInstance].capturerPresetLevelFrameCropSize = CGSizeMake(540, 960);
            break;
        case UPAVCapturerPreset_1280x720:
            [UPAVCapturer sharedInstance].capturerPresetLevelFrameCropSize = CGSizeMake(720, 1280);
            break;
    }
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    __block UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 44)];
    label.text = @"我是水印";
    label.textAlignment = NSTextAlignmentRight;

    UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(size.width - 80, 44, 80, 60)];
    imgV.image = [UIImage imageNamed:@"upyun_logo"];

    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    subView.backgroundColor = [UIColor clearColor];
    [subView addSubview:label];
    [subView addSubview:imgV];
    [[UPAVCapturer sharedInstance] setWatermarkView:subView Block:^{
        //动态变化的时间戳
        label.text = [NSString stringWithFormat:@"upyun:%@", [NSDate date]];
    }];
    
    
//    [UPAVCapturer sharedInstance].networkSateBlock = ^(UPAVStreamerNetworkState level) {
//        if (level == UPAVStreamerNetworkState_BAD) {
//            NSLog(@"网络比较差");
//        } else if (level == UPAVStreamerNetworkState_NORMAL) {
//            NSLog(@"网络一般");
//        } else {
//            NSLog(@"网络良好");
//        }
//    };
    
    [[UPAVCapturer sharedInstance] start];
    [self updateDashboard];
}

- (IBAction)rtcSwitch:(UISwitch *)sender {
    
    //连麦小视图视频分辨率是：320 ＊ 240
    CGFloat w = 240 / 2.;
    CGFloat h = 320 / 2.;
    
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.width);
    NSLog(@"%f", [UIScreen mainScreen].bounds.size.height);
    CGRect frame0 = CGRectMake([UIScreen mainScreen].bounds.size.width - w - 10, 10, w, h);
    CGRect frame1 = CGRectMake([UIScreen mainScreen].bounds.size.width - w - 10, 10 + h, w, h);

    [[UPAVCapturer sharedInstance] rtcInitWithAppId:@"6b1f80e7ea8b1752424f85329a4faff5900d"];
    [[UPAVCapturer sharedInstance] rtcSetViewMode:0];//主播模式连麦

    self.rtcRemoteView0 = [[UPAVCapturer sharedInstance] rtcRemoteView0WithFrame:frame0];//显示第一个连麦嘉宾画面
    self.rtcRemoteView1 = [[UPAVCapturer sharedInstance] rtcRemoteView1WithFrame:frame1];//显示第二个连麦嘉宾画面
    
    [self.videoPreview addSubview:self.rtcRemoteView0];
    [self.videoPreview addSubview:self.rtcRemoteView1];
    self.rtcRemoteView0.hidden = NO;//连麦开始，第一个小视图默认显示。
    self.rtcRemoteView1.hidden = YES;//连麦开始，第二个小视图默认隐藏。后面随着新 uid 进入房间而动态显示。

    if (sender.on) {
        //设置连麦房间号与推流id一致，方便播放客户端进行连麦
        NSString *rtcChannelId = _settings.streamId;
        int ret = [[UPAVCapturer sharedInstance] rtcConnect:rtcChannelId];
        
        if (ret == -2) {
            [self errorAlert:@"连麦错误：请检查 appID 及 采集视频尺寸"];
        }
    } else {
        [[UPAVCapturer sharedInstance] rtcClose];
        //清理远程视图
        [self.rtcRemoteView0 removeFromSuperview];
        [self.rtcRemoteView1 removeFromSuperview];
    }
}

- (IBAction)filterSwitch:(id)sender {
    if (_filterCode > UPCustomFilterHefe) {
        [[UPAVCapturer sharedInstance] setFilter:nil];
        _filterCode = -1;
    } else {
        [[UPAVCapturer sharedInstance] setFilterName:_filterCode];
    }
    _filterCode ++;
}

- (IBAction)mixerSwitch:(UISwitch *)sender {
    
    [UPAVCapturer sharedInstance].backgroudMusicUrl = @"http://test86400.b0.upaiyun.com/music32000.mp3";
    [UPAVCapturer sharedInstance].backgroudMusicOn = ![UPAVCapturer sharedInstance].backgroudMusicOn;
}

- (IBAction)beautifySwitch:(id)sender {
    [UPAVCapturer sharedInstance].beautifyOn = ![UPAVCapturer sharedInstance].beautifyOn;
}

- (IBAction)cameraSwitch:(id)sender {
    if ([UPAVCapturer sharedInstance].camaraPosition == AVCaptureDevicePositionBack) {
        [UPAVCapturer sharedInstance].camaraPosition = AVCaptureDevicePositionFront;
    } else {
        [UPAVCapturer sharedInstance].camaraPosition = AVCaptureDevicePositionBack;
    }
}

- (IBAction)stop:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[UPAVCapturer sharedInstance] stop];
    }];
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)sender {
    
    CGFloat scale = sender.scale;
    if (_lastScale == 0) {
        _lastScale = 1;
    }
    CGFloat newScale = _lastScale+scale-1;
    if (newScale >= 1 && newScale <= 3) {
        _lastScale = newScale;
        [UPAVCapturer sharedInstance].viewZoomScale = newScale;
    }
}

- (void)errorAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  [self dismissViewControllerAnimated:YES completion:^{
                                                                      [[UPAVCapturer sharedInstance] stop];
                                                                  }];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

//将预览视图固定。
//拍摄开始后镜头方向便固定了，所以预览视图也需要固定。(效果类似系统自带 camera app）https://developer.apple.com/library/ios/qa/qa1890/_index.html
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

//采集状态
- (void)capturer:(UPAVCapturer *)capturer capturerStatusDidChange:(UPAVCapturerStatus)capturerStatus {
    
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

- (void)capturer:(UPAVCapturer *)capturer capturerError:(NSError *)error {
    if (error) {
        NSString *s = [NSString stringWithFormat:@"%@", error];
        [self errorAlert:[NSString stringWithFormat:@"推流错误，请检查网络重试，或者更换一个流id后重试%@",s]];
    }
}

//推流状态
- (void)capturer:(UPAVCapturer *)capturer pushStreamStatusDidChange:(UPPushAVStreamStatus)streamStatus {
    
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


//有人进房间，动态处理三人连麦窗口
- (void)capturer:(UPAVCapturer *)capturer rtcDidJoinedOfUid:(NSUInteger)uid{
    NSLog(@"rtcDidJoinedOfUid uid %ld", uid);
    NSLog(@"rtcDidJoinedOfUid rtcRemoteView0 %ld", self.rtcRemoteView0.tag);
    NSLog(@"rtcDidJoinedOfUid rtcRemoteView1 %ld", self.rtcRemoteView1.tag);
    
    
    if (uid == self.rtcRemoteView0.tag) {
        self.rtcRemoteView0.hidden = NO;
    }
    
    if (uid == self.rtcRemoteView1.tag) {
        self.rtcRemoteView1.hidden = NO;
    }
}

//有人出房间，动态处理三人连麦窗口
- (void)capturer:(UPAVCapturer *)capturer rtcDidOfflineOfUid:(NSUInteger)uid reason:(NSUInteger)reason{
    
    NSLog(@"rtcDidOfflineOfUid uid %ld", uid);
    NSLog(@"rtcDidOfflineOfUid rtcRemoteView0 %ld", self.rtcRemoteView0.tag);
    NSLog(@"rtcDidOfflineOfUid rtcRemoteView1 %ld", self.rtcRemoteView1.tag);
    
    if (uid == self.rtcRemoteView0.tag) {
        self.rtcRemoteView0.hidden = YES;
    }
    
    if (uid == self.rtcRemoteView1.tag) {
        self.rtcRemoteView1.hidden = YES;
    }
    
    //如果对方全部退出后，将rtcRemoteView0 显示出来（黑屏），代表主播在连麦状态（等待连麦）
    if (self.rtcRemoteView0.hidden && self.rtcRemoteView1.hidden) {
        self.rtcRemoteView0.hidden = NO;
    }
}



- (void)updateDashboard{
    self.dashboard.text = [NSString stringWithFormat:@"%@", [UPAVCapturer sharedInstance].dashboard];
    self.dashboard.textColor = [UIColor redColor];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    __weak UPLiveStreamerLivingVC *weakself = self;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [weakself updateDashboard];
    });
}

- (void)dealloc {
//    NSLog(@"dealloc %@", self);
}



#pragma mark 测试

- (void)beautifyLevelTest{
    UIView *testPanle = [[UIView alloc] initWithFrame:CGRectMake(200, 100, 200, 400)];
    testPanle.backgroundColor = [UIColor colorWithRed:0./255 green:0./255 blue:0./255 alpha:0.1];
    
    
    for (int index = 0; index < 4; index ++) {
        UIStepper *Stepper = [[UIStepper alloc] init];
        Stepper.tag = index;
        
        switch (Stepper.tag) {
            case 0:
                Stepper.value = 0.6; Stepper.minimumValue = 0;  Stepper.maximumValue = 100; Stepper.stepValue = 0.1;
                break;
            case 1:
                Stepper.value = 4.0; Stepper.minimumValue = 0;  Stepper.maximumValue = 100; Stepper.stepValue = 1;
                break;
            case 2:
                Stepper.value = 1.1; Stepper.minimumValue = 0;  Stepper.maximumValue = 100; Stepper.stepValue = 0.1;
                break;
            case 3:
                Stepper.value = 1.1; Stepper.minimumValue = 0;  Stepper.maximumValue = 100; Stepper.stepValue = 0.1;

                break;
            default:
                break;
        }
        
        
        Stepper.center = CGPointMake(100, 60 * (index + 1));
        [testPanle addSubview:Stepper];
        [Stepper addTarget:self action:@selector(beautifyLevelTestStepperTap:) forControlEvents:UIControlEventValueChanged];
    }
    
    [self.view addSubview:testPanle];
}

- (void)beautifyLevelTestStepperTap:(UIStepper *)sender {
    /*
     /// 美颜效果。值越大效果越强。可适当调整
     @property (nonatomic, assign)CGFloat level;//默认值 0.6
     /// 磨皮, 双边模糊，平滑处理。值越小效果越强。建议保持默认值。
     @property (nonatomic, assign)CGFloat bilateralLevel;//默认值 4.0
     /// 饱和度。值越小画面越灰白，值越大色彩越强烈。可适当调整。
     @property (nonatomic, assign)CGFloat saturationLevel;//默认值 1.1
     /// 亮度。值越小画面越暗，值越大越明亮。可适当调整。
     @property (nonatomic, assign)CGFloat brightnessLevel;//默认值 1.1
     */
    
    NSLog(@"sender.tag : %ld  %f", (long)sender.tag, sender.value);
    switch (sender.tag) {
        case 0:[UPAVCapturer sharedInstance].beautifyFilter.level = sender.value;
            break;
        case 1:[UPAVCapturer sharedInstance].beautifyFilter.bilateralLevel = sender.value;
            break;
        case 2:[UPAVCapturer sharedInstance].beautifyFilter.saturationLevel = sender.value;
            break;
        case 3:[UPAVCapturer sharedInstance].beautifyFilter.brightnessLevel = sender.value;
            break;
        default:
            break;
    }
    
    NSLog(@"level %f", [UPAVCapturer sharedInstance].beautifyFilter.level);
    NSLog(@"bilateralLevel %f", [UPAVCapturer sharedInstance].beautifyFilter.bilateralLevel);
    NSLog(@"saturationLevel %f", [UPAVCapturer sharedInstance].beautifyFilter.saturationLevel);
    NSLog(@"brightnessLevel %f", [UPAVCapturer sharedInstance].beautifyFilter.brightnessLevel);
    [UPAVCapturer sharedInstance].beautifyOn = YES;
}


//横竖屏设置
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (_settings.videoOrientation == AVCaptureVideoOrientationPortrait) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (_settings.videoOrientation == AVCaptureVideoOrientationPortrait) {
        return UIInterfaceOrientationPortrait;
    } else {
        return UIInterfaceOrientationLandscapeRight;
    }
}

@end
