//
//  UPLivePlayerDemoViewController.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLivePlayerDemoViewController.h"
#import "UPLivePlayerVC.h"


@interface UPLivePlayerDemoViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITextField *textFieldPlayUrl;
    int bufferingLength;
    UILabel *labelBufferValue;
    UITableView *_tableView;
    UIButton *_ConvininteUrl_1;
    UIButton *_ConvininteUrl_2;
    NSMutableArray *_playerHistoryUrls;
}

@end

@implementation UPLivePlayerDemoViewController

- (void)viewDidLoad {
    
    NSArray *historyUrls = [[NSUserDefaults standardUserDefaults] objectForKey:@"_playerHistoryUrls"];
    if (historyUrls) {
        _playerHistoryUrls = [[NSMutableArray alloc] initWithArray:historyUrls];
    } else {
        _playerHistoryUrls = [NSMutableArray new];
        [_playerHistoryUrls addObject:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
        [_playerHistoryUrls addObject:@"rtmp://testlivesdk.b0.upaiyun.com:1935/live/test1"];
        [[NSUserDefaults standardUserDefaults] setObject:_playerHistoryUrls forKey:@"_playerHistoryUrls"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 100, 44)];
    label.text = @"播放地址：";
    
    textFieldPlayUrl = [[UITextField alloc] initWithFrame:CGRectMake(20, 144, 280, 33)];
    textFieldPlayUrl.delegate = self;
    
    
    textFieldPlayUrl.text = @"http://uprocess.b0.upaiyun.com/demo/short_video/UPYUN_0.mp4";
    
    textFieldPlayUrl.borderStyle = UITextBorderStyleRoundedRect;
    textFieldPlayUrl.font = [UIFont systemFontOfSize:12.0f];
    textFieldPlayUrl.clearButtonMode = UITextFieldViewModeWhileEditing;
    textFieldPlayUrl.returnKeyType = UIReturnKeyDone;

    [self.view addSubview:label];
    [self.view addSubview:textFieldPlayUrl];
    
    UILabel *labelBuffer = [[UILabel alloc] initWithFrame:CGRectMake(20, 240, 100, 44)];
    labelBuffer.text = @"缓冲时间：";
    UIStepper *stepper = [[UIStepper alloc] initWithFrame:CGRectMake(120, 240, 60, 44)];
    stepper.minimumValue = 1;
    stepper.maximumValue = 10;
    stepper.stepValue = 1;
    stepper.wraps = YES;
    stepper.value = 2;
    [stepper addTarget:self action:@selector(stepperChange:) forControlEvents:UIControlEventValueChanged];
    
    labelBufferValue = [[UILabel alloc] initWithFrame:CGRectMake(240, 235, 100, 44)];
    
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self updateUI];
    return YES;
}

- (void)updateUI {
    NSURL *rtmpUrl = [NSURL URLWithString:textFieldPlayUrl.text];


    NSString *m3u8 = nil;
    NSString *flv = nil;
    
    
    

    if ([rtmpUrl.scheme isEqualToString:@"rtmp"] &&
        rtmpUrl.pathComponents.count == 3 &&
        [rtmpUrl.pathExtension isEqualToString:@""]) {
        m3u8 = [NSString stringWithFormat:@"http://%@%@.m3u8", rtmpUrl.host, rtmpUrl.path];
        flv = [NSString stringWithFormat:@"http://%@%@.flv", rtmpUrl.host, rtmpUrl.path];
    }
    
    if ([rtmpUrl.scheme isEqualToString:@"http"] &&
        rtmpUrl.pathComponents.count == 3 &&
        [rtmpUrl.pathExtension isEqualToString:@"m3u8"]) {
        
        m3u8 = [NSString stringWithFormat:@"rtmp://%@%@", rtmpUrl.host, [rtmpUrl.path stringByReplacingOccurrencesOfString:@".m3u8" withString:@""]];
        flv = [NSString stringWithFormat:@"http://%@%@.flv", rtmpUrl.host,[rtmpUrl.path stringByReplacingOccurrencesOfString:@".m3u8" withString:@""]];
    }
    
    if ([rtmpUrl.scheme isEqualToString:@"http"] &&
        rtmpUrl.pathComponents.count == 3 &&
        [rtmpUrl.pathExtension isEqualToString:@"flv"]) {
        m3u8 = [NSString stringWithFormat:@"http://%@%@.m3u8", rtmpUrl.host, [rtmpUrl.path stringByReplacingOccurrencesOfString:@".flv" withString:@""]];
        flv = [NSString stringWithFormat:@"rtmp://%@%@", rtmpUrl.host, [rtmpUrl.path stringByReplacingOccurrencesOfString:@".flv" withString:@""]];
    }
    
    if ([rtmpUrl.host containsString:@"hkstv"]) {
        m3u8 = nil;
        flv = nil;
        [_ConvininteUrl_1 removeFromSuperview];
        [_ConvininteUrl_2 removeFromSuperview];
    }
    
    
    if (!m3u8 || !flv) {
        return;
    }
    
    [_ConvininteUrl_1 removeFromSuperview];
    [_ConvininteUrl_2 removeFromSuperview];
    _ConvininteUrl_1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 175, 300, 44)];
    [_ConvininteUrl_1 setTitle:m3u8 forState:UIControlStateNormal];
    [_ConvininteUrl_1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _ConvininteUrl_1.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _ConvininteUrl_1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_ConvininteUrl_1 addTarget:self action:@selector(convininteBtn:) forControlEvents:UIControlEventTouchUpInside];
    _ConvininteUrl_2 = [[UIButton alloc] initWithFrame:CGRectMake(20, 205, 300, 44)];
    [_ConvininteUrl_2 setTitle:flv forState:UIControlStateNormal];
    [_ConvininteUrl_2 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _ConvininteUrl_2.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    _ConvininteUrl_2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_ConvininteUrl_2 addTarget:self action:@selector(convininteBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_ConvininteUrl_1];
    [self.view addSubview:_ConvininteUrl_2];
    [_tableView reloadData];
}

- (void)beginBtn:(UIButton *)sender {
    UPLivePlayerVC *playerVC = [[UPLivePlayerVC alloc] init];
    playerVC.url = textFieldPlayUrl.text;
    playerVC.bufferingTime = bufferingLength;
    [self presentViewController:playerVC animated:YES completion:nil];
    

    // add history urls
    [_playerHistoryUrls removeObject:textFieldPlayUrl.text];
    [_playerHistoryUrls insertObject:textFieldPlayUrl.text atIndex:0];
    [[NSUserDefaults standardUserDefaults] setObject:_playerHistoryUrls forKey:@"_playerHistoryUrls"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)stepperChange:(UIStepper *)sender {
    NSLog(@"%d", (int)sender.value);
    bufferingLength = (int)sender.value;
    labelBufferValue.text = [NSString stringWithFormat:@"%d s", bufferingLength];

}

- (void)convininteBtn:(UIButton *)sender {
    if (sender.titleLabel.text) {
        textFieldPlayUrl.text = sender.titleLabel.text;
        [self updateUI];
    }
}

- (void)hideKeyBoard {
    [textFieldPlayUrl resignFirstResponder];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _playerHistoryUrls.count;

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
    }
    
    cell.textLabel.text = _playerHistoryUrls[indexPath.row];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *url = [_playerHistoryUrls objectAtIndex:indexPath.row];
    textFieldPlayUrl.text = url;
    [self updateUI];
    
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"播放历史：";
}

@end
