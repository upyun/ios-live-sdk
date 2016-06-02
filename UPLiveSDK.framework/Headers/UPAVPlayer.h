//
//  UPAVPlayer.h
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/16/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UPEAGLView.h"
#import "UPLiveSDKLogger.h"

#define Version @"1.0.3"


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


@class UPAVPlayer;

@protocol UPAVPlayerDelegate <NSObject>

- (void)UPAVPlayer:(UPAVPlayer *)player playerStatusDidChange:(UPAVPlayerStatus)playerStatus;
- (void)UPAVPlayer:(UPAVPlayer *)player playerError:(NSError *)error;
- (void)UPAVPlayer:(UPAVPlayer *)player displayPositionDidChange:(float)position;
- (void)UPAVPlayer:(UPAVPlayer *)player bufferingProgressDidChange:(float)progress;

- (void)UPAVPlayer:(UPAVPlayer *)player streamStatusDidChange:(UPAVStreamStatus)streamStatus;
- (void)UPAVPlayer:(UPAVPlayer *)player streamInfoDidReceive:(UPAVPlayerStreamInfo *)streamInfo;
@end


@interface UPAVPlayer : NSObject

@property (nonatomic, strong, readonly) UPEAGLView *playView;

@property (nonatomic, assign) BOOL interrupted;

@property (nonatomic, strong) UPAVPlayerStreamInfo *streamInfo;
@property (nonatomic, strong) PlayerStadusBlock playerStadusBlock;
@property (nonatomic, strong) BufferingProgressBlock bufferingProgressBlock;
@property (nonatomic, assign) NSTimeInterval bufferingTime;//(1s -- 10s)
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) CGFloat bright;
@property (nonatomic, assign) BOOL mute;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) NSUInteger bitrateLevel;
@property (nonatomic, assign) BOOL autoChangeBitrate;
@property (nonatomic, assign) NSTimeInterval bufferingTimeOutLimit;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *bandwidth;
@property (nonatomic, assign) float displayPosition;// 视频播放到的时间点
@property (nonatomic, assign) float streamPosition;// 视频流读取到的时间点
@property (nonatomic, weak) id<UPAVPlayerDelegate> delegate;

- (instancetype)initWithURL:(NSString *)url;
- (void)setImageURL:(NSString *)url;
- (void)setFrame:(CGRect)frame;
- (void)connect;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(CGFloat)position;
- (void)configChoppyRetryMaxCount:(NSInteger)maxCount inTimeScope:(NSTimeInterval)timeScope;

+ (void)setLogLevel:(UPLiveSDKLogger_level)level;
@end
