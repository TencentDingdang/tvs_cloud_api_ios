//
//  TVSSpeechRecognizer.h
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SpeechRegonizerDelegate <NSObject>

- (void)onSpeechStart:(NSInteger)session;

- (void)onSpeechRecoginzing:(NSInteger)session payload:(NSDictionary *)payload;

- (void)onSpeechEnd:(NSInteger)session;

@end

@interface TVSSpeechRecognizer : NSObject

@property(nonatomic, assign) id<SpeechRegonizerDelegate> delegate;

// session 标记请求，在callback中携带
- (NSInteger)start:(NSInteger) session;

- (void)cancel;

- (BOOL)isRecording;

@end

NS_ASSUME_NONNULL_END
