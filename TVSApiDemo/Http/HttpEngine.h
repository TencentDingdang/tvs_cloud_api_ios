//
//  HttpEngine.h
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpEngine : NSObject

+ (BOOL) sendHttpRequestUrl:(NSInteger)reqId url:(NSString*)url json:(NSString*)json callback:(void(^)(NSInteger, NSData*, NSDictionary*, NSError*))handler;

+ (NSString *)HMAC_SHA256:(NSString *)content withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
