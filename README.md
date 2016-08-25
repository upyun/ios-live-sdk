# 又拍云 iOS 推拉流 SDK 使用说明


## SDK 概述

此 `SDK` 包含__推流__和__拉流__两部分，及美颜滤镜等全套直播功能；       

此 `SDK` 中的播放器、采集器、推流器可单独使用。用户可以自主构建直播中某个环节，比如播放器（`UPAVPlayer`）可以与 Web 推流器 Flex 相配合。推流器（`UPAVStreamer`）可以配合系统自带的AVCapture 或者`GPUImage `库提供的采集功能。 


基于此 `SDK` 结合 __upyun__ 直播平台可以快速构建直播应用。
  
  
## SDK使用说明

### 运行环境和兼容性

```UPLiveSDK.framework``` 支持 `iOS 8` 及以上系统版本； 
	
支持 `ARMv7`，`ARM64`，`x86_64` 架构。

### 安装使用说明

#### 安装方法：

直接将 `UPLiveService`文件夹拖拽到目标工程目录。

```
//文件结构：

UPLiveService 文件夹
├── GPUImage              //视频处理依赖第三方库 GPUImage  
├── UPAVCapturer          //UPAVCapturer 音视频采集模块
└── UPLiveSDK.framework   //framework 包含播放器`UPAVPlayer`和推流器`UPAVStreamer`

```

#### 工程设置：     

```Enable bitcode```： NO     
 

#### 工程依赖：

`AVFoundation.framework`

`QuartzCore.framework`

`OpenGLES.framework`

`AudioToolbox.framework`

`VideoToolbox.framework`

`Accelerate.framework`

`libbz2.1.0.tbd`

`libiconv.tbd`

`libz.tbd`


***注意: 此 `SDK` 已经包含 `FFMPEG 3.0` , 不建议用户自行再添加 `FFMPEG` 库 , 如有特殊需求, 请联系我们***    


## 推流端功能特性 （采集器 ＋ 推流器）

* 集成音频和视频采集模块 `AVCaptureSession`

* 音频编码：`AAC` 

* 视频编码：`H.264`

* 支持音频，视频硬件编码

* 推流协议：`RTMP`

* 支持前后置摄像头切换

* 支持闪光灯开关

* 支持目标码率设置		

* 支持拍摄帧频设置

* 支持美颜滤镜

* 支持横屏拍摄

* 支持单音频推流

* 支持静音推流



## 播放端功能特性 （播放器）

* 支持播放直播源和点播源，支持播放本地视频文件。

* 支持视频格式：`HLS`, `RTMP`, `FLV`，`mp4` 等视频格式 
	
* 播放器支持单音频流播放，支持 speex 解码，可以配合浏览器 Flex 推流的播放 

* 低延时直播体验，配合又拍云推流 `SDK` 及 `CDN` 分发, 可以达到全程直播稳定在 `2-3` 秒延时

* 支持设置窗口大小和全屏设置

* 支持音量调节，静音设置

* 支持亮度调整

* 支持缓冲大小设置，缓冲进度回调

* 支持自动音画同步调整


## SDK下载
Demo 下载: `https://github.com/upyun/ios-live-sdk`


## 推流 SDK 使用示例 UPAVCapturer

使用__拍摄和推流__功能需要引入头文件  `#import "UPAVCapturer.h"`  

`UPAVCapturer` 是采集器，采集处理后的数据会利用 `UPAVStreamer` 进行推流；

	
	
__注:__ ``UPLiveSDK.framework``中的推流器 `UPAVStreamer`也可以单独使用。`UPAVStreamer`可以配合任何采集器来推流原始的或者经过编码压缩的音视频数据。


1.设置视频预览视图:  

```
   UIViewContentMode previewContentMode = UIViewContentModeScaleAspectFit;
   self.videoPreview = [[UPAVCapturer sharedInstance] previewWithFrame:CGRectMake(0, 0, width, height) 
   contentMode:previewContentMode];
   self.videoPreview.backgroundColor = [UIColor blackColor];
   [self.view insertSubview:self.videoPreview atIndex:0];

```

2.设置推流地址

```
	NSString *rtmpPushUrl = @"rtmp://host/liveapp/streamid";
	[UPAVCapturer sharedInstance].outStreamPath = rtmpPushUrl;

```

3.开启和关闭  

```
	//开启视频采集并推流到 rtmpPushUrl
	[[UPAVCapturer sharedInstance] start];

	//关闭视频采集，停止推流
	[[UPAVCapturer sharedInstance] stop];

```


## 拉流 SDK 使用示例 UPAVPlayer

使用 ```UPAVPlayer``` 需要引入头文件 ```#import <UPLiveSDK/UPAVPlayer.h>```

`UPAVPlayer` 使用接口类似 `AVFoundation` 的 `AVPlayer` 。

完整的使用代码请参考 `demo` 工程。

     

1.设置播放地址

```
    //初始化播放器，设置播放地址
    _player = [[UPAVPlayer alloc] initWithURL:@"rtmp://live.hkstv.hk.lxdns.com/live/hks"];

    //设置播放器画面尺寸
    [_player setFrame:[UIScreen mainScreen].bounds];
    
    //将播放器画面添加到 UIview上展示
    [self.view insertSubview:_player.playView atIndex:0];

```

2.连接、播放、暂停、停止、seek  

```
- (void)connect;//连接文件或视频流。
- (void)play;//开始播放。如果流文件未连接会自动连接视频流。
- (void)pause;//暂停播放。直播流无法暂停。
- (void)stop;//停止播放且关闭视频流。
- (void)seekToTime:(CGFloat)position;//seek 到固定播放点。直播流无法 seek。

```




## Q&A

__1.推流、拉流是什么意思？__

推流是指采集端将音视频流推送到直播服务器的过程；	
拉流是指从直播服务器获取音视频数据的过程。

__2.UPLiveSDK.framework 中的 UPAVCapturer、UPAVStreamer、UPAVPlayer 作用及之间的关系？__

UPAVPlayer 是播放器，可以播放点播或直播流；		
UPAVStreamer 是推流器，可以将音视频流推到直播服务器上;            
UPAVCapturer 是采集器负责采集录制音视频数据。	
除了 UPAVCapturer 会用到 UPAVStreamer 进行推流外，这三者可以独立使用。     	

__3.可否同时播放两条流？__ 

支持在同一个界面上放置多个 UPAVPlayer 播放器同时播放多个流。同时也可选择任一一条流静音播放。

__4.如何实现秒开，如何优化秒开？__

使用 UPAVPlayer 与又拍云的视频服务基本可以实现开播小于 0.5 秒；         
利用 UPAVPlayer 进行先连接后播放操作，结合适当的 UI 效果也可以改善视频秒开体验。        

__5.如何进行低延时优化？__

又拍云的视频服务基本可以做到直播的全过程延时小于 3 秒。           
同时可以调整 UPAVPlayer 播放器的缓冲大小，来减小播放器本地带来的延时。         

__6.耗电量多少？可否长时间直播？__

耗电量多少与不同机型及网络环境相关。对于 iphone 5s 及以上机型可以长时间推流，也不会感觉到手机发烫。
直播一小时一般电量消耗在 10％ － 20％ 范围之间。

__7.横屏拍摄和屏幕旋转问题怎么解决？__     

对于“横屏拍摄和屏幕旋转”问题的一个关键点：需要区分清楚 UI(设备)的横竖屏与镜头横竖拍摄的区别。并且拍摄开始之后“镜头横竖” 是已经固定了无法更改。具体可参考 demo 的解决方式。    

__8.直播的视频尺寸是否可以自定义？__   

最终的推流视频尺寸取决于两点：        	
	
1) 镜头采集到的图像尺寸。不同设备支持多种不同的拍摄尺寸，一般的 480x360、640x480、1280x720是各种设备及前后镜头支持最广泛的。这个参数可以通过 UPAVCapturer 的 capturerPresetLevel 属性进行修改。            

2) 剪裁图像尺寸。在采集尺寸的基础上可以通过 UPAVCapturer 的 capturerPresetLevelFrameCropRect 属性进行图像剪裁。
例如：选择 640x480 像素的镜头进行拍摄后可以再剪裁为 640x360 全屏比例图片进行直播。 


__9.可不可以仅直播声音不传图像？__     

可以。UPAVCapturer 支持单音频推流，UPAVPlayer支持单音频流的播放。 

__10.如何快速体验和测试直播？__

下载 demo 工程运行后，便可以直接进行直播测试。        

如果需要自主注册直播云服务可以参考：[UPYUN 直播平台自主配置流程](http://docs.upyun.com/live/) 



## 版本历史


__1.0.1 基本的直播推流器和播放器；__  
 
 * 播放器支持 rtmp, hls, flv;
 * 推流器支持 rtmp 推流。  
  
  
__1.0.2 性能优化，添加美颜滤镜__
 	
 * 推流添加美颜滤镜； 
 * 缩小 framework 打包体积；	
 * 修复播放器清晰度 bug；		
 * 修复播放器开始播放花屏 bug；	
 * 修改播放器卡顿重新连接逻辑；	
 * 播放器秒开优化。  
 
 
__1.0.3 点播支持__
 	
 * 播放器点播，支持暂停和 seek 功能；
 * 播放器播放、连接逻辑分离，支持异步预连接和缓冲；
 * 播放器状态 delegate 方式回调；
 * 推流器解决 iPhone 6s 音频采集引起相关的 bug；
 * 推流器横屏拍摄及屏幕旋转适配 demo。
 


__1.0.4 分析统计，拆分 UPAVStreamer__
 	
 * 播放器添加播放质量分析统计功能；     
 * 播放器添加帧频，码率等信息接口及 demo 展示；     
 * SDK 内部删除 GPUImage 依赖，美颜滤镜功能通过协议接口暴露；     
 * 推流器拆分暴露 UPAVStreamer，方便自由组织实现采集，处理，编码，推流等直播各个环节；      
 * 推流器 UPAVCapturer 状态回调改为代理方式，且细分推流状态和拍摄状态；         
 * 推流器添加拍摄帧频，推流帧频，码率，丢帧等信息接口及 demo 展示；     
 * 推流过程支持背景音乐不被打断及修复 AVAudioSession 相关bug；
 
 
__2.1 包尺寸显著减小；支持后台推流；支持浏览器 Flex 推流的播放__

* UPLiveSDK.framework 大小精简到 24M；		
* 播放器支持单音频播放；				
* 播放器支持 speex 格式解码，实现配合浏览器 Flex 推流的播放；         
* 推流支持自由剪裁像素尺寸，如 640*360 的全屏尺寸；    
* 推流支持后台推流（音频），应用退出后台推流不会中断；     
* 推流添加水印功能及 demo 展示；


__2.2 采集部分以源码展示__

* UPAVCapturer 以源码展示，方便更灵活的配置功能;
* 性能提高;
* fix bug;

__2.3 单音频推流__

* 增加播放端对 hevc (h.265) 格式的支持;
* 增加单音频推流功能;
* 增加直播静音功能;
* 增加拍摄 zoom 功能;
* 修复横屏拍摄和屏幕旋转 bug;

__2.4 __

* 采集器结构调整;
* 采集器添加更丰富的视频滤镜;
* 修复单音频点播的seek bug;
* 音频采集的处理，增益降噪等接口;
 
## 反馈与建议

 邮箱：<livesdk@upai.com>
 
 QQ: `3392887145`
 
