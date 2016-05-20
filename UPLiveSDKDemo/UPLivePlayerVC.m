//
//  UPLivePlayerVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/20/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLivePlayerVC.h"
#import <UPLiveSDK/UPAVPlayer.h>

@interface UPLivePlayerVC ()
{
    UPAVPlayer *_player;
    UIButton *_infoBtn;
    UIActivityIndicatorView *_activityIndicatorView;
    UILabel *_bufferingProgressLabel;
}

@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *bufferingProgressLabel;


@end

@implementation UPLivePlayerVC

- (void)viewDidLoad {
    [UPAVPlayer setLogLevel:UP_Level_debug];
    self.view.backgroundColor = [UIColor blackColor];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    _activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(250.0,20.0,30.0,30.0)];
    _activityIndicatorView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhite;
    _activityIndicatorView.hidesWhenStopped = YES;
    
    _playBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, 500, 100, 100)];
    [_playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [_playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_playBtn setTitle:@"play" forState:UIControlStateNormal];
    _stopBtn = [[UIButton alloc] initWithFrame:CGRectMake(140, 500, 100, 100)];
    [_stopBtn addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    [_stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    _infoBtn = [[UIButton alloc] initWithFrame:CGRectMake(240, 500, 100, 100)];
    [_infoBtn addTarget:self action:@selector(info:) forControlEvents:UIControlEventTouchUpInside];
    [_infoBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_infoBtn setTitle:@"info" forState:UIControlStateNormal];
    
    _bufferingProgressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    _bufferingProgressLabel.backgroundColor = [UIColor clearColor];
    _bufferingProgressLabel.textColor = [UIColor lightTextColor];
    
    [self.view addSubview:_activityIndicatorView];
    [self.view addSubview:_playBtn];
    [self.view addSubview:_stopBtn];
    [self.view addSubview:_infoBtn];
    [self.view addSubview:_bufferingProgressLabel];
    

    _player = [[UPAVPlayer alloc] initWithURL:self.url];
    _player.bufferingTime = self.bufferingTime;
    __weak UPLivePlayerVC *weakself = self;
    _player.playerStadusBlock = ^(UPAVPlayerStatus playerStatus, NSError *error){
        switch (playerStatus) {
            case UPAVPlayerStatusIdle:{
                [weakself.activityIndicatorView stopAnimating];
                weakself.bufferingProgressLabel.hidden = YES;
                weakself.playBtn.enabled = YES;
                [weakself.playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                weakself.stopBtn.enabled = NO;
                [weakself.stopBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
                break;
            case UPAVPlayerStatusPlaying_buffering:{
                [weakself.activityIndicatorView startAnimating];
                weakself.bufferingProgressLabel.hidden = NO;
                
                weakself.playBtn.enabled = NO;
                [weakself.playBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                weakself.stopBtn.enabled = YES;
                [weakself.stopBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
            }
                break;
            case UPAVPlayerStatusPlaying:{
                [weakself.activityIndicatorView stopAnimating];
                weakself.bufferingProgressLabel.hidden = YES;
                
            }
                break;
            case UPAVPlayerStatusFailed:{
                [weakself.activityIndicatorView stopAnimating];
                weakself.bufferingProgressLabel.hidden = YES;
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
    
    _player.bufferingProgressBlock = ^(float progress) {
        weakself.bufferingProgressLabel.text = [NSString stringWithFormat:@"%.0f %%", (progress * 100)];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.view.frame = [UIScreen mainScreen].bounds;
    [_player setFrame:[UIScreen mainScreen].bounds];

    [self.view insertSubview:_player.playView atIndex:0];
    _activityIndicatorView.center = CGPointMake(_player.playView.center.x - 30, _player.playView.center.y);
    _bufferingProgressLabel.center = CGPointMake(_player.playView.center.x + 30, _player.playView.center.y);
    [self.view addSubview:_activityIndicatorView];
    [_player play];

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

- (void)info:(id)sender {
    NSString *message = [NSString stringWithFormat:@"Stream Info:\n %@ \n\n\n\n", _player.videoInfo];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"info"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
