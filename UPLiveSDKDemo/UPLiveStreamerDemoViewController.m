//
//  UPLiveStreamerDemoViewController.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//


#import "UPLiveStreamerDemoViewController.h"
#import "UPLiveStreamerSettingVC.h"
#import "UPLiveStreamerLivingVC.h"

@implementation Settings

@end


@interface UPLiveStreamerDemoViewController ()<UITextFieldDelegate>
{
    UITextView *textViewPushUrl;
    UITextView *textViewPlayUrl;
    UITextField *textFieldStreamId;
}

@end

@implementation UPLiveStreamerDemoViewController


- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    //default settings
    Settings *settings = [[Settings alloc] init];
    settings.rtmpServerPushPath = @"rtmp://testlivesdk.v0.upaiyun.com/live/";
    settings.rtmpServerPlayPath = @"rtmp://testlivesdk.b0.upaiyun.com/live/";
    settings.fps = 24;
    settings.filter = YES;
    settings.streamingOnOff = YES;
    settings.camaraTorchOn = NO;
    settings.camaraPosition = AVCaptureDevicePositionBack;
    settings.videoOrientation = AVCaptureVideoOrientationPortrait;
    settings.level = UPAVCapturerPreset_640x480;
    settings.filterLevel = Beautify_Normal;

    
    self.settings = settings;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 100, 44)];
    label.text = @"输入流id：";
    
    textFieldStreamId = [[UITextField alloc] initWithFrame:CGRectMake(20, 144, 280, 33)];
    textFieldStreamId.delegate = self;
    textFieldStreamId.text = @"test1";
    textFieldStreamId.borderStyle = UITextBorderStyleRoundedRect;
    self.settings.streamId = textFieldStreamId.text;

    UILabel *labelPushUrl = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 100, 44)];
    labelPushUrl.text = @"推流地址：";
    
    textViewPushUrl = [[UITextView alloc] initWithFrame:CGRectMake(20, 244, 280, 44)];
    textViewPushUrl.editable = NO;
    
    UILabel *labelPlayUrl = [[UILabel alloc] initWithFrame:CGRectMake(20, 288, 100, 44)];
    labelPlayUrl.text = @"播放地址：";
    
    textViewPlayUrl = [[UITextView alloc] initWithFrame:CGRectMake(20, 332, 280, 44)];
    textViewPlayUrl.editable = NO;

    [self.view addSubview:label];
    [self.view addSubview:textFieldStreamId];
    
    [self.view addSubview:labelPushUrl];
    [self.view addSubview:labelPlayUrl];
    [self.view addSubview:textViewPushUrl];
    [self.view addSubview:textViewPlayUrl];

    UIButton *settingsBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 400, 100, 44)];
    [settingsBtn addTarget:self action:@selector(settingsBtn:) forControlEvents:UIControlEventTouchUpInside];
    [settingsBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [settingsBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    settingsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [settingsBtn setTitle:@"参数设置" forState:UIControlStateNormal];
    
    UIButton *beginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 450, 100, 44)];
    [beginBtn addTarget:self action:@selector(beginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [beginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [beginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    beginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [beginBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    
    [self.view addSubview:settingsBtn];
    [self.view addSubview:beginBtn];

    [self updateUI];
}

- (void)updateUI {
    textViewPushUrl.text = [NSString stringWithFormat:@"%@%@", self.settings.rtmpServerPushPath, self.settings.streamId];
    textViewPlayUrl.text = [NSString stringWithFormat:@"%@%@", self.settings.rtmpServerPlayPath, self.settings.streamId];
}

- (void)settingsBtn:(UIButton *)sender {
    UPLiveStreamerSettingVC *settingsVC = [[UPLiveStreamerSettingVC alloc] init];
    settingsVC.demoVC = self;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

- (void)beginBtn:(UIButton *)sender {
    UPLiveStreamerLivingVC *livingVC = [[UPLiveStreamerLivingVC alloc] init];
    livingVC.settings = self.settings;
    [self presentViewController:livingVC animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    self.settings.streamId = textFieldStreamId.text;
    [self updateUI];
    return YES;
}

- (void)setSettings:(Settings *)settings {
    _settings = settings;
    [self updateUI];
}


@end
