## TVS基础API iOS Demo使用说明



#### 1、填写APPKEY和ACCESSTOKEN

在Constants.h中填写APPKEY和ACCESSTOKEN：

```
#define APP_KEY @"YOUR APPKEY"
#define APP_ACCESSTOKEN @"YOUR ACCESS_TOKEN"
```

登录腾讯云小微开放平台 -- 设备开放平台，在应用列表中查看应用概览，可以找到该应用的APP KEY和AccessToken；如果没有应用，需要新建一个；

开放平台地址为：

[腾讯云小微开放平台](https://dingdang.qq.com/open#/)



#### 2、填写设备唯一标识

在TVSApiUtils.m中填写：

```
// 接入方保证唯一，目前demo填写的UUID
+ (NSString *)buildSerialNum {
    NSString *serial_num = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return serial_num;
}
```

serial_num是设备的唯一标识，要保证该标识的唯一性，比如使用手机的UUID等；



#### 3、填写设备的QUA

在TVSApiUtils.m中填写：

```
// 请根据tvs基础API文档指引拼写
+ (NSString *)buildQUA {
    NSString *vn = @"1.0.1000";
    NSString *pp = @"com.tencent.yunxiaowei.tvsapidemo";
    return [NSString stringWithFormat:@"QV=3&VE=GA&VN=%@&PP=%@&CHID=10000", vn, pp];
}
```

关于QUA的字段说明，可以查阅如下文档：
[QUA字段说明](https://github.com/TencentDingdang/tvs-tools/blob/master/doc/%E8%85%BE%E8%AE%AF%E5%8F%AE%E5%BD%93HTTP%E6%96%B9%E5%BC%8F%E6%8E%A5%E5%85%A5API%E6%96%87%E6%A1%A3.md#71-qua%E5%AD%97%E6%AE%B5%E8%AF%B4%E6%98%8E)



#### 4、在NLP时填写自定义上下文

在TVSTextRecognizer.m的createContext方法中增加自定义上下文，增加自定义键-对标识：

```
NSDictionary *testCustomData = [NSDictionary dictionaryWithObjectsAndKeys:@"spotLabel", @"type", @"Yunnan", @"value", nil];
    NSDictionary *customDataDic = [NSDictionary dictionaryWithObject:testCustomData forKey:@"currentState"];
    NSDictionary *customDataContext = [TVSContext createContext:@"TvsCustomData" name:@"State" payload:customDataDic];
    [contextList addObject:customDataContext];
```



#### 5、完善TVS指令解析

在ViewController.m的textRecognizer请求的回调方法中对后台下发的TVS指令进行解析处理，当前Demo只做了打印的示例。

TVS协议可以参考如下路径中的文档：
[TVS Protocol](https://github.com/TencentDingdang/tvs-tools/tree/master/Tvs%20Protocol)


#### 6、Demo使用方法

运行Demo，点击"开始录音"，对手机麦克风说话，可以在界面下方看到语音识别后的文本；

点击”文本->技能“，将对语音识别的结果进行语义理解，返回结果并打印在界面下方。



#### 7、其他

语音识别协议可以参考如下文档：

[腾讯云叮当语音识别协议](https://github.com/TencentDingdang/tvs-tools/blob/master/doc/腾讯叮当HTTP方式接入API文档.md#52-语音识别)