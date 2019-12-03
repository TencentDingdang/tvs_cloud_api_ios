//
//  TVSApiUtils.h
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVSApiUtils : NSObject

// 请tvs基础API文档指引拼写
+ (NSString *)buildQUA;

 // 标示设备的唯一码，接入方需保证唯一性;
+ (NSString *)buildSerialNum;

+ (NSDictionary *)speexEncodeAndBase64:(NSData *) data length:(NSInteger)length;

+ (NSString *)speexDecode:(NSData *) data;

@end

NS_ASSUME_NONNULL_END
