//
//  TVSTextRecognizer.m
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TVSTextRecognizer.h"

#import "TextUtils.h"
#import "TVSApiUtils.h"
#import "TVSContext.h"

#import "HttpEngine.h"
#import "Constants.h"

@implementation TVSTextRecognizer

- (int)start:(NSInteger)session text:(NSString *)text handler : (void(^)(NSInteger *, NSDictionary *, NSError *))handler {
    NSString *requestJson = [self createRequestJson:text];
    BOOL result = [HttpEngine sendHttpRequestUrl:session url:API_TEXT_RECOGNIZER json:requestJson callback:^(NSInteger reqId, NSData *data, NSDictionary * dic, NSError* err) {
        NSLog(@"TVSTextRecognizer callback result = %@, err = %@", dic, err ? err.localizedDescription : @"null");
        handler(reqId, dic, err);
    }];
    return result ? 0 : -1;
}

- (NSString *) createRequestJson: (NSString *) text{
    NSMutableDictionary *result = [NSMutableDictionary new];
    
    NSMutableDictionary *baseInfo = [self createBaseInfo];
    [result setValue:baseInfo forKey:@"baseInfo"];

    NSMutableDictionary *event = [self createTextRecognizerEvent:text];
    [result setValue:event forKey:@"event"];
    
    NSMutableArray *context = [self createContext];
    [result setValue:context forKey:@"context"];
    
    NSString *json = [TextUtils jsonFromDict:result];
    NSLog(@"createRequestJson json = %@", json);
    
    return json;
}

- (NSMutableDictionary *)createBaseInfo {
    NSMutableDictionary *baseInfo = [NSMutableDictionary new];
    [baseInfo setValue:[TVSApiUtils buildQUA] forKey:@"qua"];
    
    // 标示设备的唯一码，接入方需保证唯一性
    NSString *serial_num = [TVSApiUtils buildSerialNum];
    NSDictionary *device = @{@"network":@"", @"serialNum":serial_num};
    [baseInfo setValue:device forKey:@"device"];
    
    return baseInfo;
}


- (NSMutableDictionary *)createTextRecognizerEvent:(NSString *)text {
    NSMutableDictionary *event = [NSMutableDictionary new];
    
//    {
//        "header": {
//        "dialogRequestId": "-1241145376",
//        "messageId": "-1241145376",
//        "name": "Recognize",
//        "namespace": "TvsTextRecognizer"
//        },
//        "payload": {
//            "text": "今天深圳的天气"
//        }
//    }
    
    NSString *timestamp = [NSString stringWithFormat:@"%f", [[NSDate new] timeIntervalSince1970]];
    NSDictionary *header = @{@"namespace" : @"TvsTextRecognizer", @"name" : @"Recognize",  @"dialogRequestId" : timestamp, @"messageId" : timestamp};
    
    [event setValue:header forKey:@"header"];
    [event setValue:@{@"text" : text} forKey:@"payload"];
    
    return event;
}

// 具体Context 参考文档
- (NSMutableArray *)createContext {
    NSMutableArray *contextList = [NSMutableArray new];
//    "header": {
//        "name": "ShowState",
//        "namespace": "TvsUserInterface"
//    },
//    "payload": {
//        "isEnable": true
//    }
    NSDictionary *showStateContext = [TVSContext createContext:@"TvsUserInterface" name:@"ShowState" payload:@{@"isEnabled":[NSNumber numberWithBool:YES]}];
    [contextList addObject:showStateContext];
    
    NSDictionary *testCustomData = [NSDictionary dictionaryWithObjectsAndKeys:@"spotLabel", @"type", @"Yunnan", @"value", nil];
    NSDictionary *customDataDic = [NSDictionary dictionaryWithObject:testCustomData forKey:@"currentState"];
    NSDictionary *customDataContext = [TVSContext createContext:@"TvsCustomData" name:@"State" payload:customDataDic];
    [contextList addObject:customDataContext];
    
    
    // other context
    //[contextList addObject:otherContext];
    
    // sample for context
//    NSDictionary *payload = @{@"latitude" : [NSNumber numberWithInt:30.0000], @"longitude" : [NSNumber numberWithInt:90.0000]};
//    NSDictionary *locationContext = [TVSContext createLocationContext:payload];
//    [contextList addObject:locationContext];
    
    return contextList;
}

@end
