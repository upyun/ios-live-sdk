//
//  UPLiveViewController.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLiveViewController.h"
#import "UPLivePlayerDemoViewController.h"
#import "UPLiveStreamerDemoViewController.h"


@interface UPLiveViewController ()

@end

@implementation UPLiveViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"UPYUN iOS Live SDK 示例";
    
    UIButton *playerBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 100, 100)];
    [playerBtn addTarget:self action:@selector(playerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [playerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playerBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [playerBtn setTitle:@"播放器示例" forState:UIControlStateNormal];
    
    
    UIButton *streamerBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 100, 100)];
    [streamerBtn addTarget:self action:@selector(streamerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [streamerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [streamerBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [streamerBtn setTitle:@"推流器示例" forState:UIControlStateNormal];
    
    
    [self.view addSubview:playerBtn];
    [self.view addSubview:streamerBtn];
}

- (void)playerBtn:(UIButton *)sender {
    UPLivePlayerDemoViewController *vc = [UPLivePlayerDemoViewController new];
    vc.title = @"播放器";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)streamerBtn:(UIButton *)sender {
    UPLiveStreamerDemoViewController *vc = [UPLiveStreamerDemoViewController new];
    vc.title = @"推流器";
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
