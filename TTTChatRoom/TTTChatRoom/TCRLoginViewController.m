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
    TCRManager.manager.rtcEngine.delegate = self;
    [TCRManager.manager.rtcEngine setChannelProfile:TTTRtc_ChannelProfile_Communication];
    [TCRManager.manager.rtcEngine setClientRole:role withKey:nil];
    [TCRManager.manager.rtcEngine enableAudioVolumeIndication:1000 smooth:3];
    [TCRManager.manager.rtcEngine muteLocalAudioStream:NO];
    [TCRManager.manager.rtcEngine joinChannelByKey:nil channelName:_roomIDTF.text uid:_uid joinSuccess:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_roomIDTF resignFirstResponder];
}

#pragma mark - TTTRtcEngineDelegate
-(void)rtcEngine:(TTTRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(int64_t)uid elapsed:(NSInteger)elapsed {
    [TTProgressHud hideHud:self.view];
    [self performSegueWithIdentifier:@"ChatRoom" sender:nil];
}

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
