//
//  HttpEngine.m
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "HttpEngine.h"
#import "Constants.h"

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import <AFNetworking/AFNetworking.h>

@implementation HttpEngine

+ (BOOL) sendHttpRequestUrl:(NSInteger)reqId url:(NSString*)url json:(NSString*)json callback:(void(^)(NSInteger, NSData*, NSDictionary*, NSError*))handler{
    NSLog(@"sendHttpRequestUrl reqId = %ld, url = %@, json= %@", reqId, url, json);
    
    if (!json) {
        return NO;
    }
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *authorization = [self createAuthorization:json];
    
    NSDictionary *header = [[NSMutableDictionary alloc] init];
    [header setValue:authorization forKey:@"Authorization"];
    [self sendHttpRequestUrl:reqId url:url method:@"POST" headers:header data:data callback:handler];
    return YES;
}

+ (void) sendHttpRequestUrl:(NSInteger)reqId url:(NSString*)url method:(NSString*)method headers:(NSDictionary *)headers
                       data:(NSData*)data callback:(void(^)(NSInteger, NSData*, NSDictionary*, NSError*))handler{
    NSURL *reqURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:reqURL];
    [request setHTTPMethod:method];
    [request setValue:@"*/*" forHTTPHeaderField:@"Accept"];
    [request setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];
    
    if (headers) {
        NSArray *keys = headers.allKeys;
        for (NSString *key in keys) {
            NSString *value = [headers valueForKey:key];
            NSLog(@"sendHttpRequestUrl headers  key= %@, value= %@", key, value);
            [request setValue:value forHTTPHeaderField:key];
        }
    }
    //[request setValue:@"application/multipart-formdata" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];

    [request setHTTPBody:data];
    
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        //NSLog(@"completionHandler data= %@, response= %@, error = %@", data, response, error);
        NSDictionary *json;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
             json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(reqId, data, json, error);
        });
    }];
    
    [task resume];
}

+ (NSString *)createAuthorization: (NSString *)jsonBody {
    
    NSString *timeStamp = [self createTimestamp];

    NSString *signingContent = [NSString stringWithFormat:@"%@%@", jsonBody, [self createTimestamp]];
    
    NSString *signature = [self HMAC_SHA256:signingContent withKey:APP_ACCESSTOKEN];
    
    NSString *result = [NSString stringWithFormat:@"TVS-HMAC-SHA256-BASIC CredentialKey=%@, Datetime=%@, Signature=%@", APP_KEY, timeStamp, signature];
    
    NSLog(@"createAuthorization result = %@", result);
    
    return result;
}

+ (NSString *)createTimestamp {
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMdd'T'HHmmss'Z'"];
    NSString *result = [formatter stringFromDate:date];
    
    NSLog(@"createTimestamp result = %@", result);
    
    return result;
}

// HMAC_SHA256算法的key，传入云小微的accessToken
+ (NSString *)HMAC_SHA256:(NSString *)content withKey:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [content cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    NSLog(@"HMAC_SHA256 result = %@", HMAC);
    return HMAC;
}

@end
