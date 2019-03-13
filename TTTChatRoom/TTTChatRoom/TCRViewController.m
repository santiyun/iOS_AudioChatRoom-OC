//
//  TCRViewController.m
//  TTTChatRoom
//
//  Created by Work on 2019/1/18.
//  Copyright © 2019 Work. All rights reserved.
//

#import "TCRViewController.h"
#import "TCRUserCell.h"
#import "TCRManager.h"
#import "TTProgressHud.h"
#import "UIView+Toast.h"

#define SELECTEDCOLOR UIColor.brownColor
#define NORMALCOLOR UIColor.whiteColor

@interface TCRViewController ()<TTTRtcEngineDelegate ,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *speakerBtn;
@property (weak, nonatomic) IBOutlet UIButton *headsetBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteSelfBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteAllBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioMixingBTn;

@property (nonatomic, strong) NSMutableArray<TCRUser *> *users;
@end

@implementation TCRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _users = [NSMutableArray array];
    TCRManager.manager.rtcEngine.delegate = self;
    if (TCRManager.manager.me.role == TTTRtc_ClientRole_Audience) {
        _muteSelfBtn.enabled = NO;
        _audioMixingBTn.enabled = NO;
        _headsetBtn.backgroundColor = SELECTEDCOLOR;
        _headsetBtn.selected = YES;
    } else {
        [_users addObject:TCRManager.manager.me];
        _speakerBtn.backgroundColor = SELECTEDCOLOR;
        _speakerBtn.selected = YES;
        _headsetBtn.backgroundColor = SELECTEDCOLOR;
        _headsetBtn.selected = YES;
    }
}

//底部按钮得功能
- (IBAction)bottomBtnAction:(UIButton *)sender {
    if (sender.tag == 100) {
        if (sender.isSelected) {//下麦
            //下麦就是角色切换为观众
            [TCRManager.manager.rtcEngine setClientRole:TTTRtc_ClientRole_Audience];
            if (_audioMixingBTn.isSelected) {
                //下麦停掉正在播放的伴奏
                [TCRManager.manager.rtcEngine stopAudioMixing];
                _audioMixingBTn.selected = NO;
                _audioMixingBTn.backgroundColor = NORMALCOLOR;
            }
            sender.backgroundColor = NORMALCOLOR;
            _muteSelfBtn.enabled = NO;
            _audioMixingBTn.enabled = NO;
            _muteSelfBtn.selected = NO;
            _muteSelfBtn.backgroundColor = NORMALCOLOR;
            [_users removeObject:TCRManager.manager.me];
        } else {//上麦
            //上麦就是角色切换为副播
            [TCRManager.manager.rtcEngine setClientRole:TTTRtc_ClientRole_Broadcaster];
            [TCRManager.manager.rtcEngine muteLocalAudioStream:NO];
            sender.backgroundColor = SELECTEDCOLOR;
            _muteSelfBtn.enabled = YES;
            _audioMixingBTn.enabled = YES;
            [_users addObject:TCRManager.manager.me];
        }
        [self.tableView reloadData];
    } else if (sender.tag == 101) { //听筒扬声器切换
        if (sender.isSelected) {
            [TCRManager.manager.rtcEngine setEnableSpeakerphone:NO];
            sender.backgroundColor = NORMALCOLOR;
        } else {
            [TCRManager.manager.rtcEngine setEnableSpeakerphone:YES];
            sender.backgroundColor = SELECTEDCOLOR;
        }
    } else if (sender.tag == 102) { //开启/关闭本地静音
        if (sender.isSelected) {
            [TCRManager.manager.rtcEngine muteLocalAudioStream:NO];
            sender.backgroundColor = NORMALCOLOR;
        } else {
            [TCRManager.manager.rtcEngine muteLocalAudioStream:YES];
            sender.backgroundColor = SELECTEDCOLOR;
        }
        TCRManager.manager.me.mutedSelf = !sender.isSelected;
    } else if (sender.tag == 103) { //是否静音所有的远端用户
        if (sender.isSelected) {
            [TCRManager.manager.rtcEngine muteAllRemoteAudioStreams:NO];
            sender.backgroundColor = NORMALCOLOR;
        } else {
            [TCRManager.manager.rtcEngine muteAllRemoteAudioStreams:YES];
            sender.backgroundColor = SELECTEDCOLOR;
        }
    }
    sender.selected = !sender.isSelected;
}

//播放或者停止伴奏
- (IBAction)playAudioMIxing:(UIButton *)sender {
    if (sender.isSelected) {
        [TCRManager.manager.rtcEngine stopAudioMixing];
        sender.backgroundColor = NORMALCOLOR;
    } else {
        sender.backgroundColor = SELECTEDCOLOR;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Life" ofType:@"mp3"];
        [TCRManager.manager.rtcEngine startAudioMixing:path loopback:NO replace:NO cycle:1];
    }
    sender.selected = !sender.isSelected;
}

//离开频道
- (IBAction)leaveChannel:(id)sender {
    [TCRManager.manager.rtcEngine leaveChannel:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (TCRUser *)getUser:(int64_t)uid {
    __block TCRUser *user = nil;
    [_users enumerateObjectsUsingBlock:^(TCRUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.uid == uid) {
            user = obj;
            *stop = YES;
        }
    }];
    return user;
}
#pragma mark - TTTRtcEngineDelegate
//伴奏播放完成
- (void)rtcEngineAudioMixingPlayFinish:(TTTRtcEngineKit *)engine {
    _audioMixingBTn.selected = NO;
    _audioMixingBTn.backgroundColor = NORMALCOLOR;
}
//有远端用户加入频道
- (void)rtcEngine:(TTTRtcEngineKit *)engine didJoinedOfUid:(int64_t)uid clientRole:(TTTRtcClientRole)clientRole isVideoEnabled:(BOOL)isVideoEnabled elapsed:(NSInteger)elapsed {
    if (clientRole ==  TTTRtc_ClientRole_Audience) { return; } //不关注房间内得观众（观众只能听）
    TCRUser *user = [[TCRUser alloc] initWithUid:uid];
    user.role = clientRole;
    [_users addObject:user];
    [self.tableView reloadData];
}
//远端用户离线
- (void)rtcEngine:(TTTRtcEngineKit *)engine didOfflineOfUid:(int64_t)uid reason:(TTTRtcUserOfflineReason)reason {
    TCRUser *user = [self getUser:uid];
    if (user) {
        [_users removeObject:user];
        [self.tableView reloadData];
    }
}
//远端用户对自己做开启关闭静音
- (void)rtcEngine:(TTTRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(int64_t)uid {
    TCRUser *user = [self getUser:uid];
    if (user) {
        user.mutedSelf = muted;
        [self.tableView reloadData];
    }
}
//报告房间内用户的音量包括自己
- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    TCRUser *user = [self getUser:userID];
    if (user) {
        user.audioLevel = (int)audioLevel;
        [self.tableView reloadData];
    }
}
//网络丢失（会自动重连）
- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [TTProgressHud showHud:self.view message:@"网络链接丢失，正在重连..."];
}

//重新连接服务器成功
- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
}

//重新连接服务器失败，需要退出房间
- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
    [self.view.window showToast:@"网络丢失，请检查网络"];
    [engine leaveChannel:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//在房间内被服务器踢出
- (void)rtcEngine:(TTTRtcEngineKit *)engine didKickedOutOfUid:(int64_t)uid reason:(TTTRtcKickedOutReason)reason {
    NSString *errorInfo = @"";
    switch (reason) {
        case TTTRtc_KickedOut_ReLogin:
            errorInfo = @"重复登录";
            break;
        case TTTRtc_KickedOut_NoAudioData:
            errorInfo = @"长时间没有上行音频数据";
            break;
        case TTTRtc_KickedOut_ChannelKeyExpired:
            errorInfo = @"Channel Key失效";
            break;
        default:
            errorInfo = @"未知错误";
            break;
    }
    [self.view.window showToast:errorInfo];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCRUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TCRUserCell" forIndexPath:indexPath];
    [cell configureCell:_users[indexPath.row]];
    return cell;
}
@end
