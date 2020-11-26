### 说明
如果对 `ReplayKit` 概念不是很清楚的, 建议看一下这篇写的很详细的文章 [iOS 10 ReplayKit Live 与 Broadcast UI/Upload Extension](http://blog.lessfun.com/blog/2016/09/21/ios-10-replaykit-live-and-broadcast-extension/) 

### 使用
[录制端](http://test654123.b0.upaiyun.com/UPLiveSDKDemo.zip) 

[被录制端](https://github.com/Mobcrush/ReplayKitDemo) 这个是测试用的 游戏的 `demo`.

要在手机上先安装录制端 `demo (UPLiveSDKDemo)`, 然后下载被录制端（即上面的 游戏 `demo` ）`build` 之后, 点击游戏中像 `Wi-Fi` 的那个按钮,选择 "UPYUN录屏验证", 然后就是等待 `Extension` 启动. 

### 相关建议

环境 `iOS 10.0` `Xcode 8.0` 以上

1. 10.1以上的系统运行比较稳定(包含 10.1), 10.0 以上也能运行, 画面显示会稍微差一点.

2. 新建的 `Broadcast Upload Extension`, 需要调整一下 `Broadcast Upload Extension` 的 `Info.plist`,  详情可以参考 demo 或者 参考推荐文章的 [评论](http://blog.lessfun.com/blog/2016/09/21/ios-10-replaykit-live-and-broadcast-extension/)

3. 注意 `Broadcast Upload Extension` 要使用 单例 , ( `demo` 里面已经写好了 `Uploader` 这个类)

4. 新建 `Broadcast Upload Extension` 的时候, 可以选上 `include UI Extension`, 这样就不用再新建 `UI Extension` 了, 创建后选 `activate`.

5. 因为 `App` 和 `Extension` 不共享代码, 新建之后 `Broadcast Upload Extension`  需要添加工程依赖 (如果已经添加了我们的 `SDK` , 文件不用重新拷贝一份, 但是 `Extension` 的依赖库还是要设置的), 添加方法可以参考 `demo`  [工程设置](https://github.com/upyun/ios-live-sdk#%E5%B7%A5%E7%A8%8B%E4%BE%9D%E8%B5%96). 

__注意__ 不支持 `bit code`。

有录屏相关的需求和问题, 欢迎联系, 我们会解答并提供相关支持 
邮箱：livesdk@upai.com
QQ:3392887145
