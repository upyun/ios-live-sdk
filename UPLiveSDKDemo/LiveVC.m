//
//  LiveVC.m
//  UPLiveSDKDemo
//  Copyright © 2017 upyun.com. All rights reserved.

#import "LiveVC.h"
#import "UPAVCapturer.h"

@interface LiveVC ()<UPAVCapturerDelegate>
{
    NSString *_streamId;
}
@property (weak, nonatomic) IBOutlet UILabel *playUrlLabel;

@end

@implementation LiveVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *deviceIdentifier = [[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString];
    _streamId = [deviceIdentifier substringFromIndex:deviceIdentifier.length - 3];
    self.playUrlLabel.text =  [NSString stringWithFormat:@"观看地址 rtmp://testlivesdk.b0.upaiyun.com/live/%@", _streamId];
}

- (void)viewDidAppear:(BOOL)animated {
    //1. 设置直播预览画面
    UIView *livePreview = [[UPAVCapturer sharedInstance] previewWithFrame:self.view.bounds
                                                              contentMode:UIViewContentModeScaleAspectFit];
    //2. 将直播画面添加到 view
    [self.view insertSubview:livePreview atIndex:0];
    
    //3. 设置代理，采集状态推流信息回调
    [UPAVCapturer sharedInstance].delegate = self;
    
    //4. 设置推流地址
    [UPAVCapturer sharedInstance].outStreamPath = [NSString stringWithFormat:@"rtmp://testlivesdk.v0.upaiyun.com/live/%@", _streamId];
    
    //6. 设置视频采集尺寸。其他详细设置请参考高级示例。
    [UPAVCapturer sharedInstance].capturerPresetLevel = UPAVCapturerPreset_640x480;
    
    //6. 开始推流
    [[UPAVCapturer sharedInstance] start];
}

- (void)viewWillDisappear:(BOOL)animated {
    //7. 结束推流
    [[UPAVCapturer sharedInstance] stop];
}

#pragma mark UPAVCapturerDelegate
- (void)capturer:(UPAVCapturer *)capturer capturerError:(NSError *)error {
    //8. 监听推流错误。
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"播放失败" message:error.description preferredStyle:1];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)capturer:(UPAVCapturer *)capturer pushStreamStatusDidChange:(UPPushAVStreamStatus)streamStatus {
    //9. 监听直播流状态。
    if (streamStatus == UPPushAVStreamStatusConnecting) {
        self.title = @"连接中";
    }

    if (streamStatus == UPPushAVStreamStatusPushing) {
        self.title = @"正在直播";
    }
}



@end
