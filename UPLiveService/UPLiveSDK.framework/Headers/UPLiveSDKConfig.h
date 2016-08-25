//
//  UPLiveSDKConfig.h
//  UPLiveSDKLib
//
//  Created by DING FENG on 6/29/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Version @"2.3"

typedef NS_ENUM(NSInteger, UPLiveSDKLogger_level) {
    UP_Level_debug,
    UP_Level_warn,
    UP_Level_error
};

@interface UPLiveSDKConfig : NSObject

+ (void)setLogLevel:(UPLiveSDKLogger_level)level;
+ (void)setStatistcsOn:(BOOL)onOff;//播放质量统计功能，默认开

@end


