//
//  AQPlayer.m
//  DobbySwift
//
//  Created by Zacard Fang on 2017/9/28.
//  Copyright © 2017年 tencent. All rights reserved.
//
#import "AQPlayer.h"
#import <AVFoundation/AVFoundation.h>

void AudioOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
    NSLog(@"AudioOutputCallback start");
    
    AQPlayer *player = (__bridge AQPlayer *)inUserData;
    PlayState playState = player.playState;
    if (!playState.working || playState.currentIndex > player.sourceData.length) {
        return;
    }

    long bufferSize = BUFFER_SIZE;
    if(playState.currentIndex + BUFFER_SIZE > player.sourceData.length) {
        bufferSize = player.sourceData.length - playState.currentIndex;
    }
    [player.sourceData getBytes:inBuffer->mAudioData range:NSMakeRange(playState.currentIndex, bufferSize)];
    AudioQueueEnqueueBuffer(playState.queue, inBuffer, 0, NULL);
    
    playState.currentIndex += bufferSize;
    player.playState = playState;
    
    NSLog(@"AudioOutputCallback end");
}

void initBufferSize(AudioQueueRef audioQueue, AudioStreamBasicDescription ASBDescription, Float64 seconds, UInt32 *outBufferSize) {
    static const int maxBufferSize = 0x50000;
    int maxPacketSize = ASBDescription.mBytesPerPacket;
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(audioQueue, kAudioConverterPropertyMaximumOutputPacketSize, &maxPacketSize, &maxVBRPacketSize);
    }
    
    Float64 numBytesForTime = ASBDescription.mSampleRate * maxPacketSize * seconds;
    *outBufferSize = (UInt32)((numBytesForTime < maxBufferSize) ? numBytesForTime : maxBufferSize);
}

@implementation AQPlayer

-(instancetype)init {
    if (self == [super init]) {
        _aqueue = dispatch_queue_create("aqueue", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}


-(void)setVolume:(float) volume{
    AudioQueueSetParameter(_playState.queue, kAudioQueueParam_Volume, volume);
}

-(void)play:(NSData *)data{
    AudioQueueReset(_playState.queue);
    
    [self setupAudioFormat:&_playState.dataFormat];
    
    OSStatus status = AudioQueueNewOutput(&_playState.dataFormat, AudioOutputCallback, (__bridge void *)self, CFRunLoopGetCurrent(),
                                          kCFRunLoopCommonModes, 0, &_playState.queue);
    if(status != noErr) {
        NSLog(@"AQPlayer setup failed err:%d", status);
        return;
    }
    
    [self setVolume:1.0];
    
    initBufferSize(_playState.queue, _playState.dataFormat, 0.5, &_playState.bufferByteSize);
    
    for (int i = 0; i < BUFFER_NUM; i++) {
        AudioQueueAllocateBuffer(_playState.queue, BUFFER_SIZE, &_playState.buffers[i]);
        AudioQueueEnqueueBuffer(_playState.queue, _playState.buffers[i], 0, NULL);
    }

    _sourceData = data;
    
    UInt32 enableMetering = YES;
    AudioQueueSetProperty(_playState.queue, kAudioQueueProperty_EnableLevelMetering, &enableMetering, sizeof(enableMetering));
    
    AVAudioSession* session = [AVAudioSession sharedInstance];
    NSError* err;
    [session setCategory:AVAudioSessionCategoryPlayback error:&err];
    if (err) {
        NSLog(@"AQPlayer setSessionCategory failed:%@", err.localizedDescription);
    }
    [session setActive:YES error:&err];
    
    status = AudioQueueStart(_playState.queue, NULL);
    NSLog(@"start AudioQueueStart status = %d",(int)status);
    if (status == 0) {
        _playState.currentIndex = 0;
        _playState.working = true;
    }
}

-(BOOL)pause {
    return _playState.queue && AudioQueuePause(_playState.queue) == 0 ? YES : NO;
}

-(BOOL)resume {
    return _playState.queue && AudioQueueStart(_playState.queue, NULL) == 0 ? YES : NO;
}

-(NSData*)stop {
    if (_playState.working) {
        _playState.working = false;
        AudioQueueFlush(_playState.queue);
        AudioQueueStop(_playState.queue, true);
        for (int i = 0; i < BUFFER_NUM; i++) {
            AudioQueueFreeBuffer(_playState.queue, _playState.buffers[i]);
        }
        AudioQueueDispose(_playState.queue, true);
        AudioFileClose(_playState.audioFile);
        
        NSLog(@"AQPlayer stopped");
        
        return [NSData dataWithContentsOfURL:(__bridge NSURL*)mFileURL];
    }
    return nil;
}

-(BOOL)isPlaying {
    return _playState.working;
}

-(void)setupAudioFormat:(AudioStreamBasicDescription*)format {
    format->mSampleRate = 16000.0;
    format->mFormatID = kAudioFormatLinearPCM;
    format->mBitsPerChannel = 16;
    format->mFramesPerPacket = 1;
    format->mReserved = 0;
    format->mChannelsPerFrame = 1;
    format->mBytesPerPacket = format->mBytesPerFrame = 2 * format->mChannelsPerFrame;
    format->mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
}

-(void)dealloc {
    CFRelease(mFileURL);
}

@end
