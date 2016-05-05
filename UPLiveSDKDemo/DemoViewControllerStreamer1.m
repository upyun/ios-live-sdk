//
//  Demo1ViewController.m
//  SFFmpegIOSStreamer
//
//  Created by DING FENG on 4/12/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "DemoViewControllerStreamer1.h"
#import <UPLiveSDK/UPAVCapturer.h>

@interface DemoViewControllerStreamer1 ()
{
    AVCaptureVideoPreviewLayer *_previewLayer;
    UIButton *_startBtn;
}
@end

@implementation DemoViewControllerStreamer1

- (void)viewDidLoad {
    [UPAVCapturer setLogLevel:UPAVCapturerLogger_level_debug];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 100, 100, 100)];
    [_startBtn setTitle:@"start" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_startBtn];
    
    //rtmp 推流地址
    NSString *rtmpPushUrl = @"rtmp://testlivesdk.v0.upaiyun.com/live/streamhz";
    //计算 upToken
    NSString *upToken = [UPAVCapturer tokenWithKey:@"password"
                                            bucket:@"testlivesdk"
                                        expiration:86400
                                   applicationName:@"live"
                                        streamName:@"streamhz"];
    
    rtmpPushUrl = [NSString stringWithFormat:@"%@?_upt=%@", rtmpPushUrl, upToken];
    NSLog(@"rtmpPushUrl: %@", rtmpPushUrl);
    
    //rtmp 播放地址
    NSString *rtmpPlayUrl = @"rtmp://testlivesdk.b0.upaiyun.com/live/streamhz";
    //浏览器测试播放地址
    NSString *webPlayUrl = @"http://test86400.b0.upaiyun.com/player/demo1/srs_player.html?vhost=testlivesdk.b0.upaiyun.com&app=live&stream=streamhz&server=testlivesdk.b0.upaiyun.com&port=1935&autostart=true";
    
    //设置推流地址
    [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(40, 20, 1500, 200)];
    label.text = [NSString stringWithFormat:@"rtmpPushUrl:\n%@\n\nrtmpPlayUrl:\n%@\n\nwebPlayUrl:\n%@\n",
                  rtmpPushUrl,
                  rtmpPlayUrl,
                  webPlayUrl];
    
    label.editable = NO;
    [self.view addSubview:label];
    
    //设置推流状态回调
    __weak DemoViewControllerStreamer1 *weakself = self;
    [UPAVCapturer sharedInstance].uPAVCapturerStatusBlock = ^(UPAVCapturerStatus status,
                                                              NSError *error) {
        //非主线程
        if (error) {
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
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
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
