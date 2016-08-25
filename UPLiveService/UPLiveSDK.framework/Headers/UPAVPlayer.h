//
//  UPAVPlayer.h
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UPLiveSDKConfig.h"



typedef NS_ENUM(NSInteger, UPAVPlayerStatus) {
    UPAVPlayerStatusIdle,
    UPAVPlayerStatusPlaying_buffering,
    UPAVPlayerStatusPlaying,
    UPAVPlayerStatusPause,
    UPAVPlayerStatusFailed
};

typedef NS_ENUM(NSInteger, UPAVStreamStatus) {
    UPAVStreamStatusIdle,
    UPAVStreamStatusConnecting,
    UPAVStreamStatusReady,
};

typedef void(^PlayerStadusBlock)(UPAVPlayerStatus playerStatus, NSError *error);
typedef void(^BufferingProgressBlock)(float progress);


@interface UPAVPlayerStreamInfo : NSObject
@property (nonatomic) float duration;
@property (nonatomic) BOOL canPause;
@property (nonatomic) BOOL canSeek;
@property (nonatomic, strong) NSDictionary *descriptionInfo;
@end

@interface UPAVPlayerDashboard: NSObject
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSString *serverIp;
@property (nonatomic, readonly) NSString *serverName;
@property (nonatomic, readonly) int cid;
@property (nonatomic, readonly) int pid;
@property (nonatomic, readonly) float fps;
@property (nonatomic, readonly) float bps;
@property (nonatomic, readonly) int vCachedFrames;
@property (nonatomic, readonly) int aCachedFrames;
@end


@class UPAVPlayer;

@protocol UPAVPlayerDelegate <NSObject>
//播放器状态
- (void)UPAVPlayer:(UPAVPlayer *)player playerStatusDidChange:(UPAVPlayerStatus)playerStatus;
- (void)UPAVPlayer:(UPAVPlayer *)player playerError:(NSError *)error;
- (void)UPAVPlayer:(UPAVPlayer *)player displayPositionDidChange:(float)position;
- (void)UPAVPlayer:(UPAVPlayer *)player bufferingProgressDidChange:(float)progress;

//视频流状态
- (void)UPAVPlayer:(UPAVPlayer *)player streamStatusDidChange:(UPAVStreamStatus)streamStatus;
- (void)UPAVPlayer:(UPAVPlayer *)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo;
@end



@interface UPAVPlayer : NSObject

@property (nonatomic, strong, readonly) UIView *playView;
@property (nonatomic, strong, readonly) UPAVPlayerDashboard *dashboard;
@property (nonatomic, strong, readonly) UPAVPlayerStreamInfo *streamInfo;
@property (nonatomic, assign, readonly) UPAVPlayerStatus playerStatus;
@property (nonatomic, assign, readonly) UPAVStreamStatus streamStatus;

@property (nonatomic, assign) NSTimeInterval bufferingTime;//(0.1s -- 10s)
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) CGFloat bright;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) NSUInteger bitrateLevel;
@property (nonatomic, assign) NSTimeInterval bufferingTimeOutLimit;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign, readonly) float displayPosition;//视频播放到的时间点
@property (nonatomic, assign, readonly) float streamPosition;//视频流读取到的时间点
@property (nonatomic, weak) id<UPAVPlayerDelegate> delegate;
@property (nonatomic) BOOL lipSynchOn;//音画同步，默认值 YES


- (instancetype)initWithURL:(NSString *)url;
- (void)setFrame:(CGRect)frame;
- (void)connect;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(CGFloat)position;

@end
