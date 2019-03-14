//
//  TCRManager.swift
//  TTTChatRoom
//
//  Created by Work on 2019/3/13.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineVoiceKit

let TTManager = TCRManager.manager

class TCRManager: NSObject {

    public static let manager = TCRManager()
    public var rtcEngine: TTTRtcEngineKit!
    public var me = TCRUser(0)
    
    private override init() {
        super.init()
        //输入对应的AppId
        rtcEngine = TTTRtcEngineKit.sharedEngine(withAppId: <#name#>, delegate: nil)
    }
}
