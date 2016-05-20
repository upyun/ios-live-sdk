//
//  UPLiveStreamerLivingVC.m
//  UPLiveSDKDemo
//
//  Created by DING FENG on 5/19/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPLiveStreamerLivingVC.h"
#import <UPLiveSDK/UPAVCapturer.h>


@interface UPLiveStreamerLivingVC ()

{
    
    AVCaptureVideoPreviewLayer *_previewLayer;
}
@property (weak, nonatomic) IBOutlet UISwitch *filterSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *streamingSwitch;

@property (weak, nonatomic) IBOutlet UISwitch *flashSwitch;


@end

@implementation UPLiveStreamerLivingVC

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *preview = [[UPAVCapturer sharedInstance] previewWithFrame:[UIScreen mainScreen].bounds contentMode:UIViewContentModeScaleAspectFill];
    preview.backgroundColor = [UIColor blackColor];
    [self.view insertSubview:preview atIndex:0];
    
    [UPAVCapturer setLogLevel:UPAVCapturerLogger_level_debug];
    __weak UPLiveStreamerLivingVC *weakself = self;
    [UPAVCapturer sharedInstance].uPAVCapturerStatusBlock = ^(UPAVCapturerStatus status, NSError *error) {
        if (error) {
            NSString *s = [NSString stringWithFormat:@"%@", error];
            [weakself errorAlert:s];
        }
    };
}

- (void)viewWillAppear:(BOOL)animated {
    self.filterSwitch.on = _settings.filter;
    self.streamingSwitch.on = _settings.streamingOnOff;
    self.flashSwitch.on = _settings.camaraTorchOn;
}

- (void)viewDidAppear:(BOOL)animated {
    [self start];
}

- (void)start {
    [[UPAVCapturer sharedInstance] stop];
    [UPAVCapturer sharedInstance].level = _settings.level;
    [UPAVCapturer sharedInstance].camaraPosition = _settings.camaraPosition;
    [UPAVCapturer sharedInstance].streamingOnOff = _settings.streamingOnOff;
    [UPAVCapturer sharedInstance].filter = _settings.filter;
    [UPAVCapturer sharedInstance].filterLevel = _settings.filterLevel ;
    [UPAVCapturer sharedInstance].camaraTorchOn = _settings.camaraTorchOn;
    
    //推流地址
    NSString *rtmpPushUrl = [NSString stringWithFormat:@"%@%@", _settings.rtmpServerPushPath, _settings.streamId];
    
    //计算 upToken
    NSString *upToken = [UPAVCapturer tokenWithKey:@"password"
                                            bucket:@"testlivesdk"
                                        expiration:86400
                                   applicationName:@"live"
                                        streamName:@"streamhz"];
    
    rtmpPushUrl = [NSString stringWithFormat:@"%@?_upt=%@", rtmpPushUrl, upToken];
    NSLog(@"rtmpPushUrl: %@", rtmpPushUrl);
    [UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;
    [[UPAVCapturer sharedInstance] start];
}


- (IBAction)streamingSwitch:(id)sender {
    [UPAVCapturer sharedInstance].streamingOnOff = ![UPAVCapturer sharedInstance].streamingOnOff;
}

- (IBAction)filterSwitch:(id)sender {
    [UPAVCapturer sharedInstance].filter = ![UPAVCapturer sharedInstance].filter;
}

- (IBAction)flashSwitch:(id)sender {
    
    [UPAVCapturer sharedInstance].camaraTorchOn = ![UPAVCapturer sharedInstance].camaraTorchOn ;
}

- (IBAction)stop:(id)sender {
    [[UPAVCapturer sharedInstance] stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)errorAlert:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^(){
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"推流错误，请检查网络重试，或者更换一个流id后重试"
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


@end
