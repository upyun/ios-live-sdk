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
    AVCaptureVideoPreviewLayer *_previewLayer;
    UIButton *_startBtn;
    UIButton *_bitrateBtn;
    UIButton *_camaraBtn;
    UIButton *_flashBtn;
    UIButton *_dismissBtn;
}

@end

@implementation DemoViewControllerStreamer2

- (void)viewDidLoad {
    [UPAVCapturer setLogLevel:UPAVCapturerLogger_level_debug];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 100, 100, 100)];
    [_startBtn setTitle:@"start" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    _bitrateBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, self.view.frame.size.height - 100, 100, 100)];
    [_bitrateBtn setTitle:@"bitrate" forState:UIControlStateNormal];
    [_bitrateBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_bitrateBtn addTarget:self action:@selector(bitrate:) forControlEvents:UIControlEventTouchUpInside];
    
    _camaraBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, self.view.frame.size.height - 100, 100, 100)];
    [_camaraBtn setTitle:@"camera" forState:UIControlStateNormal];
    [_camaraBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_camaraBtn addTarget:self action:@selector(camera:) forControlEvents:UIControlEventTouchUpInside];

    _flashBtn = [[UIButton alloc] initWithFrame:CGRectMake(300, self.view.frame.size.height - 100, 100, 100)];
    [_flashBtn setTitle:@"flash" forState:UIControlStateNormal];
    [_flashBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_flashBtn addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_startBtn];
    [self.view addSubview:_bitrateBtn];
    [self.view addSubview:_camaraBtn];
    [self.view addSubview:_flashBtn];

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
    
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(40, 20, 1500, 200)];
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
        [self setPreview];
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
    [UPAVCapturer sharedInstance].bitrate = bitrate;
}

//前后镜头切换
- (void)camera:(UIButton *)sender {
    [[UPAVCapturer sharedInstance] changeCamera];
}

//闪光灯开关
- (void)flash:(UIButton *)sender {
    [UPAVCapturer sharedInstance].camaraTorchOn = ![UPAVCapturer sharedInstance].camaraTorchOn;
}

//设置视频预览画面
- (void)setPreview {
    [_previewLayer removeFromSuperlayer];
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[UPAVCapturer sharedInstance].captureSession];
    _previewLayer.frame = CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.width);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

@end
