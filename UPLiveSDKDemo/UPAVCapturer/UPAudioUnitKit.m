//
//  UPAudioUnitKit.m
//  Test_audioUnitRecorderAndPlayer
//
//  Created by DING FENG on 7/20/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPAudioUnitKit.h"

#define kBusOutput 0
#define kBusInput 1

#define KDefaultChannelsNum 1

@interface UPAudioUnitKit()
@property (nonatomic) AudioComponentInstance audioUnit;
@property (nonatomic) AudioBuffer tempBuffer;
@property (nonatomic) UPAudioUnitCategory category;
@property (nonatomic) AudioStreamBasicDescription audioFormat;


- (void)processAudio:(AudioBufferList *)bufferList;
@end

void checkOSStatus(int status){
    if (status) {
        printf("Status not 0! %d\n", status);
    }
}

/**
 This callback is called when new audio data from the microphone is available.
 */
static OSStatus audioRecordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
    
    @autoreleasepool {
        UPAudioUnitKit *iosAudio = (__bridge UPAudioUnitKit *)inRefCon;
        AudioBuffer buffer;
        
        buffer.mNumberChannels = KDefaultChannelsNum;
        buffer.mDataByteSize = inNumberFrames * 2 * KDefaultChannelsNum;
        buffer.mData = malloc( inNumberFrames * 2 * KDefaultChannelsNum);
        
        // Put buffer in a AudioBufferList
        AudioBufferList bufferList;
        bufferList.mNumberBuffers = 1;
        bufferList.mBuffers[0] = buffer;
        
        OSStatus status;
        
        status = AudioUnitRender(iosAudio.audioUnit,
                                 ioActionFlags,
                                 inTimeStamp,
                                 inBusNumber,
                                 inNumberFrames,
                                 &bufferList);
        checkOSStatus(status);
        [iosAudio processAudio:&bufferList];
        free(bufferList.mBuffers[0].mData);
        
        return noErr;
    }
}

/**
 This callback is called when the audioUnit needs new data to play through the speakers.
 */
static OSStatus audioPlaybackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData) {
    @autoreleasepool {
        UPAudioUnitKit *iosAudio = (__bridge UPAudioUnitKit *)inRefCon;
        for (int i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
            UInt32 size = MIN(buffer.mDataByteSize, [iosAudio tempBuffer].mDataByteSize);
            memcpy(buffer.mData, [iosAudio tempBuffer].mData, size);
            buffer.mDataByteSize = size;
        }
        return noErr;
    }
}


@implementation UPAudioUnitKit


- (id)initWith:(UPAudioUnitCategory)category {
    self = [super init];
    if (self) {
        self.category = category;
        [self setup];
        
    }
    return self;
}

- (void)setup {
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
    
    checkOSStatus(status);
    
    // Enable IO for recording
    UInt32 flag_recording = 1;
    UInt32 flag_player = 1;

    if (self.category == UPAudioUnitCategory_player) {
        flag_recording = 0;
    }
    if (self.category == UPAudioUnitCategory_recorder) {
        flag_player = 0;
    }

    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kBusInput,
                                  &flag_recording,
                                  sizeof(flag_recording));
    checkOSStatus(status);
    
    // Enable IO for playback
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kBusOutput,
                                  &flag_player,
                                  sizeof(flag_player));
    checkOSStatus(status);
    
    _audioFormat.mSampleRate		= 44100.00;
    _audioFormat.mFormatID			= kAudioFormatLinearPCM;
    _audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _audioFormat.mFramesPerPacket	= 1;
    _audioFormat.mChannelsPerFrame	= KDefaultChannelsNum;
    _audioFormat.mBitsPerChannel		= 16;
    _audioFormat.mBytesPerPacket		= 2 * KDefaultChannelsNum;
    _audioFormat.mBytesPerFrame		= 2 * KDefaultChannelsNum;
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kBusInput,
                                  &_audioFormat,
                                  sizeof(_audioFormat));
    checkOSStatus(status);
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kBusOutput,
                                  &_audioFormat,
                                  sizeof(_audioFormat));
    checkOSStatus(status);
    
    
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = audioRecordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kBusInput,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkOSStatus(status);
    
    callbackStruct.inputProc = audioPlaybackCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kBusOutput,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    checkOSStatus(status);
    
    UInt32 flag = 0;
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output, 
                                  kBusInput,
                                  &flag, 
                                  sizeof(flag));
    
    checkOSStatus(status);

    UInt32 tempBufferInitalSize = 1024;
    _tempBuffer.mNumberChannels = 1;
    _tempBuffer.mDataByteSize = tempBufferInitalSize;
    _tempBuffer.mData = malloc(tempBufferInitalSize);
    memset(_tempBuffer.mData, 0, tempBufferInitalSize);
    status = AudioUnitInitialize(_audioUnit);
    checkOSStatus(status);
}

- (void)start{
    OSStatus status = AudioOutputUnitStart(_audioUnit);
    checkOSStatus(status);
}
- (void) stop {
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    checkOSStatus(status);
}

- (void)processAudio: (AudioBufferList*) bufferList{
    AudioBuffer sourceBuffer = bufferList->mBuffers[0];
    if ([self.delegate respondsToSelector:@selector(didReceiveBuffer:info:)]) {
        [self.delegate didReceiveBuffer:sourceBuffer info:_audioFormat];
    }
}

- (void) dealloc {
    AudioUnitUninitialize(_audioUnit);
    free(_tempBuffer.mData);
}


@end
