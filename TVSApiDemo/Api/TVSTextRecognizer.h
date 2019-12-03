//
//  TVSTextRecognizer.h
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVSTextRecognizer : NSObject

- (int)start:(NSInteger)session text:(NSString *)text handler : (void(^)(NSInteger *, NSDictionary *, NSError *))handler;

@end

NS_ASSUME_NONNULL_END
