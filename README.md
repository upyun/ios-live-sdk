# 又拍云 iOS 直播 SDK(动态库) 使用说明         
***注: 从4.0.0 版本之后 SDK 改为了动态库形式.***


## 1 SDK 概述     

此 ```SDK``` 包含推流和拉流两部分，支持美颜滤镜、水印、连麦等全套直播功能。     
```50``` 行代码即可开始直播，结合 ```UPYUN直播平台``` 可以快速构建直播应用。

[UPYUN 直播平台自主配置流程](http://docs.upyun.com/live/) 

  
## 2 SDK使用说明

### 2.1 运行环境和兼容性

```UPLiveSDKDll.framework``` 支持 `iOS 8` 及以上系统版本；     
支持 `ARMv7`，`ARM64` 架构。请使用真机进行开发和测试。     

```UPLiveSDKDll.framework``` 接口支持 Swift 3 调用，参考 [DemoSwift3](http://test86400.b0.upaiyun.com/iossdk/UPLiveSDkDemoSwift3.zip) 。 

### 2.2 安装使用说明

	
#### 手动安装方法：

直接将 `UPLiveService`文件夹拖拽到目标工程目录。

```
//文件结构：

UPLiveService 文件夹
├── GPUImage                 //视频处理依赖第三方库 GPUImage  
├── UPAVCapturer             //UPAVCapturer 音视频采集模块, 直播接口。
└── UPLiveSDKDll.framework   //framework 包含播放器`UPAVPlayer`和推流器`UPAVStreamer`

```

#### 2.3 工程设置：     

```TARGET -> Build Settings -> Enable bitcode```： 设置为 NO  			


```TARGET -> General -> Embedded Binaries```： 添加选择 UPLiveSDKDll.framework



***注: 如果需要 app 退出后台仍然不间断推流直播，需要设置 ```TARGET -> Capabilities -> Backgroud Modes:ON    √ Audio, AirPlay,and Picture in Picture```***	



#### 2.4 工程依赖：

`AVFoundation.framework`

`QuartzCore.framework`

`OpenGLES.framework`

`AudioToolbox.framework`

`VideoToolbox.framework`

`Accelerate.framework`

`libbz2.1.0.tbd`

`libiconv.tbd`

`libz.tbd`

`CoreMedia.framework`

`CoreTelephony.framework`

`SystemConfiguration.framework`

`libc++.tbd`

`CoreMotion.framework`



***注: 此 `SDK` 已经包含 `FFMPEG 3.0` , 不建议自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***       


## 3 功能特性

### 3.1 推流端功能特性 （采集器 ＋ 推流器）


* 音频编码：`AAC` 

* 视频编码：`H.264`

* 支持音频，视频硬件编码

* 推流协议：`RTMP`

* 支持前后置摄像头切换

* 支持目标码率设置		

* 支持拍摄帧频设置

* 支持美颜滤镜

* 支持横屏拍摄

* 支持单音频推流

* 支持静音推流	

* 支持连麦推流



### 3.2 播放端功能特性 （播放器）

* 支持播放直播源和点播源，支持播放本地视频文件。

* 支持视频格式：`HLS`, `RTMP`, `FLV`，`mp4` 等视频格式 
	
* 播放器支持单音频流播放，支持 speex 解码，可以配合浏览器 Flex 推流的播放 

* 低延时直播体验，配合又拍云推流 `SDK` 及 `CDN` 分发, 可以达到全程直播稳定在 `2-3` 秒延时

* 支持设置窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调

* 支持自动音画同步调整


## 4 SDK下载
Demo 下载: `https://github.com/upyun/ios-live-sdk`


## 5 使用示例 

___具体使用示例，请参考 demo 工程的 ```基础使用示例 ```部分，```50行代码``` 即可以开启直播和播放。
高级设置和使用请参考 demo 工程的 ```高级设置使用示例 ```部分。___

### 5.1 推流使用示例 UPAVCapturer

使用**拍摄和推流**功能需要引入头文件  `#import "UPAVCapturer.h"`。`UPAVCapturer` 负责采集视频再经过 `UPAVStreamer` 进行推流直播,``UPLiveSDKDll.framework``中的推流器 `UPAVStreamer`也可以单独使用。`UPAVStreamer`可以配合任何采集器来推流原始或压缩的音视频数据。


``` 
    //1. 设置预览画面
    UIView *livePreview = [[UPAVCapturer sharedInstance] previewWithFrame:self.view.bounds
                                                              contentMode:UIViewContentModeScaleAspectFit];
    //2. 将预览画面添加到 view
    [self.view insertSubview:livePreview atIndex:0];
    
    //3. 设置代理，接收直播状态回调
    [UPAVCapturer sharedInstance].delegate = self;
    
    //4. 设置推流地址
    [UPAVCapturer sharedInstance].outStreamPath = [NSString stringWithFormat:@"rtmp://testlivesdk.v0.upaiyun.com/live/%@", _streamId];
    
    //6. 设置视频采集尺寸。其他详细设置请参考高级示例。
    [UPAVCapturer sharedInstance].capturerPresetLevel = UPAVCapturerPreset_640x480;
    
    //6. 开始推流
    [[UPAVCapturer sharedInstance] start];

    //7. 结束推流
    [[UPAVCapturer sharedInstance] stop];

```


### 5.2 拉流使用示例 UPAVPlayer

使用 ```UPAVPlayer``` 需要引入头文件 ```#import <UPLiveSDKDll/UPAVPlayer.h>```

`UPAVPlayer` 使用接口类似 `AVFoundation` 的 `AVPlayer` 。

```
    //1. 初始化播放器
    _player = [[UPAVPlayer alloc] initWithURL:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];
    
    //2. 设置代理，接收状态回调信息
    _player.delegate = self;
    
    //3. 设置播放器 playView Frame
    [_player setFrame:self.view.bounds];
    
    //4. 添加播放器 playView
    [self.view insertSubview:_player.playView atIndex:0];
    
    //5. 开始播放
    [_player play];

    //6. 停止播放
    [_player stop];

```

__[注1]__  如果需要在产品中正式使用连麦功能，请联系申请 ``` rtc appid ```, 可以参考 ``` README_rtc.md ``` 熟悉连麦直播流程。

__[注2]__  单音频推流与连麦, 只需要在连麦或推流时设置 ```[UPAVCapturer sharedInstance].audioOnly = YES;``` 即可。

__[注3]__  可以通过 ```[UPAVCapturer sharedInstance].streamingOn``` 开关，来实现先预览再推流的逻辑。

__[注4]__  如果确定有视频流, 而拉流的时候出现黑屏,可以设置```player.hasVideo = YES``` 来开启强制创建视频流信息。



## 6 版本历史 

[历史版本：https://github.com/upyun/ios-live-sdk/releases](https://github.com/upyun/ios-live-sdk/releases)
 
## 7 反馈与建议

 邮箱：<livesdk@upai.com>
 
 QQ: `200576786`
 


