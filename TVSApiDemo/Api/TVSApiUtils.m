//
//  TVSApiUtils.m
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TVSApiUtils.h"
#import <UIKit/UIKit.h>
#import "TSpeex.h"

@implementation TVSApiUtils

// 请根据tvs基础API文档指引拼写
+ (NSString *)buildQUA {
    NSString *vn = @"1.0.1000";
    NSString *pp = @"com.tencent.yunxiaowei.tvsapidemo";
    return [NSString stringWithFormat:@"QV=3&VE=GA&VN=%@&PP=%@&CHID=10000", vn, pp];
}

// 接入方保证唯一
+ (NSString *)buildSerialNum {
    NSString *serial_num = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return serial_num;
}

+ (NSDictionary *)speexEncodeAndBase64:(NSData *) data length:(NSInteger)length{

    NSUInteger speex_context = TSpeex_EncodeInit();
    NSLog(@"TSpeex_Encode speex_context = %lu", speex_context);
    char *inBytes = (char *)[data bytes];
    char *outBytes = 0;
    int outLength = TSpeex_Encode(speex_context, inBytes, length, &outBytes);
    NSLog(@"TSpeex_Encode inBytes.len = %lu, outLength = %d",  length, outLength);
    TSpeex_EncodeRelease(speex_context);
    
    if (outLength <= 0) {
        return nil;
    }
    NSData *speexResult = [NSData dataWithBytes:outBytes length:outLength];
    NSLog(@"TSpeex_Encode speexResult = %@",  speexResult);

    NSString *base64 = [speexResult base64EncodedStringWithOptions:0];
    NSLog(@"TSpeex_Encode base64 = %@",  base64);

    return @{@"base64": base64, @"outLength" : [NSNumber numberWithInteger:outLength]};
}

+ (NSString *)speexDecode:(NSData *) data{
    NSUInteger speex_context = TSpeex_DecodeInit();
    
    char *inBytes = [data bytes];
    char *outBytes = 0;
    int result = TSpeex_Decode(speex_context, inBytes, strlen(inBytes), &outBytes);
    NSLog(@"TSpeex_Decode result = %d, inBytes.len = %d, outBytes.len = %d",  result, strlen(inBytes), strlen(outBytes));
    TSpeex_DecodeRelease(speex_context);
    
    if (result <= 0) {
        return nil;
    }
    NSString *speexResult = [[NSString new] initWithUTF8String:outBytes];
    NSLog(@"TSpeex_Decode speexResult = %@",  speexResult);
    return speexResult;
}

@end
