#又拍云 iOS 推拉流 SDK 使用说明

## 阅读对象

本文档面向 `iOS` 移动视频直播应用开发者。

## SDK 概述

此 `SDK` 实现了视频直播和播放两部分功能。开发者可以在应用内集成此 `SDK` 来快速实现视频推流（直播）和拉流（播放）功能。
  
***支持 `ARMv7`，`ARM64`，`x86_64` 架构***

***注意: `SDK` 依赖于 `FFMPEG 3.0` , 不建议用户自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***  

## 推流端功能特性

* 集成音频和视频采集模块 `AVCaptureSession`

* 音频编码：`AAC` 

* 视频编码：`H.264`

* 支持音频，视频硬件编码

* 推流协议：`RTMP`

* 支持前后置摄像头切换

* 支持闪光灯开关

* 支持音视频目标码率设置

## 播放端功能特性

* 支持视频格式：`HLS`, `RTMP`, `HTTP-FLV` 等，支持 `HLS` 多种分辨率切换

* 低延时直播体验，配合又拍云推流 `SDK`, 可以达到全程直播稳定在 2-3 秒延时；

* 支持设置窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调


##SDK下载
Demo 下载: `https://github.com/upyun/ios-live-sdk`

##SDK使用说明

* 运行环境和兼容性

```UPLiveSDK.framework``` 支持 `iOS 8` 及以上系统版本； 

* 安装使用说明

 安装方法：直接将 ``UPLiveSDK.framework`` 拖拽到目标工程目录；

 

 工程设置：     

```Enable bitcode```： NO     

```Framework Search Paths``` :  添加 `$(PROJECT_DIR)`, 并设置为 `recursive` 

    

   

工程依赖：

`AVFoundation.framework`

`QuartzCore.framework`

`OpenGLES.framework`

`AudioToolbox.framework`

`VideoToolbox.framework`

`Accelerate.framework`

`libbz2.1.0.tbd`

`libiconv.tbd`

`libz.tbd`


  

## 推流 SDK 使用示例 UPAVCapturer

使用推流功能 `UPAVCapturer` 需要引入头文件  `#import <UPLiveSDK/UPAVCapturer.h>`   

`UPAVCapturer` 为单例模式。

1.简单的使用:  

```

	[UPAVCapturer sharedInstance].outStreamPath  = @"pushurl";

	AVCaptureVideoPreviewLayer *_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[UPAVCapturer sharedInstance].captureSession];

    _previewLayer.frame = CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.width);

    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    [self.view.layer addSublayer:_previewLayer];

    [[UPAVCapturer sharedInstance] start];

```

2.设置推流地址

```
	
	NSString *rtmpPushUrl = @"pushurl";
	
	[UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;

```

3.开启和关闭  

```

	//开启视频采集并推流到 rtmpPushUrl

	[[UPAVCapturer sharedInstance] start];

	//关闭视频采集，停止推流

	[[UPAVCapturer sharedInstance] stop];

```

4.设置预览画面   

将 `[UPAVCapturer sharedInstance].captureSession` 赋值给 `AVCaptureVideoPreviewLayer` 对象。完整代码请参考 demo 工程。

```

- (void)setPreview {

    [_previewLayer removeFromSuperlayer];

    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[UPAVCapturer sharedInstance].captureSession];

    _previewLayer.frame = CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.width);

    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;     

    [self.view.layer addSublayer:_previewLayer];

}

```

5.摄像头切换接口, 闪光灯设置接口 

```

    [[UPAVCapturer sharedInstance] changeCamera];//切换前后摄像头

    

    [UPAVCapturer sharedInstance].camaraTorchOn ＝ YES;//设置闪光灯开关

    

``` 

6.码率设置接口

可以根据网络情况适当调整码率：

```

    [UPAVCapturer sharedInstance].bitrate = 400000;//默认值 600000 bps

```

7.推流状态回调

如果在直播过程发生异常，可以通过 `uPAVCapturerStatusBlock` 捕捉错误信息，并且关闭采集和推流。__注意：__uPAVCapturerStatusBlock 不保证在主线程执行。

```

    [UPAVCapturer sharedInstance].uPAVCapturerStatusBlock = ^(UPAVCapturerStatus status, NSError *error) {

        if (error) {

        //错误通知

        //关闭推流

        //如果需要操作 UI，需要切换到主线程

        }

    };

```

##拉流 SDK 使用示例 UPAVPlayer

使用 ```UPAVPlayer``` 需要引入头文件 ````#import <UPLiveSDK/UPAVPlayer.h>```

`UPAVPlayer` 使用接口类似 `AVFoundation` 的 `AVPlayer`。

完整的使用代码请参考 `demo` 工程。

     

1.简单的使用:  

```

	UPAVPlayer *player = [[UPAVPlayer alloc] initWithURL:@"playurl"];  

	[player setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width)];

	[self.view addSubview:player.playView atIndex:0];

	[player play];

	[player stop];

```     

2.设置播放地址

```

    //初始化播放器，设置播放地址
    _player = [[UPAVPlayer alloc] initWithURL:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];

    //设置播放器画面尺寸
    [_player setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.width)];

    
    //将播放器画面添加到 UIview上展示
    [self.view insertSubview:_player.playView atIndex:0];

```

3.视频流基本信息 

```
	//播放流的基本信息
    NSString *message = [NSString stringWithFormat:@"Stream Info:\n %@", _player.videoInfo];

```

4.播放状态回调 

```

    __weak DemoViewController1 *weakself = self;

    _player.playerStadusBlock = ^(UPAVPlayerStatus playerStatus, NSError *error){

        switch (playerStatus) {

            case UPAVPlayerStatusIdle:{
				// 未进行播放
            }

                break;

            case UPAVPlayerStatusPlaying_buffering:{
                // 缓存中
            }

                break;

            case UPAVPlayerStatusPlaying:{
                // 播放中
            }

                break;

            case UPAVPlayerStatusFailed:{
               // 播放失败
            }

                break;

            default:

                break;

        }

    };

```

5.缓冲进度回调，缓冲时间设置

```

    //缓冲进度回调

    _player.bufferingProgressBlock = ^(float progress) {

        weakself.bufferingProgressLabel.text = [NSString stringWithFormat:@"%.0f %%", (progress * 100)];

    };

    //缓冲时间设置

    _player.bufferingTime = 2;

```

6.音量设置

```
@property (nonatomic) CGFloat volume;

``` 

7.画面亮度  

```

@property (nonatomic) CGFloat bright;

```

8.静音设置  

```

@property (nonatomic) BOOL mute;

```

9.设置播放窗口大小设置  

```

- (void)setFrame:(CGRect)frame;

```

10.全屏设置 

```

@property (nonatomic) BOOL fullScreen;

``` 

11.开始和停止播放  

```

- (void)play;

- (void)stop;

```

## UPYUN 直播平台自主配置流程

**1.注册新建又拍云账号**  

[注册地址](https://console.upyun.com/#/register/)  

**2.进行账户认证**  

[账户认证](https://console.upyun.com/#/account/profile/)  

**3.创建服务**  

[创建服务](https://console.upyun.com/#/services/)  

填写服务名称，简称 `bucket`  

资源获取方式选择自主源站  

加速域名和回源地址如有则填写，如无可以任意编辑结构合法内容，如域名为 `a.com`，回源 `IP` 为 `1.1.1.1`  

创建好服务后如需进行直播功能测试和加速，会有对应的服务人员与您联系，您将需求按如下格式整理好发送给服务人员，我们会尽快为您提供测试服务

格式如下  

账户名：`xxxxx`  

服务名称：`bucket` 名

`app` 名：如 `show/*`  `show` 代表应用名称，`*` 代表目录后可以为 `stream id`

拉流需要支持的格式：`rtmp` 或 `http-flv` 或 `hls` (三个至少选其中一个)  

对外服务的推流域名：`xxx.com` （如无可不填写）  

对外服务的拉流域名：`xxx.com` （如无可不填写）  

**4.推拉流地址格式以及 token 加密规则**  

推流地址：`rtmp://bucket.v0.upaiyun.com/show/abc`  

拉流地址：`rtmp` 协议  `rtmp://bucket.b0.upaiyun.com/show/abc` ,
`http+flv`  `http://bucket.b0.upaiyun.com/show/abc.flv` , `hls`       `http://bucket.b0.upaiyun.com/show/abc.m3u8` 

**Token 防盗链加密规则** 

`Token` 防盗链可设置签名过期时间来控制文件的访问时限  

**url格式**：  

推流地址：`rtmp://bucket.v0.upaiyun.com/show/abc?_upt=abcdefgh137000060`  

拉流地址：`http://bucket.b0.upaiyun.com/show/abc.flv?_upt=abcdefgh137000060`   

**签名方式说明**  

**签名**：`_upt = MD5( token密匙 + etime + URI) {中间 8 位} + etime` 

加密后格式如下 `_upt=abcdefgh1370000600` 



**参数**：  

`token` 密钥：用户所填的密钥(一个 `bucket` 对应一个密钥)  

`etime` ：过期时间，必须是 UNIX TIME 格式，如： `1378092990`  

`URI` ：请求地址（不包含?及后面的 Query String），如： `/live/abc`    


**正确例子**: 

密钥 : `password`

etime : `1462513671`

URI : `/live/streamhz`

密钥 + etime + URI 拼接结果 :  `password1462513671/live/streamhz`

md5 之后： `cd07624363efbcc102e772c2e270e811`

取中间 8 位加 `etime` ：`bcc102e71462513671` 

最后 url ： `url`

**由 SDK 生成 TOKEN**

```

/* 生成推流 token
 例如推流地址：rtmp://bucket.v0.upaiyun.com/live/abc?_upt=abcdefgh1370000600
 其中：
 bucket 为 bucket name；
 live 为 appName；
 abc 为 streamName；
 abcdefgh1370000600 为推流token 可以用此方法计算生成。
 */
+ (NSString *)tokenWithKey:(NSString *)key //空间密钥
                    bucket:(NSString *)bucket //空间名
                expiration:(int)expiration //token 过期时间
           applicationName:(NSString *)appName //应用名，比如示例推流地址中的 live
                streamName:(NSString *)streamName; //流名， 比如示例推流地址中的 abc
                
```

##反馈与建议

 邮箱：<livesdk@upai.com>
 
 QQ: `3392887145`
