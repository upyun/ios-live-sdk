//
//  ViewController.m
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "ViewController.h"

#import "DemoViewControllerPlayer1.h"
#import "DemoViewControllerPlayer2.h"
#import "DemoViewControllerFullscreen.h"

#import "DemoViewControllerStreamer1.h"
#import "DemoViewControllerStreamer2.h"
#import "DemoViewControllerStreamer3.h"



#define heigth 80



@interface ViewController ()
@end

@implementation ViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *demo1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 50, 200, heigth)];
    [demo1 addTarget:self action:@selector(demo1:) forControlEvents:UIControlEventTouchUpInside];
    [demo1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [demo1 setTitle:@"player demo1" forState:UIControlStateNormal];
    
    
    UIButton *demo2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 50+heigth*1, 200, heigth)];
    [demo2 addTarget:self action:@selector(demo2:) forControlEvents:UIControlEventTouchUpInside];
    [demo2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [demo2 setTitle:@"player demo2" forState:UIControlStateNormal];
    
    UIButton *demo3 = [[UIButton alloc] initWithFrame:CGRectMake(100, 50+heigth*2, 200, heigth)];
    [demo3 addTarget:self action:@selector(demo3:) forControlEvents:UIControlEventTouchUpInside];
    [demo3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [demo3 setTitle:@"player demo3" forState:UIControlStateNormal];
    
    [self.view addSubview:demo1];
    [self.view addSubview:demo2];
    [self.view addSubview:demo3];
    
    
    UIButton *demo11 = [[UIButton alloc] initWithFrame:CGRectMake(100,  50+heigth*3, 200, heigth)];
    [demo11 setTitle:@"push stream1" forState:UIControlStateNormal];
    [demo11 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [demo11 addTarget:self action:@selector(demo11:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *demo22 = [[UIButton alloc] initWithFrame:CGRectMake(100, 50+heigth*4, 200, heigth)];
    [demo22 setTitle:@"push stream2" forState:UIControlStateNormal];
    [demo22 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [demo22 addTarget:self action:@selector(demo22:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *demo33 = [[UIButton alloc] initWithFrame:CGRectMake(100, 50+heigth*5, 200, heigth)];
    [demo33 setTitle:@"push stream3" forState:UIControlStateNormal];
    [demo33 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [demo33 addTarget:self action:@selector(demo33:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:demo11];
    [self.view addSubview:demo22];
    [self.view addSubview:demo33];
}

//播放demo1
- (void)demo1:(id)sender {
    DemoViewControllerPlayer1 *vc = [DemoViewControllerPlayer1 new];
    [self.navigationController pushViewController:vc animated:YES];
}

//播放demo2
- (void)demo2:(id)sender {
    DemoViewControllerPlayer2 *vc = [DemoViewControllerPlayer2 new];
    [self.navigationController pushViewController:vc animated:YES];
}

//播放demo3
- (void)demo3:(id)sender {
    DemoViewControllerFullscreen *vc = [DemoViewControllerFullscreen new];
    [self.navigationController pushViewController:vc animated:YES];
}

//推流demo11
- (void)demo11:(UIButton *)sender {
    DemoViewControllerStreamer1 *demo1 = [[DemoViewControllerStreamer1 alloc] init];
    [self presentViewController:demo1 animated:YES completion:nil];
}

//推流demo22
- (void)demo22:(UIButton *)sender {
    DemoViewControllerStreamer2 *demo2 = [[DemoViewControllerStreamer2 alloc] init];
    [self presentViewController:demo2 animated:YES completion:nil];
}

//推流demo33
- (void)demo33:(UIButton *)sender {
    DemoViewControllerStreamer3 *demo3 = [[DemoViewControllerStreamer3 alloc] init];
    [self presentViewController:demo3 animated:YES completion:nil];
}

@end
