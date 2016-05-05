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

#define Version @"1.0.0"

typedef NS_ENUM(NSInteger, UPAVPlayerLogger_level) {
    UPAVPlayerLogger_level_debug,
    UPAVPlayerLogger_level_warn,
    UPAVPlayerLogger_level_error
};

typedef NS_ENUM(NSInteger, UPAVPlayerStatus) {
    UPAVPlayerStatusIdle,
    UPAVPlayerStatusPlaying_buffering,
    UPAVPlayerStatusPlaying,
    UPAVPlayerStatusFailed
};

typedef void(^PlayerStadusBlock)(UPAVPlayerStatus playerStatus, NSError *error);
typedef void(^BufferingProgressBlock)(float progress);

@interface UPAVPlayer : NSObject

@property (nonatomic, strong, readonly) UPEAGLView *playView;
@property (nonatomic, strong, readonly) NSDictionary *videoInfo;
@property (nonatomic, strong) PlayerStadusBlock playerStadusBlock;
@property (nonatomic, strong) BufferingProgressBlock bufferingProgressBlock;
@property (nonatomic) NSTimeInterval bufferingTime;//(1s -- 10s)
@property (nonatomic) CGFloat volume;
@property (nonatomic) CGFloat bright;
@property (nonatomic) BOOL mute;
@property (nonatomic) BOOL fullScreen;
@property (nonatomic) NSUInteger bitrateLevel;
@property (nonatomic) BOOL autoChangeBitrate;
@property (nonatomic) NSTimeInterval bufferingTimeOutLimit;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *bandwidth;

- (instancetype)initWithURL:(NSString *)url;
- (void)setImageURL:(NSString *)url;
- (void)setFrame:(CGRect)frame;
- (void)play;
- (void)stop;
- (void)configChoppyRetryMaxCount:(NSInteger)maxCount inTimeScope:(NSTimeInterval)timeScope;

+ (void)setLogLevel:(UPAVPlayerLogger_level)level;

@end
