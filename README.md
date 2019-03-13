# 在线语音聊天室
语音聊天室是一种纯音频的实时互动使用场景。用户可以创建语音聊天房间，听众以副播或观众的身份加入房间进行语音聊天，也可以在房间内任意切换自己的副播/听众身份，即上麦/下麦的过程。

常见的几种语音聊天室类型及特点：

> 语音交友: 房间内多个用户需要频繁上下麦，用户不想花费过多流量

> 开黑语音: 频道内用户数相对固定，用户对声音延迟要求较高

> 情感电台: 对音质要求较高，声音还原度高，模拟电台语音聊天，语音电台主播首选

# 功能列表

1. 创建 TTT 音频引擎对象 [sharedEngineWithAppId](http://3ttech.cn/index.php?menu=68&type=iOS#sharedEngineWithAppId)
2. 设置频道通信模式 [setChannelProfile](http://3ttech.cn/index.php?menu=68&type=iOS#setChannelProfile)
3. 设置用户角色 [setClientRole](http://3ttech.cn/index.php?menu=68&type=iOS#setClientRole)  麦上用户: BROADCASTER， 麦下用户: AUDIENCE
4. 启用说话音量提示 [enableAudioVolumeIndication](http://3ttech.cn/index.php?menu=68&type=iOS#enableAudioVolumeIndication)
5. 加入频道 [joinChannelByKey](http://3ttech.cn/index.php?menu=68&type=iOS#joinChannelByKey)
6. 离开频道 [leaveChannel](http://3ttech.cn/index.php?menu=68&type=iOS#leaveChannel)
7. 静音/取消静音，可选操作 [muteLocalAudioStream](http://3ttech.cn/index.php?menu=68&type=iOS#muteLocalAudioStream)
8. 静音/取消静音所有远端用户，可选操作 [muteAllRemoteAudioStreams](http://3ttech.cn/index.php?menu=68&type=iOS#muteAllRemoteAudioStreams)
9. 听筒扬声器切换，可选操作 [setEnableSpeakerphone](http://3ttech.cn/index.php?menu=68&type=iOS#setEnableSpeakerphone)
10. 设置高音质，可选操作 [setHighQualityAudioParametersWithFullband](http://3ttech.cn/index.php?menu=68&type=iOS#setHighQualityAudioParametersWithFullband)
11. 伴奏播放，可选操作 [startAudioMixing](http://3ttech.cn/index.php?menu=68&type=iOS#startAudioMixing)

# 示例程序

#### 准备工作
1. 在三体云官网SDK下载页 [http://3ttech.cn/index.php?menu=53](http://3ttech.cn/index.php?menu=53) 下载对应平台的 语音通话SDK。
2. 登录三体云官网 [http://dashboard.3ttech.cn/index/login](http://dashboard.3ttech.cn/index/login) 注册体验账号，进入控制台新建自己的应用并获取APPID。

## iOS工程配置

SDK包含**TTTRtcEngineVoiceKit.framework**和**TTTPlayerKit.framework** 

**两个framework只支持真机，不支持模拟器**


把下载的SDK放在demo得**TTTLib**目录下, 在**TCRManager.m**目录下填写申请的AppID

工程已做如下配置，直接运行工程

1. 设置Bitcode为NO
2. 设置后台音频模式
3. 导入系统库

 * libxml2.tbd
 * libc++.tbd
 * libz.tbd
 * AudioToolbox.framework
 * AVFoundation.framework
 * CoreTelephony.framework
 * SystemConfiguration.framework



# 视频教程
安卓端SDK集成视频教程：[https://v.qq.com/x/page/h0740eg9f8q.html]()

iOS端SDK集成视频教程：[https://v.qq.com/x/page/u0738fgva34.html]()

# 常见问题
1. 由于部分模拟器会存在功能缺失或者性能问题，所以 SDK 不支持模拟器的使用。