//
//  TCRLoginViewController.swift
//  TTTChatRoom
//
//  Created by Work on 2019/3/13.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineVoiceKit

class TCRLoginViewController: UIViewController {

    private var uid: Int64 = 0
    private var roleSelectedBtn: UIButton!
    @IBOutlet private weak var broBtn: UIButton!
    @IBOutlet private weak var audienceBtn: UIButton!
    @IBOutlet private weak var roomIDTF: UITextField!
    @IBOutlet private weak var versionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        roleSelectedBtn = broBtn
        versionLabel.text = TTTRtcEngineKit.getSdkVersion()
        uid = Int64(arc4random() % 1000000) + 1
        if let rid = UserDefaults.standard.value(forKey: "ENTERROOMID") as? Int64 {
            roomIDTF.text = rid.description
        } else {
            roomIDTF.text = (arc4random() % 1000000 + 1).description
        }
        
    }
    //选择角色
    @IBAction private func roleSelectedAction(_ sender: UIButton) {
        if sender.isSelected { return }
        roleSelectedBtn.isSelected = false
        roleSelectedBtn.backgroundColor = UIColor.black
        sender.isSelected = true
        sender.backgroundColor = UIColor.cyan
        roleSelectedBtn = sender
    }
    
    @IBAction private func joinChannel(_ sender: UIButton) {
        if roomIDTF.text == nil || roomIDTF.text!.count == 0 || roomIDTF.text!.count >= 19 {
            showToast("请输入19位以内的房间ID")
            return
        }
        let rid = Int64(roomIDTF.text!)!
        UserDefaults.standard.set(rid, forKey: "ENTERROOMID")
        UserDefaults.standard.synchronize()
        TTProgressHud.showHud(view)
        
        var role = TTTRtcClientRole.clientRole_Broadcaster
        TTManager.me.uid = uid
        TTManager.me.mutedSelf = false
        TTManager.me.role = role
        
        if roleSelectedBtn == audienceBtn {
            role = .clientRole_Audience
        }
        
        //初始化工具管理类，内部初始化了TTTRtcEngineKit对象
        //设置代理
        TTManager.rtcEngine.delegate = self
        //设置频道属性为通信模式
        TTManager.rtcEngine.setChannelProfile(.channelProfile_Communication)
        //设置用户角色
        TTManager.rtcEngine.setClientRole(role)
        //启动音量监听
        TTManager.rtcEngine.enableAudioVolumeIndication(1000, smooth: 3)
        //启用音频，该方法设置的状态是全局的，退出频道不会重置用户的状态
        TTManager.rtcEngine.muteLocalAudioStream(false)
        //加入频道
        TTManager.rtcEngine.joinChannel(byKey: nil, channelName: roomIDTF.text, uid: uid, joinSuccess: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension TCRLoginViewController: TTTRtcEngineDelegate {
    func rtcEngine(_ engine: TTTRtcEngineKit!, didJoinChannel channel: String!, withUid uid: Int64, elapsed: Int) {
        TTProgressHud.hideHud(for: view)
        performSegue(withIdentifier: "PK", sender: nil)
    }
    
    func rtcEngine(_ engine: TTTRtcEngineKit!, didOccurError errorCode: TTTRtcErrorCode) {
        var errorInfo = ""
        switch errorCode {
        case .error_Enter_TimeOut:
            errorInfo = "超时,10秒未收到服务器返回结果"
        case .error_Enter_Failed:
            errorInfo = "无法连接服务器"
        case .error_Enter_BadVersion:
            errorInfo = "版本错误"
        case .error_InvalidChannelName:
            errorInfo = "Invalid channel name"
        default:
            errorInfo = "未知错误: " + errorCode.rawValue.description
        }
        TTProgressHud.hideHud(for: view)
        showToast(errorInfo)
    }
}
