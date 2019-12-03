//
//  BufferedRecorder.h
//  Dingdang
//
//  Created by RincLiu on 20/06/2017.
//  Copyright © 2017 tencent. All rights reserved.
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
    SInt64 currentPacket;
    bool working;
} RecordState;

@protocol AQRecorderDelegate <NSObject>
-(void)onInputVoice:(NSData *)data length:(NSInteger)length;
@end

@interface AQRecorder : NSObject{
    CFURLRef mFileURL;
}

@property(nonatomic, assign) RecordState recordState;

@property(nonatomic, assign) id<AQRecorderDelegate> delegate;

@property(nonatomic, strong) dispatch_queue_t aqueue;


-(NSError*)start;

-(BOOL)pause;

-(BOOL)resume;

-(NSData*)stop;

-(BOOL)isRecording;

@end
