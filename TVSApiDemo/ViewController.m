//
//  ViewController.m
//  TVSApiDemo
//
//  Created by Zacard Fang on 2019/11/29.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "ViewController.h"

#import "TVSTextRecognizer.h"
#import "TVSSpeechRecognizer.h"
#import "HttpEngine.h"
#import "TVSApiUtils.h"
#import "TextUtils.h"

@interface ViewController () <SpeechRegonizerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *textSkillButton;
@property (strong, nonatomic) IBOutlet UITextView *logInput;

@property(nonatomic, strong) TVSSpeechRecognizer *speechRecognizer;
@property(nonatomic, strong) TVSTextRecognizer *textRecognizer;

@property(nonatomic, strong) NSString *textResult;

@property(nonatomic, strong) NSMutableString *displayLog;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _displayLog = [NSMutableString new];
    
    _speechRecognizer = [TVSSpeechRecognizer new];
    _speechRecognizer.delegate = self;
    
     _textRecognizer = [TVSTextRecognizer new];
}

- (IBAction)clearLog:(id)sender {
    [self clearToDisplay];
}

- (IBAction)speechRecognize:(id)sender {
    if ([_speechRecognizer isRecording]) {
        [_speechRecognizer cancel];
        return;
    }
    [_speechRecognizer start:222];
}

- (IBAction)textRecognize:(id)sender {
    if (!_textResult || _textResult.length <= 0) {
        [self appendToDisplay: @"需要传入文本参数，可以使用语音识别的结果/::)"];
        return;
    }
    
    [_textRecognizer start:111 text:_textResult handler:^(NSInteger * session, NSDictionary * result, NSError * err) {
        NSLog(@"tvsRecognizer handler session = %lu, %@", session, result);
        // 解析技能数据
        if (result) {
            [self appendToDisplay: @"----------******-----------"];
           [self appendToDisplay: [NSString stringWithFormat:@"文本：%@", self.textResult]];
           [self appendToDisplay: [NSString stringWithFormat:@"指令数据：%@", [TextUtils jsonFromDict:result]]];
        }
    }];
}

- (void)onSpeechStart:(NSInteger)session {
    [_recordButton setTitle:@"结束录音" forState:UIControlStateNormal];
     [self appendToDisplay: @"----------******-----------"];
    [self appendToDisplay: @"开始收音"];
}

-(void)onSpeechRecoginzing:(NSInteger)session payload:(NSDictionary *)payload {
    if (payload) {
        NSLog(@"ret = %d, final_result = %d, result = %@", [payload[@"ret"] intValue], [payload[@"final_result"] boolValue], payload[@"result"]);
        BOOL isFinal = [payload[@"final_result"] boolValue];
        NSString *recognizeResult = payload[@"result"];
        if (isFinal) {
            [self appendToDisplay:[NSString stringWithFormat:@"识别完成：%@", recognizeResult]];
            _textResult = recognizeResult;
            
        } else {
            if (recognizeResult && recognizeResult.length > 0) {
              [self appendToDisplay:[NSString stringWithFormat:@"识别中：%@", recognizeResult]];
            }
        }
    }
}

- (void)onSpeechEnd:(NSInteger)session {
    [_recordButton setTitle:@"开始录音" forState:UIControlStateNormal];
    [self appendToDisplay: @"停止收音"];
}

#pragma mark log
- (void)appendToDisplay:(NSString *)content {
    [_displayLog appendString:content];
    [_displayLog appendString:@"\n"];
    [self onDisplayChanged: _displayLog];
}

- (void)clearToDisplay {
    [_displayLog setString:@""];
    [self onDisplayChanged: _displayLog];
}

- (void)onDisplayChanged:(NSString *)content{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_logInput setText:content];
        [self->_logInput scrollRangeToVisible:NSMakeRange(self->_logInput.text.length - 1, 1)];
    });
    
}

@end
