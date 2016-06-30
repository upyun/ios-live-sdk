//
//  Demo2ViewController.m
//  SFFmpegIOSStreamer
//
//  Created by DING FENG on 4/12/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "DemoViewControllerStreamer2.h"
#import <UPLiveSDK/UPAVCapturer.h>

@interface DemoViewControllerStreamer2 () {
    UIButton *_startBtn;
    UIButton *_bitrateBtn;
    UIButton *_camaraBtn;
    UIButton *_flashBtn;
    UIButton *_dismissBtn;
    UIButton *_streamingBtn;
    UIButton *_beautifyBtn;
    
    
    UIView *_preview;

}

@end

@implementation DemoViewControllerStreamer2

- (void)viewDidLoad {
    [UPLiveSDKConfig setLogLevel:UP_Level_debug];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //rtmp 推流地址
    NSString *rtmpPushUrl = @"rtmp://testlivesdk.v0.upaiyun.com/live/streamhz1";
    
    //计算 upToken
    NSString *upToken = [UPAVCapturer tokenWithKey:@"password"
                                            bucket:@"testlivesdk"
                                        expiration:86400
                                   applicationName:@"live"
                                        streamName:@"streamhz"];
    
    rtmpPushUrl = [NSString stringWithFormat:@"%@?_upt=%@", rtmpPushUrl, upToken];
    NSLog(@"rtmpPushUrl: %@", rtmpPushUrl);
    
    //rtmp 播放地址
    NSString *rtmpPlayUrl = @"rtmp://testlivesdk.b0.upaiyun.com/live/streamhz1";
    //浏览器测试播放地址
    NSString *webPlayUrl = @"http://test86400.b0.upaiyun.com/player/demo1/srs_player.html?vhost=testlivesdk.b0.upaiyun.com&app=live&stream=streamhz1&server=testlivesdk.b0.upaiyun.com&port=1935&autostart=true";
    
    //设置推流地址
    [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
    
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(40, 20, 1500, 130)];
    label.text = [NSString stringWithFormat:@"rtmpPushUrl:\n%@\n\nrtmpPlayUrl:\n%@\n\nwebPlayUrl:\n%@\n", rtmpPushUrl,rtmpPlayUrl,webPlayUrl];
    label.editable = NO;
    [self.view addSubview:label];
    
    //设置推流状态回调
    __weak DemoViewControllerStreamer2 *weakself = self;
    [UPAVCapturer sharedInstance].uPAVCapturerStatusBlock = ^(UPAVCapturerStatus status, NSError *error) {
        if (error) {
            //非主线程
            NSString *s = [NSString stringWithFormat:@"%@", error];
            [weakself errorAlert:s];
        }
    };
    
    
    
    
    
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 4.;
    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 180, width, width)];
    [_startBtn setTitle:@"start" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _bitrateBtn = [[UIButton alloc] initWithFrame:CGRectMake(width, self.view.frame.size.height - 180, width, width)];
    [_bitrateBtn setTitle:@"bitrate - 100000" forState:UIControlStateNormal];
    [_bitrateBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_bitrateBtn addTarget:self action:@selector(bitrate:) forControlEvents:UIControlEventTouchUpInside];
    
    _camaraBtn = [[UIButton alloc] initWithFrame:CGRectMake(width * 2, self.view.frame.size.height - 180, width, width)];
    [_camaraBtn setTitle:@"   camera switch" forState:UIControlStateNormal];
    [_camaraBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_camaraBtn addTarget:self action:@selector(camera:) forControlEvents:UIControlEventTouchUpInside];
    
    _flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(width * 3, self.view.frame.size.height - 180, width, width)];
    [_flashBtn setTitle:@"    flash on/off" forState:UIControlStateNormal];
    [_flashBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_flashBtn addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    _streamingBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, width, width)];
    [_streamingBtn setTitle:@"streaming on/off" forState:UIControlStateNormal];
    [_streamingBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_streamingBtn addTarget:self action:@selector(streamingBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _beautifyBtn = [[UIButton alloc] initWithFrame:CGRectMake(width, self.view.frame.size.height - 100, width, width)];
    [_beautifyBtn setTitle:@" beautify on/off" forState:UIControlStateNormal];
    [_beautifyBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_beautifyBtn addTarget:self action:@selector(beautifyBtn:) forControlEvents:UIControlEventTouchUpInside];

    
    _startBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    _bitrateBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    _camaraBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    _flashBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    _streamingBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    _beautifyBtn.titleLabel.adjustsFontSizeToFitWidth = TRUE;
    [self setPreview];

    
    [self.view addSubview:_startBtn];
    [self.view addSubview:_bitrateBtn];
    [self.view addSubview:_camaraBtn];
    [self.view addSubview:_flashBtn];
    [self.view addSubview:_streamingBtn];
    [self.view addSubview:_beautifyBtn];


}

- (void)errorAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"推流错误，请检查网络重试，或者更换一个流id后重试"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)startBtn:(UIButton *)sender {
    
    if (sender.tag == 0) {
        [[UPAVCapturer sharedInstance] start];
        [sender setTitle:@"stop" forState:UIControlStateNormal];
        sender.tag = 1;
    } else {
        [[UPAVCapturer sharedInstance] stop];
        [sender setTitle:@"start" forState:UIControlStateNormal];
        sender.tag = 0;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//比特率测试 bitrate［100000 600000］；默认值600000
int64_t bitrate = 600000;
- (void)bitrate:(UIButton *)sender {
    bitrate = bitrate - 100000;
    
    NSLog(@"bitrate %lld", bitrate);
    [UPAVCapturer sharedInstance].bitrate = bitrate;
}

//前后镜头切换
- (void)camera:(UIButton *)sender {
    
    if ([UPAVCapturer sharedInstance].camaraPosition == AVCaptureDevicePositionBack) {
        [UPAVCapturer sharedInstance].camaraPosition = AVCaptureDevicePositionFront;
    } else {
        [UPAVCapturer sharedInstance].camaraPosition = AVCaptureDevicePositionBack;
    }
}

//闪光灯开关
- (void)flash:(UIButton *)sender {
    [UPAVCapturer sharedInstance].camaraTorchOn = ![UPAVCapturer sharedInstance].camaraTorchOn;
}

//推流开关
- (void)streamingBtn:(UIButton *)sender {
    [UPAVCapturer sharedInstance].streamingOn = ![UPAVCapturer sharedInstance].streamingOn;
}

//美颜开关
- (void)beautifyBtn:(UIButton *)sender {
    [UPAVCapturer sharedInstance].filterOn = ![UPAVCapturer sharedInstance].filterOn;
}



//设置视频预览画面
- (void)setPreview {
    
    
    //获取和设置视频预览视图 videoPreview
    UIViewContentMode previewContentMode = UIViewContentModeScaleAspectFit;
    CGFloat videoPreviewWidth = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    CGFloat videoPreviewHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    _preview= [[UPAVCapturer sharedInstance] previewWithFrame:CGRectMake(0, 0, videoPreviewWidth, videoPreviewHeight) contentMode:previewContentMode];
    _preview.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_preview];

    
    
    
//    [_previewLayer removeFromSuperlayer];
//    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[UPAVCapturer sharedInstance].captureSession];
//    _previewLayer.frame = CGRectMake(0, 140, self.view.frame.size.width, self.view.frame.size.width);
//    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.view.layer addSublayer:_previewLayer];
}


- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

@end