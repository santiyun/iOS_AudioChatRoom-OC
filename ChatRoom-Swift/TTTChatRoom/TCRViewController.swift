//
//  TCRViewController.swift
//  TTTChatRoom
//
//  Created by Work on 2019/3/13.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineVoiceKit

class TCRViewController: UIViewController {

    private var users = [TCRUser]()
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var speakerBtn: UIButton!//上下麦
    @IBOutlet private weak var headsetBtn: UIButton!//扬声器听筒切换
    @IBOutlet private weak var muteselfBtn: UIButton!       //是否静音
    @IBOutlet private weak var muteAllBtn: UIButton!        //静音全部远端音频
    @IBOutlet private weak var audioMixingBtn: UIButton!    //伴奏
    
    override func viewDidLoad() {
        super.viewDidLoad()

        TTManager.rtcEngine.delegate = self
        if TTManager.me.role == .clientRole_Broadcaster {
            users.append(TTManager.me)
            speakerBtn.isSelected = true
            speakerBtn.backgroundColor = UIColor.brown
        } else {
            muteselfBtn.isEnabled = false
            audioMixingBtn.isEnabled = false
        }
        headsetBtn.isSelected = true
        headsetBtn.backgroundColor = UIColor.brown
    }
    
    //上下麦
    @IBAction private func becomeSpeaker(_ sender: UIButton) {
        if sender.isSelected {//下麦
            //下麦就是角色切换为观众
            TTManager.rtcEngine.setClientRole(.clientRole_Audience)
            //下麦停掉正在播放的伴奏
            if audioMixingBtn.isSelected {
                TTManager.rtcEngine.stopAudioMixing()
                audioMixingBtn.isSelected = false
                audioMixingBtn.backgroundColor = UIColor.white
            }
            sender.backgroundColor = UIColor.white
            muteselfBtn.isEnabled = false
            muteselfBtn.isSelected = false
            muteselfBtn.backgroundColor = UIColor.white
            audioMixingBtn.isEnabled = false
            if let index = users.firstIndex(where: {$0.uid == TTManager.me.uid}) {
                users.remove(at: index)
            }
        } else {              //上麦
            //上麦就是角色切换为副播
            TTManager.rtcEngine.setClientRole(.clientRole_Broadcaster)
            TTManager.rtcEngine.muteLocalAudioStream(false)
            sender.backgroundColor = UIColor.brown
            muteselfBtn.isEnabled = true
            audioMixingBtn.isEnabled = true
            users.append(TTManager.me)
        }
        sender.isSelected = !sender.isSelected
        tableView.reloadData()
    }
    
    //听筒扬声器切换
    @IBAction private func playSpeaker(_ sender: UIButton) {
        if sender.isSelected {
            TTManager.rtcEngine.setEnableSpeakerphone(false)
            sender.backgroundColor = UIColor.white
        } else {
            TTManager.rtcEngine.setEnableSpeakerphone(true)
            sender.backgroundColor = UIColor.brown
        }
        sender.isSelected = !sender.isSelected
    }
    
    //开启/关闭本地静音
    @IBAction private func muteSelf(_ sender: UIButton) {
        if sender.isSelected {
            TTManager.rtcEngine.muteLocalAudioStream(false)
            sender.backgroundColor = UIColor.white
        } else {
            TTManager.rtcEngine.muteLocalAudioStream(true)
            sender.backgroundColor = UIColor.brown
        }
        sender.isSelected = !sender.isSelected
    }
    
    //是否静音所有的远端用户
    @IBAction private func muteAllRemoteAudio(_ sender: UIButton) {
        if sender.isSelected {
            TTManager.rtcEngine.muteAllRemoteAudioStreams(false)
            sender.backgroundColor = UIColor.white
        } else {
            TTManager.rtcEngine.muteAllRemoteAudioStreams(true)
            sender.backgroundColor = UIColor.brown
        }
        sender.isSelected = !sender.isSelected
    }
    
    //播放或者停止伴奏
    @IBAction private func startAudioMixing(_ sender: UIButton) {
        if sender.isSelected {
            TTManager.rtcEngine.stopAudioMixing()
            sender.backgroundColor = UIColor.white
        } else {
            sender.backgroundColor = UIColor.brown
            let path = Bundle.main.path(forResource: "Life", ofType: "mp3")
            TTManager.rtcEngine.startAudioMixing(path, loopback: false, replace: false, cycle: 1)
        }
        sender.isSelected = !sender.isSelected
    }
    
    //离开频道
    @IBAction private func exitChannel(_ sender: Any) {
        TTManager.rtcEngine.leaveChannel(nil)
        dismiss(animated: true, completion: nil)
    }
    
    private func getUser(_ uid: Int64) -> (TCRUser, Int)? {
        if let index = users.index(where: { $0.uid == uid } ) {
            return (users[index], index)
        }
        return nil
    }
    
}

extension TCRViewController: TTTRtcEngineDelegate {
    //有远端用户加入频道
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinedOfUid uid: Int64, clientRole: TTTRtcClientRole, isVideoEnabled: Bool, elapsed: Int) {
        if clientRole == .clientRole_Audience { return }
        let user = TCRUser(uid)
        user.role = clientRole
        users.append(user)
        tableView.reloadData()
    }
    //远端用户离线
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOfflineOfUid uid: Int64, reason: TTTRtcUserOfflineReason) {
        if let index = getUser(uid)?.1 {
            users.remove(at: index)
            tableView.reloadData()
        }
    }
    
    //远端用户对自己做开启关闭静音
    func rtcEngine(_ engine: TTTRtcEngineKit!, didAudioMuted muted: Bool, byUid uid: Int64) {
        if let user = getUser(uid)?.0 {
            user.mutedSelf = muted
            tableView.reloadData()
        }
    }
    
    //报告房间内用户的音量包括自己
    func rtcEngine(_ engine: TTTRtcEngineKit!, reportAudioLevel userID: Int64, audioLevel: UInt, audioLevelFullRange: UInt) {
        if let user = getUser(userID)?.0 {
            user.audioLevel = audioLevel
            tableView.reloadData()
        }
    }
    
    //伴奏播放完成
    func rtcEngineAudioMixingPlayFinish(_ engine: TTTRtcEngineKit!) {
        audioMixingBtn.isSelected = false
        audioMixingBtn.backgroundColor = UIColor.white
    }
    
    //网络丢失（会自动重连）
    func rtcEngineConnectionDidLost(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.showHud(view, message: "网络链接丢失，正在重连...", color: nil)
    }
    
    //重新连接服务器成功
    func rtcEngineReconnectServerSucceed(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.hideHud(for: view)
    }
    
    //重新连接服务器失败，需要退出房间
    func rtcEngineReconnectServerTimeout(_ engine: TTTRtcEngineKit!) {
        TTProgressHud.hideHud(for: view)
        view.window?.showToast("网络丢失，请检查网络")
        engine.leaveChannel(nil)
        dismiss(animated: true, completion: nil)
    }
    
    //在房间内被服务器踢出
    func rtcEngine(_ engine: TTTRtcEngineKit!, didKickedOutOfUid uid: Int64, reason: TTTRtcKickedOutReason) {
        var errorInfo = ""
        switch reason {
        case .kickedOut_ReLogin:
            errorInfo = "重复登录"
        default:
            errorInfo = "未知错误: " + reason.rawValue.description
        }
        view.window?.showToast(errorInfo)
    }
}


extension TCRViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TCRUserCell", for: indexPath) as! TCRUserCell
        cell.configureCell(users[indexPath.row])
        return cell
    }
    
    
}
