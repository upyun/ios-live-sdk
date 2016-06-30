//
//  DemoViewController1.m
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "DemoViewControllerPlayer1.h"
#import <UPLiveSDK/UPAVPlayer.h>

@interface DemoViewControllerPlayer1 ()<UPAVPlayerDelegate>
{
    UPAVPlayer *_player;
    UIButton *_infoBtn;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_bufferingProgressLabel;
    UISlider *slider;
    BOOL _sliding;
}

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *bufferingProgressLabel;


@end

@implementation DemoViewControllerPlayer1

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    _activityIndicatorView.hidesWhenStopped = YES;
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 500, 80, 80)];
    [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playBtn setTitle:@"play" forState:UIControlStateNormal];
    
    _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(80, 500, 80, 80)];
    [_pauseBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    [_pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_pauseBtn setTitle:@"pause" forState:UIControlStateNormal];
    
    _stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(160, 500, 80, 80)];
    [_stopBtn addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    _infoBtn = [[UIButton alloc] initWithFrame:CGRectMake(240, 500, 80, 80)];
    [_infoBtn addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    [_infoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_infoBtn setTitle:@"info" forState:UIControlStateNormal];
    
    _bufferingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _bufferingProgressLabel.backgroundColor = [UIColor clearColor];
    _bufferingProgressLabel.textColor = [UIColor lightTextColor];
    
    [self.view addSubview:_activityIndicatorView];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_pauseBtn];
    [self.view addSubview:_stopBtn];
    [self.view addSubview:_infoBtn];
    [self.view addSubview:_bufferingProgressLabel];
    
    //http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/appleman.m3u8      多码率m3u8 嵌套
    //http://vevoplaylist-live.hls.adaptive.level3.net/vevo/ch1/02/prog_index.m3u8 单m3u8
//    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"war3end.mp4"];
    NSString *filePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"test.flv"];
//    BOOL aa =  [DemoViewControllerPlayer1 isFileExist:filePath];
    
    filePath = @"http://v1.tangdouimg.com/tdvideo/2016/0511/7937144.mp4";
    
//    filePath = @"rtmp://testlivesdk.b0.upaiyun.com/live/1234";
//    filePath = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
    
    
//    filePath = @"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8";
    
    _player = [[UPAVPlayer alloc] initWithURL:filePath];
    _player.delegate = self;
    [_player connect];
    _player.bufferingTime = 1;
    [_player setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width)];
    
    
    [self.view insertSubview:_player.playView atIndex:0];
    _activityIndicatorView.center = CGPointMake(_player.playView.center.x - 30, _player.playView.center.y);
    _bufferingProgressLabel.center = CGPointMake(_player.playView.center.x + 30, _player.playView.center.y);
    [self.view addSubview:_activityIndicatorView];
    
    slider=[[UISlider alloc]initWithFrame:CGRectMake(60, 450, 200, 30)];
    slider.tag=101;
    //设置最大值
    slider.maximumValue = 0;
    //设置最小值
    slider.minimumValue = 0;
    //设置默认值
    slider.value = 0.0f;
    slider.continuous = NO;
    
    [slider addTarget:self action:@selector(valueChange:) forControlEvents:(UIControlEventTouchUpInside)];
    [slider addTarget:self action:@selector(valueChange:) forControlEvents:(UIControlEventTouchUpOutside)];
    [slider addTarget:self action:@selector(touchDown:) forControlEvents:(UIControlEventTouchDown)];

    
    [self.view addSubview:slider];
}

-(void)touchDown:(UISlider *)slider{
    _sliding = YES;
}

-(void)valueChange:(UISlider *)slider_{
    NSLog(@"slider value : %.2f", slider_.value);
    if (_player) {
        [_player seekToTime:slider_.value];
        _sliding = NO;
    }
}

+ (BOOL) isFileExist:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:fileName];
    return result;
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stop:nil];
}

- (void)play:(id)sender {
    [_player play];
}

- (void)stop:(id)sender {
    [_player stop];
}
- (void)pause:(id)sender {
    [_player pause];
}
- (void)info:(id)sender {
//    NSString *message = [NSString stringWithFormat:@"Stream Info:\n %@ \n\n\n\n", _player.streamInfo.descriptionInfo];
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"info"
//                                                                   message:message
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
//                                                            style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {
//                                                          }];
//    [alert addAction:defaultAction];
//    [self presentViewController:alert animated:YES completion:nil];
}


- (void)dealloc {
    NSLog(@"dealloc %@", self);
}


#pragma mark UPAVPlayerDelegate

- (void)UPAVPlayer:(UPAVPlayer *)player streamStatusDidChange:(UPAVStreamStatus)streamStatus {
    switch (streamStatus) {
        case UPAVStreamStatusIdle:
            break;
        case UPAVStreamStatusConnecting:{
            NSLog(@"正在建立连接－－－－－");
            
            
//            player.interrupted = YES; 中断
        }
            break;
        case UPAVStreamStatusReady:{
            NSLog(@"连接建立成功－－－－－");
        }
            break;
        default:
            break;
    }
}

- (void)UPAVPlayer:(UPAVPlayer *)player playerStatusDidChange:(UPAVPlayerStatus)playerStatus {
    
    switch (playerStatus) {
        case UPAVPlayerStatusIdle:{
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.playBtn.enabled = YES;
            [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = NO;
            [self.stopBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            [self.pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case UPAVPlayerStatusPause:{
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.playBtn.enabled = YES;
            [self.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = YES;
            [self.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = NO;
            [self.pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
            
        case UPAVPlayerStatusPlaying_buffering:{
            [self.activityIndicatorView startAnimating];
            self.bufferingProgressLabel.hidden = NO;
            self.playBtn.enabled = NO;
            [self.playBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            self.stopBtn.enabled = YES;
            [self.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            self.pauseBtn.enabled = YES;
            [self.pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            
        }
            break;
        case UPAVPlayerStatusPlaying:{
            [self.activityIndicatorView stopAnimating];
            self.bufferingProgressLabel.hidden = YES;
            self.pauseBtn.enabled = YES;
            [self.pauseBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        }
            break;
        case UPAVPlayerStatusFailed:{
            
        }
            break;
        default:
            break;
    }
}

- (void)UPAVPlayer:(id)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo {
    NSLog(@"获取视频信息-- %@ ", streamInfo.descriptionInfo);
    
    if (streamInfo.canPause && streamInfo.canSeek) {
        slider.maximumValue = streamInfo.duration;
        
        NSLog(@"streamInfo.duration %f", streamInfo.duration);
    } else {
        slider.enabled = NO;
        _pauseBtn.enabled = NO;
        [_pauseBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)UPAVPlayer:(id)player displayPositionDidChange:(float)position {
    if (_sliding) {
        return;
    }
    slider.value = position;
}

- (void)UPAVPlayer:(id)player playerError:(NSError *)error {
    [self.activityIndicatorView stopAnimating];
    self.bufferingProgressLabel.hidden = YES;
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
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)UPAVPlayer:(id)player bufferingProgressDidChange:(float)progress {
    self.bufferingProgressLabel.text = [NSString stringWithFormat:@"%.0f %%", (progress * 100)];
}

@end
