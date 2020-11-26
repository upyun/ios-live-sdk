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
#import <AVFoundation/AVFoundation.h>


@implementation Settings

@end


@interface UPLiveStreamerDemoViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITextView *textViewPushUrl;
    UITextView *textViewPlayUrl;
    UITextField *textFieldStreamId;
    
    //摄像头和麦克风权限检查
    BOOL microphoneAvailable;
    BOOL cameraAvailable;
    BOOL microphoneChecked;
    BOOL cameraChecked;
    
    UITableView *_tableView;
    NSMutableArray *_streamerHistoryUrls;

}

@end

@implementation UPLiveStreamerDemoViewController


- (void)viewDidLoad {
    
    NSArray *historyUrls = [[NSUserDefaults standardUserDefaults] objectForKey:@"_streamerHistoryUrls"];
    if (historyUrls) {
        _streamerHistoryUrls = [[NSMutableArray alloc] initWithArray:historyUrls];
    } else {
        _streamerHistoryUrls = [NSMutableArray new];
        [_streamerHistoryUrls addObject:@"rtmp://testlivesdk.v0.upaiyun.com/live/test1"];
        [[NSUserDefaults standardUserDefaults] setObject:_streamerHistoryUrls forKey:@"_streamerHistoryUrls"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //default settings
    Settings *settings = [[Settings alloc] init];
    settings.rtmpServerPushPath = @"rtmp://testlivesdk.v0.upaiyun.com/live/";
    settings.rtmpServerPlayPath = @"rtmp://testlivesdk.b0.upaiyun.com/live/";
    settings.fps = 24;
    settings.beautifyOn = YES;
    settings.streamingOn = YES;
    settings.camaraTorchOn = NO;
    settings.camaraPosition = AVCaptureDevicePositionBack;
    settings.videoOrientation = AVCaptureVideoOrientationPortrait;
    settings.level = UPAVCapturerPreset_640x480;
    settings.filterLevel = 3;

    
    self.settings = settings;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 100, 44)];
    label.text = @"输入流id：";
    
    textFieldStreamId = [[UITextField alloc] initWithFrame:CGRectMake(20, 144, 280, 33)];
    textFieldStreamId.delegate = self;
    textFieldStreamId.text = @"test1";
    textFieldStreamId.borderStyle = UITextBorderStyleRoundedRect;
    textFieldStreamId.returnKeyType = UIReturnKeyDone;
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
    
    UIButton *beginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 66, 100, 44)];
    [beginBtn addTarget:self action:@selector(beginBtn:) forControlEvents:UIControlEventTouchUpInside];
    [beginBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [beginBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    beginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [beginBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    
    [self.view addSubview:settingsBtn];
    [self.view addSubview:beginBtn];

    [self updateUI];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]
//                                           initWithTarget:self
//                                           action:@selector(hideKeyBoard)];
//    
//    [self.view addGestureRecognizer:tapGesture];
    
    [_tableView removeFromSuperview];
    CGFloat s_w = [UIScreen mainScreen].bounds.size.width;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 470, s_w, 200)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateUI];
}
- (void)updateUI {
    textViewPushUrl.text = [NSString stringWithFormat:@"%@%@", self.settings.rtmpServerPushPath, self.settings.streamId];
    NSURL *url = [NSURL URLWithString:self.settings.rtmpServerPlayPath relativeToURL:nil];

    NSString *rtmpPlayUrl = [NSString stringWithFormat:@"rtmp://%@/%@/%@", url.host, _settings.rtmpServerPushPath.lastPathComponent,self.settings.streamId];

    NSString *hlsPlayUrl = [NSString stringWithFormat:@"http://%@/%@/%@.m3u8", url.host, _settings.rtmpServerPushPath.lastPathComponent,self.settings.streamId];
    textViewPlayUrl.text = [NSString stringWithFormat:@"%@ \n%@", rtmpPlayUrl, hlsPlayUrl];
    
    textFieldStreamId.text = _settings.streamId;

    [_tableView reloadData];
}

- (void)settingsBtn:(UIButton *)sender {
    UPLiveStreamerSettingVC *settingsVC = [[UPLiveStreamerSettingVC alloc] init];
    settingsVC.demoVC = self;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

- (void)tryStartLiving {
    if (!microphoneChecked || !cameraChecked) {
        return ;
    }
    if (!cameraAvailable || !microphoneAvailable) {
        [self errorAlert:@"请开启摄像头和麦克风权限"];
        return;
    }
    
    microphoneChecked = NO;
    cameraChecked = NO;
    cameraAvailable = NO;
    microphoneAvailable = NO;
    UPLiveStreamerLivingVC *livingVC = [[UPLiveStreamerLivingVC alloc] init];
    livingVC.settings = self.settings;
    [self presentViewController:livingVC animated:YES completion:nil];
}

- (void)beginBtn:(UIButton *)sender {
    microphoneChecked = NO;
    cameraChecked = NO;
    cameraAvailable = NO;
    microphoneAvailable = NO;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (!granted) {
                cameraAvailable = NO;
                NSLog(@"需要开启摄像头权限");
            } else {
                cameraAvailable = YES;
                NSLog(@"摄像头权限 ok");
            }
            cameraChecked = YES;
            [self tryStartLiving];
        });
 
    }];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            if (!granted) {
                NSLog(@"需要开启麦克风权限");
                microphoneAvailable = NO;
            } else {
                NSLog(@"麦克风权限 ok");
                microphoneAvailable = YES;
            }
            microphoneChecked = YES;
            [self tryStartLiving];
        });

    }];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", _settings.rtmpServerPushPath, _settings.streamId];
    [_streamerHistoryUrls removeObject:url];
    [_streamerHistoryUrls insertObject:url atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_streamerHistoryUrls forKey:@"_streamerHistoryUrls"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)errorAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
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



- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.settings.streamId = textFieldStreamId.text;
    [self updateUI];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)setSettings:(Settings *)settings {
    _settings = settings;
    [self updateUI];
}

- (void)hideKeyBoard {
    [textFieldStreamId resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _streamerHistoryUrls.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    cell.textLabel.text = _streamerHistoryUrls[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = [_streamerHistoryUrls objectAtIndex:indexPath.row];
    NSURL *rtmpUrl = [NSURL URLWithString:url];
    
    if ([rtmpUrl.scheme isEqualToString:@"rtmp"] &&
        rtmpUrl.pathComponents.count == 3) {
        _settings.rtmpServerPushPath = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",rtmpUrl.lastPathComponent] withString:@""];
        self.settings.streamId = rtmpUrl.lastPathComponent;

        [self updateUI];
        
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"推流历史：";
}

@end
