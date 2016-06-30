//
//  DemoViewControllerFullscreen.m
//  UPAVPlayerDemo
//
//  Created by DING FENG on 3/2/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "DemoViewControllerFullscreen.h"
#import <UPLiveSDK/UPAVPlayer.h>

#import "UPQRCodeViewController.h"

@interface DemoViewControllerFullscreen () <UIActionSheetDelegate, UPQRCodeDelegate, UITextFieldDelegate>
{
    UPAVPlayer *_player;
    UIButton *_infoBtn;
    UIActivityIndicatorView *_activityIndicatorView;
    UIPanGestureRecognizer *panGestureRecognizer;
    CGPoint beginPoint;
}
@property (nonatomic, strong) UITextField *urlInput;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation DemoViewControllerFullscreen
- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    _activityIndicatorView.hidesWhenStopped = YES;
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.view.frame.size.width + 84 +80, 100, 60)];
    [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playBtn setTitle:@"play" forState:UIControlStateNormal];
    _stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(120, self.view.frame.size.width + 84 +80, 100, 60)];
    [_stopBtn addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    
    _urlInput = [[UITextField alloc] initWithFrame:CGRectMake(20, self.view.frame.size.width + 84, self.view.frame.size.width-40, 60)];
    _urlInput.font = [UIFont systemFontOfSize:13];
    _urlInput.layer.masksToBounds = YES;
    _urlInput.layer.borderWidth = 1;
    _urlInput.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _urlInput.layer.cornerRadius = 4;
    _urlInput.delegate = self;
    _urlInput.placeholder = @"请输入要播放的URL 或着 扫一扫";
    _urlInput.text = @"rtmp://testlivesdk.b0.upaiyun.com/live/upyun";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    UIButton *changeBitrate = [[UIButton alloc] initWithFrame:CGRectMake(220, self.view.frame.size.width + 84 +80, 100, 60)];
    [changeBitrate addTarget:self action:@selector(changeBitrate:) forControlEvents:UIControlEventTouchUpInside];
    [changeBitrate setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [changeBitrate setTitle:@"调整码率" forState:UIControlStateNormal];
    changeBitrate.tag = 0;
    [self.view addSubview:changeBitrate];
    
    [self.view addSubview:_activityIndicatorView];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_stopBtn];
    [self.view addSubview:_urlInput];
    
    _player = [[UPAVPlayer alloc] initWithURL:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    [_player setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width)];
    //[_player setFrame:self.view.bounds];
    [_player setBufferingTime:1];
    _player.autoChangeBitrate = NO;
    
    __weak typeof(self) weakself = self;
    _player.playerStadusBlock = ^(UPAVPlayerStatus playerStatus, NSError *error) {
        switch (playerStatus) {
            case UPAVPlayerStatusIdle:{
                [weakself.activityIndicatorView stopAnimating];
                weakself.playBtn.enabled = YES;
                [weakself.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                weakself.stopBtn.enabled = NO;
                [weakself.stopBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
                break;
            case UPAVPlayerStatusPlaying_buffering:{
                [weakself.activityIndicatorView startAnimating];
                weakself.playBtn.enabled = NO;
                [weakself.playBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                weakself.stopBtn.enabled = YES;
                [weakself.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
                break;
            case UPAVPlayerStatusPlaying:{
                [weakself.activityIndicatorView stopAnimating];
            }
                break;
            case UPAVPlayerStatusFailed:{
                [weakself.activityIndicatorView stopAnimating];
                
                NSString *msg = @"请重新尝试播放.";
                if (error) {
                    msg = error.description;
                }
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"播放失败!"
                                                                               message:msg
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                      }];
                [alert addAction:defaultAction];
                [weakself presentViewController:alert animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    };
    
    _infoBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 100, 50)];
    [_infoBtn addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    [_infoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_infoBtn setTitle:@"全屏切换" forState:UIControlStateNormal];
    [_player.playView addSubview:_infoBtn];

    [self.view insertSubview:_player.playView atIndex:0];
    _activityIndicatorView.center = _player.playView.center;
    [self.view addSubview:_activityIndicatorView];
    
    _infoBtn.tag = 1;
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleSlideFrom:)];
    
//    [_player configChoppyRetryMaxCount:2 inTimeScope:2*60*1000.0];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn addTarget:self action:@selector(QRCode:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:11];
    [btn setTitle:@"扫一扫" forState:UIControlStateNormal];//不要用setbackgroudimage
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = backItem;
}

- (void)QRCode:(UIButton *) button {
    UPQRCodeViewController *vc = [[UPQRCodeViewController alloc]init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.upQRdelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stop:nil];
}

- (void)play:(id)sender {
    if (_urlInput.text.length > 0) {
        _player.url = _urlInput.text;
    }
    
    [_player play];
}

- (void)stop:(id)sender {
    [_player stop];
}

- (void)changeBitrate:(UIButton *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"画质选择"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"自动"
                                  otherButtonTitles: nil];
    
    for (int i = 1; i <= _player.urlArray.count; i++) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"第%d项",i]];
    }
    
//    actionSheet.actionSheetStyle = UIActionSheetStyle;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"click %ld", (long)buttonIndex);
    if (buttonIndex == 0) {
        NSLog(@"自动切换");
        _player.autoChangeBitrate = !_player.autoChangeBitrate;
    } else if (buttonIndex == 1) {
        NSLog(@"取消");
    } else if (buttonIndex >= 2) {
        _player.bitrateLevel = buttonIndex-2;
    }
}

- (void)info:(id)sender {
    
    if (_infoBtn.tag == 1) {
        self.navigationController.navigationBarHidden = YES;
        _player.fullScreen = YES;
        
        [_player.playView addGestureRecognizer:panGestureRecognizer];
        _infoBtn.tag = 2;
    } else {
        self.navigationController.navigationBarHidden = NO;
        _infoBtn.tag = 1;
        _player.fullScreen = NO;
        [_player.playView removeGestureRecognizer:panGestureRecognizer];
    }
}

// 简单的滑动手势
- (void)handleSlideFrom:(UIPanGestureRecognizer *)recognizer{
    beginPoint = [recognizer locationInView:self.view];
    CGPoint translation = [recognizer translationInView:self.view];
//    NSLog(@"beginPoint %@", NSStringFromCGPoint(beginPoint));
    NSLog(@"translation %@", NSStringFromCGPoint(translation));
    if (ABS(translation.x)<20 && ABS(translation.y) > 5) {
        if (beginPoint.x < _player.playView.frame.size.width/2) {
            if (translation.y>0) {
                _player.volume = _player.volume - 0.05;
            } else {
                _player.volume = _player.volume + 0.05;
            }
        } else {
            if (translation.y>0) {
                _player.bright = _player.bright - 0.05;
            } else {
                _player.bright = _player.bright + 0.05;
            }
        }
        beginPoint = translation;
    }
}

- (void)returnWithResult:(NSString *)result {
    _urlInput.text = result;
}

//实现了UITextFieldDelegate中的方法，当对TextField进行编辑即键盘弹出时，自动将输入框上移
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移
    CGRect rect=CGRectMake(0.0f,-160,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //回归原位
    CGRect rect=CGRectMake(0.0,0.0,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
}

-(void)dismissKeyboard {
    [_urlInput resignFirstResponder];
}

- (void)dealloc {

    NSLog(@"dealloc %@", self);
}


@end
