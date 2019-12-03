//
//  TVSContext.h
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TVSContext : NSObject

+ (NSDictionary *) createLocationContext:(NSDictionary *)payload;

+ (NSDictionary *) createContext: (NSString *)namespace name:(NSString *)name payload:(NSDictionary *)paylod;

@end

NS_ASSUME_NONNULL_END
