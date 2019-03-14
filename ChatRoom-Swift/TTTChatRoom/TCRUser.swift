//
//  TCRUser.swift
//  TTTChatRoom
//
//  Created by Work on 2019/3/13.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit
import TTTRtcEngineVoiceKit

class TCRUser: NSObject {

    var uid: Int64 = 0
    var role = TTTRtcClientRole.clientRole_Audience
    var mutedSelf = false //是否静音
    var audioLevel: UInt = 0
    init(_ uid: Int64) {
        self.uid = uid
    }
}
