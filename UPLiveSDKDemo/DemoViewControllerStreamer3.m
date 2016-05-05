//
//  Demo3ViewController.m
//  SFFmpegIOSStreamer
//
//  Created by 林港 on 16/4/18.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "DemoViewControllerStreamer3.h"
#import <UPLiveSDK/UPAVCapturer.h>


@interface DemoViewControllerStreamer3 ()<UITextFieldDelegate>
{
    AVCaptureVideoPreviewLayer *_previewLayer;
    UIButton *_startBtn;
    UIButton *_dismissBtn;
    UITextField *urlTextField;
}
@end

@implementation DemoViewControllerStreamer3

- (void)viewDidLoad {
    [UPAVCapturer setLogLevel:UPAVCapturerLogger_level_debug];
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _startBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 80, 100, 80)];
    [_startBtn setTitle:@"start" forState:UIControlStateNormal];
    [_startBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_startBtn addTarget:self action:@selector(startBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_startBtn];
    
    //rtmp 推流地址
    NSString *rtmpPushUrl = @"rtmp://testlivesdk.v0.upaiyun.com/live/upyun+后缀";

    //rtmp 播放地址
    NSString *rtmpPlayUrl = @"rtmp://testlivesdk.b0.upaiyun.com/live/upyun+后缀(注意播放的时候没有+号)";

    UITextView *label = [[UITextView alloc] initWithFrame:CGRectMake(40, 20, 1500, 150)];
    label.text = [NSString stringWithFormat:@"rtmpPushUrl:\n%@\n\nrtmpPlayUrl:\n%@\n", rtmpPushUrl,rtmpPlayUrl];
    label.editable = NO;
    [self.view addSubview:label];
    

    urlTextField = [[UITextField alloc]initWithFrame:CGRectMake(10, 100, 300, 40)];
    urlTextField.layer.borderColor = [UIColor blackColor].CGColor;
    urlTextField.layer.borderWidth = 1;
    urlTextField.placeholder = @"输入流的后缀,只支持中英文,不要和别人的重复,防冲突";
    urlTextField.font = [UIFont systemFontOfSize:11];
    urlTextField.delegate = self;
    [self.view addSubview:urlTextField];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(endEd)];
    [self.view addGestureRecognizer:tap];
    
    __weak DemoViewControllerStreamer3 *weakself = self;
    [UPAVCapturer sharedInstance].uPAVCapturerStatusBlock = ^(UPAVCapturerStatus status, NSError *error) {
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
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self startBtn:_startBtn];
                                                              }];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

- (void)viewWillAppear:(BOOL)animated {
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]  removeObserver:self name:@"UPAVPacketManager_error" object:nil];
}

- (void)endEd {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)startBtn:(UIButton *)sender {
    if (sender.tag == 0) {
        NSString *text = urlTextField.text;
        
        
        //推流地址
        NSString *rtmpPushUrl = [NSString stringWithFormat:@"%@%@",@"rtmp://testlivesdk.v0.upaiyun.com/live/upyun",text];
        
        //计算 upToken
        NSString *upToken = [UPAVCapturer tokenWithKey:@"password"
                                                bucket:@"testlivesdk"
                                            expiration:86400
                                       applicationName:@"live"
                                            streamName:@"streamhz"];

        rtmpPushUrl = [NSString stringWithFormat:@"%@?_upt=%@", rtmpPushUrl, upToken];
        NSLog(@"rtmpPushUrl: %@", rtmpPushUrl);

        [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
        
        [self setPreview];
        [[UPAVCapturer sharedInstance] start];
        [sender setTitle:@"stop" forState:UIControlStateNormal];
        sender.tag = 1;
    } else {
        [[UPAVCapturer sharedInstance] stop];
        [sender setTitle:@"start" forState:UIControlStateNormal];
        sender.tag = 0;
    }
}

- (void)setPreview {
    [_previewLayer removeFromSuperlayer];
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[UPAVCapturer sharedInstance].captureSession];
    _previewLayer.frame = CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.width);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

@end
