//
//  UPAVPlayerLogger.h
//  UPAVPlayerDemo
//
//  Created by DING FENG on 2/23/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>



#define  logActiveTags           (Tag_stream + Tag_video + Tag_audio + Tag_default)


typedef NS_ENUM(NSInteger, UPLiveSDKLogger_level) {
    Level_debug,
    Level_warn,
    Level_error
};

UPLiveSDKLogger_level log_level_limit  = Level_warn;

typedef NS_ENUM(NSInteger, UPLiveSDKLogger_tag) {
    Tag_stream = 1 << 0,
    Tag_video  = 1 << 1,
    Tag_audio  = 1 << 2,
    Tag_default  = 1 << 3,
};

@interface UPLiveSDKLogger : NSObject

+ (void)log:(NSString *)message level:(UPLiveSDKLogger_level)level tag:(UPLiveSDKLogger_tag)tag;
+ (void)setLogLevel:(UPLiveSDKLogger_level)level;

@end
