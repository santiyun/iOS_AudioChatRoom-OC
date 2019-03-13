//
//  TCRLoginViewController.m
//  TTTChatRoom
//
//  Created by Work on 2019/1/18.
//  Copyright © 2019 Work. All rights reserved.
//

#import "TCRLoginViewController.h"
#import "TCRManager.h"
#import "TTProgressHud.h"
#import "UIView+Toast.h"

@interface TCRLoginViewController ()<TTTRtcEngineDelegate>
@property (weak, nonatomic) IBOutlet UIButton *broBtn;
@property (weak, nonatomic) IBOutlet UIButton *audienceBtn;
@property (weak, nonatomic) IBOutlet UITextField *roomIDTF;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic, strong) UIButton *roleSelectedBtn;
@property (nonatomic, assign) int64_t uid;
@end

@implementation TCRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *dateStr = NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
    _versionLabel.text= [TTTRtcEngineKit.getSdkVersion stringByAppendingFormat:@"__%@", dateStr];
    _uid = arc4random() % 100000 + 1;
    int64_t roomID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ENTERROOMID"].longLongValue;
    if (roomID == 0) {
        roomID = arc4random() % 1000000 + 1;
    }
    _roomIDTF.text = [NSString stringWithFormat:@"%lld", roomID];
    _roleSelectedBtn = _broBtn;
}

//选择角色
- (IBAction)roleSelectedAction:(UIButton *)sender {
    if (sender.isSelected) { return; }
    _roleSelectedBtn.selected = NO;
    _roleSelectedBtn.backgroundColor = [UIColor blackColor];
    sender.selected = YES;
    sender.backgroundColor = [UIColor cyanColor];
    _roleSelectedBtn = sender;
}


- (IBAction)joinChannel:(id)sender {
    if (_roomIDTF.text.length == 0) {
        [self showToast:@"请输入正确的房间号"];
        return;//
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:_roomIDTF.text forKey:@"ENTERROOMID"];
    [ud synchronize];
    TTTRtcClientRole role = TTTRtc_ClientRole_Broadcaster;
    if (_roleSelectedBtn == _audienceBtn) {
        role = TTTRtc_ClientRole_Audience;
    }
    [TTProgressHud showHud:self.view];
    TCRManager.manager.me.uid = _uid;
    TCRManager.manager.me.role = role;
    TCRManager.manager.me.mutedSelf = NO;
    //3T Func
    //初始化工具管理类，内部初始化了TTTRtcEngineKit对象
    //设置代理
    TCRManager.manager.rtcEngine.delegate = self;
    //设置频道属性为通信模式
    [TCRManager.manager.rtcEngine setChannelProfile:TTTRtc_ChannelProfile_Communication];
    //设置用户角色
    [TCRManager.manager.rtcEngine setClientRole:role];
    //启动音量监听
    [TCRManager.manager.rtcEngine enableAudioVolumeIndication:1000 smooth:3];
    //启用音频，该方法设置的状态是全局的，退出频道不会重置用户的状态
    [TCRManager.manager.rtcEngine muteLocalAudioStream:NO];
    //加入频道
    [TCRManager.manager.rtcEngine joinChannelByKey:nil channelName:_roomIDTF.text uid:_uid joinSuccess:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_roomIDTF resignFirstResponder];
}

#pragma mark - TTTRtcEngineDelegate
//加入频道成功，进入聊天室页面
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [TTProgressHud hideHud:self.view];
    [self performSegueWithIdentifier:@"ChatRoom" sender:nil];
}

//加入频道出现错误
-(void)rtcEngine:(TTTRtcEngineKit *)engine didOccurError:(TTTRtcErrorCode)errorCode {
    NSString *errorInfo = @"";
    switch (errorCode) {
        case TTTRtc_Error_Enter_TimeOut:
            errorInfo = @"超时,10秒未收到服务器返回结果";
            break;
        case TTTRtc_Error_Enter_Failed:
            errorInfo = @"该直播间不存在";
            break;
        case TTTRtc_Error_Enter_BadVersion:
            errorInfo = @"版本错误";
            break;
        case TTTRtc_Error_InvalidChannelName:
            errorInfo = @"Invalid channel name";
            break;
        default:
            errorInfo = [NSString stringWithFormat:@"未知错误：%zd",errorCode];
            break;
    }
    [TTProgressHud hideHud:self.view];
    [self showToast:errorInfo];
}

@end
