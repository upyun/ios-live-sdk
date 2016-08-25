//
//  UPLivePlayerDemoViewController.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLivePlayerDemoViewController.h"
#import "UPLivePlayerVC.h"

@interface UPLivePlayerDemoViewController ()<UITextFieldDelegate>
{
    UITextField *textFieldPlayUrl;
    int bufferingLength;
    UILabel *labelBufferValue;
}

@end

@implementation UPLivePlayerDemoViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 100, 44)];
    label.text = @"播放地址：";
    
    textFieldPlayUrl = [[UITextField alloc] initWithFrame:CGRectMake(20, 144, 280, 33)];
    textFieldPlayUrl.delegate = self;
    
    /* test urls
     http://test86400.b0.upaiyun.com/7937144.mp4
     rtmp://live.hkstv.hk.lxdns.com/live/hks
     http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8
     http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8
     rtmp://testlivesdk.b0.upaiyun.com/live/test196
     http://test654123.b0.upaiyun.com/265_demo.mp4 h265 hevc 格式
     http://test86400.b0.upaiyun.com/shanqiu.mp3
     */
    
    textFieldPlayUrl.text = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    
    //http://test86400.b0.upaiyun.com/flv/2016_08_15_16_28_20_853_%2B0800.flv
    //http://upyun-live-recorder.b0.upaiyun.com/live.ecook.cn/live/2/recorder20160812202528.mp4
    //http://upyun-live-recorder.b0.upaiyun.com/live.ecook.cn/live/2/recorder20160812202528.mp4
    textFieldPlayUrl.borderStyle = UITextBorderStyleRoundedRect;
    textFieldPlayUrl.font = [UIFont systemFontOfSize:12.0f];
    textFieldPlayUrl.clearButtonMode = UITextFieldViewModeWhileEditing;

    [self.view addSubview:label];
    [self.view addSubview:textFieldPlayUrl];
    
    UILabel *labelBuffer = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 100, 44)];
    labelBuffer.text = @"缓冲时间：";
    
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(120, 200, 60, 44)];
    stepper.minimumValue = 1;
    stepper.maximumValue = 10;
    stepper.stepValue = 1;
    stepper.wraps = YES;
    stepper.value = 2;
    [stepper addTarget:self action:@selector(stepperChange:) forControlEvents:UIControlEventValueChanged];
    
    labelBufferValue = [[UILabel alloc] initWithFrame:CGRectMake(240, 197, 100, 44)];
    
    if (bufferingLength < 1 || bufferingLength > 10) {
        bufferingLength = 2;
    }
    labelBufferValue.text = [NSString stringWithFormat:@"%d s", bufferingLength];
    
    [self.view addSubview:labelBuffer];
    [self.view addSubview:stepper];
    [self.view addSubview:labelBufferValue];

    UIButton *beginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 300, 100, 44)];
    [beginBtn addTarget:self action:@selector(beginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [beginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [beginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    beginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [beginBtn setTitle:@"开始播放" forState:UIControlStateNormal];
    
    [self.view addSubview:beginBtn];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(hideKeyBoard)];
    
    [self.view addGestureRecognizer:tapGesture];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)beginBtn:(UIButton *)sender {

    UPLivePlayerVC *playerVC = [[UPLivePlayerVC alloc] init];
    playerVC.url = textFieldPlayUrl.text;
    playerVC.bufferingTime = bufferingLength;
    [self presentViewController:playerVC animated:YES completion:nil];
}

- (void)stepperChange:(UIStepper *)sender {
    NSLog(@"%d", (int)sender.value);
    bufferingLength = (int)sender.value;
    labelBufferValue.text = [NSString stringWithFormat:@"%d s", bufferingLength];

}

- (void)hideKeyBoard {
    [textFieldPlayUrl resignFirstResponder];
}

@end
