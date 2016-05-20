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
    textFieldPlayUrl.text = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
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
    bufferingLength = (int)sender.value;
    labelBufferValue.text = [NSString stringWithFormat:@"%d s", bufferingLength];

}


@end
