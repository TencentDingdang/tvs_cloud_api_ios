//
//  TVSContext.m
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TVSContext.h"

@implementation TVSContext

/* 位置信息上下文
 {
     "header": {
         "namespace": "LocationInformation",
         "name": "LocationState"
     },
     "payload": {
         "latitude" : 30.0000,
         "longitude": 90.0000
     }
 }
 */

+ (NSDictionary *) createLocationContext: (NSDictionary *)payload {
    //NSDictionary *payload = @{@"latitude" : [NSNumber numberWithInt:30.0000], @"longitude" : [NSNumber numberWithInt:90.0000]};
    return [self createContext:@"LocationInformation" name:@"LocationState" payload:payload];
}

+ (NSDictionary *) createContext: (NSString *)namespace name:(NSString *)name payload:(NSDictionary *)payload {
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSDictionary *header = @{@"namespace" : namespace, @"name" : name};
    [result setValue:header forKey:@"header"];
    [result setValue:payload forKey:@"payload"];
    NSLog(@"createContext result = %@", result);

    return result;
}

@end
