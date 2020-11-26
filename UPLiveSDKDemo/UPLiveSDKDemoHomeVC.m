//
//  UPLiveSDKDemoHomeVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 20/07/2017.
//  Copyright © 2017 upyun.com. All rights reserved.
//

#import "UPLiveSDKDemoHomeVC.h"


#import "UPLivePlayerDemoViewController.h"//包括播放器详细功能设置
#import "UPLiveStreamerDemoViewController.h"//包括推流器详细功能设置，和连麦演示功能

#import "LiveVC.h"//精简版推流页面。不包括连麦，美颜，混音等功能逻辑
#import "PlayerVC.h"//精简版播放界面。

@interface UPLiveSDKDemoHomeVC ()

@end

@implementation UPLiveSDKDemoHomeVC

- (void)viewDidLoad {
    self.title = @"又拍云直播SDK";
}

- (IBAction)playerBtn1Tap:(id)sender {
    UPLivePlayerDemoViewController *vc = [UPLivePlayerDemoViewController new];
    vc.title = @"播放器";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)streamerBtn1Tap:(id)sender {
    UPLiveStreamerDemoViewController *vc = [UPLiveStreamerDemoViewController new];
    vc.title = @"推流器";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}


- (IBAction)playerBtn2Tap:(id)sender {
    PlayerVC *vc = [PlayerVC new];
    vc.title = @"播放";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)streamerBtn2Tap:(id)sender {
    LiveVC *vc = [LiveVC new];
    vc.title = @"直播";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

