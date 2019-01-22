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

- (IBAction)bottomBtnAction:(UIButton *)sender {
    if (sender.tag == 100) {
        if (sender.isSelected) {
            //下麦
            [TCRManager.manager.rtcEngine setClientRole:TTTRtc_ClientRole_Audience withKey:nil];
            if (_audioMixingBTn.isSelected) {
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
        } else {
            [TCRManager.manager.rtcEngine setClientRole:TTTRtc_ClientRole_Broadcaster withKey:nil];
            [TCRManager.manager.rtcEngine muteLocalAudioStream:NO];
            sender.backgroundColor = SELECTEDCOLOR;
            _muteSelfBtn.enabled = YES;
            _audioMixingBTn.enabled = YES;
            [_users addObject:TCRManager.manager.me];
        }
        [self.tableView reloadData];
    } else if (sender.tag == 101) {
        if (sender.isSelected) {
            [TCRManager.manager.rtcEngine setEnableSpeakerphone:NO];
            sender.backgroundColor = NORMALCOLOR;
        } else {
            [TCRManager.manager.rtcEngine setEnableSpeakerphone:YES];
            sender.backgroundColor = SELECTEDCOLOR;
        }
    } else if (sender.tag == 102) {
        if (sender.isSelected) {
            [TCRManager.manager.rtcEngine muteLocalAudioStream:NO];
            sender.backgroundColor = NORMALCOLOR;
        } else {
            [TCRManager.manager.rtcEngine muteLocalAudioStream:YES];
            sender.backgroundColor = SELECTEDCOLOR;
        }
        TCRManager.manager.me.mutedSelf = !sender.isSelected;
    } else if (sender.tag == 103) {
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
- (void)rtcEngineAudioMixingPlayFinish:(TTTRtcEngineKit *)engine {
    _audioMixingBTn.selected = NO;
    _audioMixingBTn.backgroundColor = NORMALCOLOR;
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didJoinedOfUid:(int64_t)uid clientRole:(TTTRtcClientRole)clientRole isVideoEnabled:(BOOL)isVideoEnabled elapsed:(NSInteger)elapsed {
    if (clientRole ==  TTTRtc_ClientRole_Audience) { return; }
    TCRUser *user = [[TCRUser alloc] initWithUid:uid];
    user.role = clientRole;
    [_users addObject:user];
    [self.tableView reloadData];
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didOfflineOfUid:(int64_t)uid reason:(TTTRtcUserOfflineReason)reason {
    TCRUser *user = [self getUser:uid];
    if (user) {
        [_users removeObject:user];
        [self.tableView reloadData];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine didAudioMuted:(BOOL)muted byUid:(int64_t)uid {
    TCRUser *user = [self getUser:uid];
    if (user) {
        user.mutedSelf = muted;
        [self.tableView reloadData];
    }
}

- (void)rtcEngine:(TTTRtcEngineKit *)engine reportAudioLevel:(int64_t)userID audioLevel:(NSUInteger)audioLevel audioLevelFullRange:(NSUInteger)audioLevelFullRange {
    TCRUser *user = [self getUser:userID];
    if (user) {
        user.audioLevel = (int)audioLevel;
        [self.tableView reloadData];
    }
}

- (void)rtcEngineConnectionDidLost:(TTTRtcEngineKit *)engine {
    [TTProgressHud showHud:self.view message:@"网络链接丢失，正在重连..."];
}

- (void)rtcEngineReconnectServerTimeout:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
}

- (void)rtcEngineReconnectServerSucceed:(TTTRtcEngineKit *)engine {
    [TTProgressHud hideHud:self.view];
    [self.view.window showToast:@"网络丢失，请检查网络"];
    [engine leaveChannel:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
