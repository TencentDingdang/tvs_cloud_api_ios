//
//  TVSSpeechRecognizer.m
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TVSSpeechRecognizer.h"

#import "TextUtils.h"
#import "TVSApiUtils.h"
#import "TVSContext.h"

#import "HttpEngine.h"
#import "Constants.h"

#import "AQRecorder.h"
#import <AVFoundation/AVFoundation.h>

@interface TVSSpeechRecognizer() <AQRecorderDelegate>

@property(nonatomic, strong)AQRecorder *aqRecorder;

@property(nonatomic, strong)NSString *sessionId;

@property(nonatomic, assign)NSInteger index;

@property(nonatomic, assign)NSInteger reqId;

// 是否是最后的语音包
@property(nonatomic, assign)BOOL isEnd;

@property(nonatomic, strong)NSMutableArray *asrRQueue;

@property(nonatomic, assign)NSInteger session;

// 是否完成识别
@property(nonatomic, assign)BOOL isFinished;

@property (nonatomic, strong) NSLock *myLock;

@end

@implementation TVSSpeechRecognizer

- (instancetype)init {
    if (self = [super init]) {
        _asrRQueue = [NSMutableArray new];
        self.myLock = [[NSLock alloc] init];
    }
    return self;
}

- (NSInteger)start:(NSInteger)session {
    NSLog(@"TVSSpeechRecognizer start");
    if (!_aqRecorder) {
        _aqRecorder = [AQRecorder new];
    }
    _aqRecorder.delegate = self;
    
    if (_aqRecorder.isRecording) {
        NSLog(@"TVSSpeechRecognizer error, isRecording!!! ");
        return -1;
    }

    self.session = session;
    
    [self reset];
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                // [self appendToDisplay:@"开始录音"];
                [self.aqRecorder start];
                if (self.delegate) {
                    [self.delegate onSpeechStart:session];
                }
            } else {
                NSLog(@"TVSSpeechRecognizer start error,  未开启录音权限!!!");
            }
        });
    }];
    
    return 0;
}

#pragma mark AQRecorderDelegate
-(void)onInputVoice:(NSData *)data length:(NSInteger)length{
    if (_isFinished) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!data) {
            NSLog(@"onInputVoice error, data is nil ");
            //[self postQueue];
            return;
        }
        
        NSLog(@"TVSSpeechRecognizer 开始收音");
        //NSLog(@"AQRecorder onInputVoice length = %ll, data = %@", length, data);

        NSDictionary *encode = [TVSApiUtils speexEncodeAndBase64:data length:length];
        if(!encode) {
             NSLog(@"onInputVoice speex encode error");
            return;
        }
        NSString *voice_base64 = encode[@"base64"];
        
        // 传入speexh压缩后的长度
        NSInteger outLength = [encode[@"outLength"] integerValue];
        
        if (voice_base64 && voice_base64.length > 0) {
            // BOOL isEnd = self->_isEnd || length < 4096;
            BOOL isEnd = self->_isEnd;
            NSString *requestJson = [self createRequestJson:self->_sessionId index:self->_index isEnd:isEnd voice_base64:voice_base64];
            // 第一次向后台提交录音数据
            if (self->_index == 0) {
                [self sendAudioRequest:requestJson];
            } else {
                // 还未获取到sessionId【第一次请求会返回】或者队列中还有之前未发出的请求，则添加到请求队列
                if (!self->_sessionId || self->_sessionId.length == 0 || self->_asrRQueue.count > 0) {
                    // requestJson中的_sessionId需要在获取到后更换掉
                    [self.myLock lock];
                    [self->_asrRQueue addObject:requestJson];
                    [self.myLock unlock];
                } else {
                    // 有sessionId并且之前的请求已发出
                    [self sendAudioRequest:requestJson];
                }
            }
            
            self->_index = self->_index + outLength;
        }
    });
}

- (void) reset {
    _index = 0;
    _sessionId = @"";
    _isEnd = NO;
    _isFinished = NO;
    
    [_asrRQueue removeAllObjects];
    _reqId = 0;
}

- (void)cancel {
    _isEnd = YES;
    [_aqRecorder stop];
}

- (BOOL)isRecording {
    return [_aqRecorder isRecording];
}

- (void)sendAudioRequest:(NSString *) requestJson{
    if (!requestJson || requestJson.length == 0) {
        NSLog(@"TVSSpeechRecognizer requestJson is empty");
        // [self cancel];
        return;
    }
    
    // requestJson中的_sessionId需要在获取到后更换掉
    NSString *source = [NSString stringWithFormat:@"\"%@\" : \"%@\"", @"session_id", @""];
    NSString *target = [NSString stringWithFormat:@"\"%@\" : \"%@\"", @"session_id", _sessionId];
    NSString *reqJson = [requestJson stringByReplacingOccurrencesOfString:source withString:target];
    
    [HttpEngine sendHttpRequestUrl:_reqId url:API_ASR json:reqJson callback:^(NSInteger reqId, NSData *data, NSDictionary * dic, NSError* err) {
        if (self.isFinished) {
            return;
        }
        NSLog(@"TVSSpeechRecognizer callback reqId =%lu, dic = %@", (unsigned long)reqId, dic);
        if (dic) {
            NSDictionary *payload = dic[@"payload"];
            if (self.delegate) {
                [self.delegate onSpeechRecoginzing:self.session payload:payload];
            }
            
            if (payload) {
                BOOL final_result = [payload[@"final_result"] boolValue];
                if (final_result) {
                    NSLog(@"TVSSpeechRecognizer 识别完成");
                    self.isFinished = YES;
                    
                    if (self.delegate) {
                        [self.delegate onSpeechEnd:self.session];
                        
                        [self cancel];
                    }
                    
                    return;
                }
            }
        }

        // 写入下次请求的sessionId
        if (dic && dic[@"header"] && dic[@"header"][@"session"]) {
            self->_sessionId = dic[@"header"][@"session"][@"session_id"];
            NSLog(@"TVSSpeechRecognizer _sessionId = %@", self->_sessionId);
        }
        [self postQueue];
        
        //handler(session, dic, err);
    }];
    
    _reqId++;
}

- (void)postQueue {
    if (_isFinished || _asrRQueue.count <= 0) {
        return;
    }
    NSLog(@"将队列中缓存的请求全部发出 %lu", (unsigned long)_asrRQueue.count);
    // 将队列中缓存的请求全部发出，如果是同步请求会慢
    [self.myLock lock];
    NSMutableArray *deleteList = [NSMutableArray array];
    for (NSString *requestJson in self->_asrRQueue) {
        [deleteList addObject:requestJson];
        [self sendAudioRequest:requestJson];
    }
    // 移除
    [self.asrRQueue removeObjectsInArray:deleteList];
    [self.myLock unlock];
}

// http body 样例

//{
//    "header": {
//        "device": {
//            "network": "4G",
//            "serial_num":"{{STRING}}"
//        },
//        "qua": "【QUA】",
//        "user": {
//            "user_id": ""
//        },
//        "lbs": {
//            "longitude": 132.56481,
//            "latitude": 22.36549
//        },
//        "ip": "8.8.8.8"
//    },
//    "payload": {
//        "voice_meta": {
//            "compress": "PCM",
//            "sample_rate": "8K",
//            "channel": 1,
//            "language": "{{STRING}}",
//            "model":10
//            "offset":0
//        },
//        "open_vad": true,
//        "session_id": "{{STRING}}",
//        "index": 0,
//        "voice_finished": false,
//        "voice_base64": "{{STRING}}"
//    }
//}

- (NSString *)createRequestJson:(NSString *)sessionId index:(NSInteger)index isEnd:(BOOL)isEnd voice_base64:(NSString *)voice_base64 {
    
    // header
    // device
    NSDictionary *device = @{@"network":@"",
                             @"serial_num":[TVSApiUtils buildSerialNum]
                             
    };
    NSDictionary *header = @{@"qua":[TVSApiUtils buildQUA],
                             @"device" : device
    };
    
    // payload
    // voice_meta
    NSDictionary *voice_meta = @{@"compress":@"SPEEX",
                                 @"sample_rate":@"16K",
                                 @"channel":[NSNumber numberWithInt:1],
                                 //@"language":@"", // 默认汉语
                                 //@"model":@"",
                                 //@"offset":@"",
    };
    
    NSDictionary *payload = @{@"voice_meta" : voice_meta,
                              @"open_vad" :[NSNumber numberWithBool:YES],
                              @"session_id" : sessionId,    // 流式识别过程中必填
                              @"index" : [NSNumber numberWithInteger:index],    // 语音片偏移量(英文时为语音包序号)
                              @"voice_finished" : [NSNumber numberWithBool:isEnd],
                              @"voice_base64" : voice_base64, // 语音数据的Base64编码
    };

    NSDictionary *httpBody = @{ @"header" : header, @"payload" : payload};
    
    NSString *result = [TextUtils jsonFromDict:httpBody];
    
    NSLog(@"createRequestJson result = %@", result);
    return result;
}

@end
