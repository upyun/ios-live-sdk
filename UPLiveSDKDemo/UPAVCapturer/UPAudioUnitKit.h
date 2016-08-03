//
//  UPAudioUnitKit.h
//  Test_audioUnitRecorderAndPlayer
//
//  Created by DING FENG on 7/20/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

typedef NS_ENUM(NSInteger, UPAudioUnitCategory) {
    UPAudioUnitCategory_recorder,
    UPAudioUnitCategory_player,
    UPAudioUnitCategory_recorderAndplayer
};



@protocol UPAudioUnitKitProtocol <NSObject>
- (void)didReceiveBuffer:(AudioBuffer)audioBuffer info:(AudioStreamBasicDescription)asbd;
@end

@interface UPAudioUnitKit : NSObject

@property (nonatomic, weak) id<UPAudioUnitKitProtocol> delegate;

- (id)initWith:(UPAudioUnitCategory)category;
- (void)start;
- (void)stop;

@end
