//
//  AQPlayer.h
//  DobbySwift
//
//  Created by Zacard Fang on 2017/9/28.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define BUFFER_SIZE 4096
#define BUFFER_NUM 3

typedef struct {
    AudioStreamBasicDescription dataFormat;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[BUFFER_NUM];
    UInt32 bufferByteSize;
    AudioFileID audioFile;
    SInt64 currentIndex;
    bool working;
} PlayState;

@interface AQPlayer : NSObject{
    CFURLRef mFileURL;
    NSLock *sysnLock;
}

@property(nonatomic, strong) NSData *sourceData;

@property(nonatomic, assign) PlayState playState;

@property(nonatomic, strong) dispatch_queue_t aqueue;


-(void)play:(NSData *)data;

-(BOOL)pause;

-(BOOL)resume;

-(NSData*)stop;

-(BOOL)isPlaying;

@end
