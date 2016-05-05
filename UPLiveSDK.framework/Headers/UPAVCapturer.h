//
//  UPAVCapturer.h
//  UPAVCaptureDemo
//
//  Created by DING FENG on 3/31/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef NS_ENUM(NSInteger, UPAVCapturerLogger_level) {
    UPAVCapturerLogger_level_debug,
    UPAVCapturerLogger_level_warn,
    UPAVCapturerLogger_level_error
};

typedef NS_ENUM(NSInteger, UPAVCapturerStatus) {
    UPAVCapturerStatusLiving,
    UPAVCapturerStatusStopped,
};

typedef void(^UPAVCapturerStatusBlock)(UPAVCapturerStatus status, NSError *error);

@interface UPAVCapturer : NSObject

@property (nonatomic, strong) NSString *outStreamPath;
@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDevicePosition camaraPosition;
@property (nonatomic) BOOL camaraTorchOn;
@property (nonatomic) int64_t bitrate;
@property (nonatomic, strong) UPAVCapturerStatusBlock uPAVCapturerStatusBlock;

- (void)start;
- (void)stop;
- (void)changeCamera;

+ (UPAVCapturer *)sharedInstance;
+ (void)setLogLevel:(UPAVCapturerLogger_level)level;

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

@end

