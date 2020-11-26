//
//  PlayerVC.m
//  UPLiveSDKDemo
//
//  Copyright © 2017 upyun.com. All rights reserved.

#import "PlayerVC.h"
#import <UPLiveSDKDll/UPAVPlayer.h>

@interface PlayerVC ()<UPAVPlayerDelegate>
{
   UPAVPlayer *_player;
}
@end

@implementation PlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    //1. 初始化播放器
    _player = [[UPAVPlayer alloc] initWithURL:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
    
    //2. 设置代理，接受播放错误，播放进度，播放状态等回调信息
    _player.delegate = self;
    
    //3. 设置播放器 playView Frame
    [_player setFrame:self.view.bounds];
    
    //4. 添加播放器 playView
    [self.view insertSubview:_player.playView atIndex:0];
    
    //5. 开始播放
    [_player play];
}

- (void)viewWillDisappear:(BOOL)animated {
    //6. 关闭页面，播放器需要 stop 才会自动释放。
    [_player stop];
}

#pragma mark UPAVPlayerDelegate
- (void)player:(UPAVPlayer *)player playerError:(NSError *)error {
    //7. 监听播放错误。
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"播放失败" message:error.description preferredStyle:1];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark 播放，停止按钮
- (IBAction)playBtnTap:(id)sender {
    //8. 播放按钮。
    [_player play];
}

- (IBAction)stopBtnTap:(id)sender {
    //9. 停止按钮。
    [_player stop];
}

@end
