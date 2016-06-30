//
//  UPAVFrame.h
//  UPLiveSDKLib
//
//  Created by DING FENG on 6/17/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef enum {
    UPAVFrameTypeAudio,
    UPAVFrameTypeVideo,
    UPAVFrameTypeArtwork,
    UPAVFrameTypeSubtitle,
} UPAVFrameType;

typedef enum {
    UPVideoFrameFormatRGB,
    UPVideoFrameFormatYUV,
} UPVideoFrameFormat;



@interface UPAVFrame : NSObject
@property (nonatomic) UPAVFrameType type;
@property (nonatomic) CGFloat position;
@property (nonatomic) CGFloat duration;
@end

@interface UPAudioFrame : UPAVFrame
@property (nonatomic, strong) NSData *samples;
@end

@interface UPVideoFrame : UPAVFrame
@property (nonatomic) UPVideoFrameFormat format;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;
@end

@interface UPVideoFrameRGB : UPVideoFrame
@property (nonatomic) NSUInteger linesize;
@property (nonatomic, strong) NSData *rgb;
@end

@interface UPVideoFrameYUV : UPVideoFrame
@property (nonatomic, strong) NSData *luma;
@property (nonatomic, strong) NSData *chromaB;
@property (nonatomic, strong) NSData *chromaR;
@end

@interface UPArtworkFrame : UPAVFrame
@property (nonatomic, strong) NSData *picture;
@end

@interface UPSubtitleFrame : UPAVFrame
@property (nonatomic, strong) NSString *text;
@end
