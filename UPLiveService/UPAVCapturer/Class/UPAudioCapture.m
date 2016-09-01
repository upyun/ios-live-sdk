//
//  UPAudioCapture.m
//  Test_audioUnitRecorderAndPlayer
//
//  Created by DING FENG on 7/20/16.
//  Copyright © 2016 upyun.com. All rights reserved.
//

#import "UPAudioCapture.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <UPLiveSDK/AudioProcessor.h>

#define kBusOutput 0
#define kBusInput 1

#define KDefaultChannelsNum 1

/*音量线性调整
 http://dsp.stackexchange.com/questions/2990/how-to-change-volume-of-a-pcm-16-bit-signed-audio
 http://www.sengpielaudio.com/calculator-levelchange.htm
 gain = 10^(dB/20)
 volumRate =  2^(db/10)
 */

static float UPAudioCapture_volumRate(float db) {
    return  powf(2,(db / 10.));
}
static float UPAudioCapture_db(float volum) {
    if (volum < 0) {
        volum = 0;
    }
    //    NSLog(@"volum : %f", volum);
    return  10 * log2(volum);
}
static float UPAudioCapture_gain(float db) {
    //    NSLog(@"db : %f", db);
    float fx = (db) / 20.;
    //    NSLog(@"fx : %f", fx);
    //    NSLog(@"DB : %f", fx * 20);
    float g = powf(10,fx);
    //    NSLog(@"gain : %f", g);
    return g;
}


@interface UPAudioCapture()
{
    AudioProcessor *_pcmProcessor;
    
}
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
        UPAudioCapture *iosAudio = (__bridge UPAudioCapture *)inRefCon;
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
        UPAudioCapture *iosAudio = (__bridge UPAudioCapture *)inRefCon;
        for (int i=0; i < ioData->mNumberBuffers; i++) {
            AudioBuffer buffer = ioData->mBuffers[i];
            UInt32 size = MIN(buffer.mDataByteSize, [iosAudio tempBuffer].mDataByteSize);
            memcpy(buffer.mData, [iosAudio tempBuffer].mData, size);
            buffer.mDataByteSize = size;
        }
        return noErr;
    }
}


@implementation UPAudioCapture


- (id)initWith:(UPAudioUnitCategory)category {
    self = [super init];
    if (self) {
        _pcmProcessor = [[AudioProcessor alloc] initWithNoiseSuppress:-8 samplerate:44100];
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
        self.category = category;
        self.increaserRate = 100;
        [self setup];
    }
    return self;
}

- (void)setup {
    OSStatus status;
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
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
    NSData *sourcePcmData = [[NSData alloc] initWithBytes:sourceBuffer.mData length:sourceBuffer.mDataByteSize];
    
    AudioBuffer buffer;
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = sourceBuffer.mDataByteSize;
    buffer.mData = malloc(sourceBuffer.mDataByteSize);
    if (self.deNoise) {
        
        NSData *deNoiseData = nil;
        deNoiseData = [_pcmProcessor noiseSuppression:sourcePcmData];
        
        if (!deNoiseData) {
            if (buffer.mData) {
                free(buffer.mData);
            }
            return;
        }
        memcpy(buffer.mData, deNoiseData.bytes, sourceBuffer.mDataByteSize);
    } else {
        memcpy(buffer.mData, sourcePcmData.bytes, sourceBuffer.mDataByteSize);
    }
    const NSUInteger numElements =  sourceBuffer.mDataByteSize * 2;
    NSMutableData *data = [NSMutableData dataWithLength:numElements * sizeof(float)];
    float scale = (UPAudioCapture_gain(UPAudioCapture_db(self.increaserRate / 100.))) / (float)INT16_MAX ;
    vDSP_vflt16((SInt16 *)buffer.mData, 1, data.mutableBytes, 1, numElements);
    vDSP_vsmul(data.mutableBytes, 1, &scale, data.mutableBytes, 1, numElements);
    float scale2 = (float)INT16_MAX;
    vDSP_vsmul(data.mutableBytes, 1, &scale2, data.mutableBytes, 1, numElements);
    NSMutableData *data16 = [NSMutableData dataWithLength:numElements * sizeof(SInt16)];
    vDSP_vfix16(data.mutableBytes, 1,(SInt16 *)data16.mutableBytes,1, numElements);
    memcpy(buffer.mData, data16.mutableBytes, sourceBuffer.mDataByteSize);
    
    if ([self.delegate respondsToSelector:@selector(didReceiveBuffer:info:)]) {
        [self.delegate didReceiveBuffer:buffer info:_audioFormat];
    }
    if (buffer.mData) {
        free(buffer.mData);
    }
}

- (void) dealloc {
    AudioUnitUninitialize(_audioUnit);
    free(_tempBuffer.mData);
}


@end
