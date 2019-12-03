//
//  TextUtils.h
//  DingDang
//
//  Created by Rinc Liu on 19/4/2018.
//  Copyright © 2018 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextUtils : NSObject

+(NSDictionary*)dictFromJson:(NSString*)json;

+(NSString*)jsonFromDict:(NSDictionary*)dict;

+(NSDictionary*)dictFromJsonData:(NSData*)data;

+(BOOL)containsEmoji:(NSString *)string;

@end
