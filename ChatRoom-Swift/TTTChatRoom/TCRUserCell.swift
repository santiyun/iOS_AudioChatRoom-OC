//
//  TCRUserCell.swift
//  TTTChatRoom
//
//  Created by Work on 2019/3/13.
//  Copyright © 2019 yanzhen. All rights reserved.
//

import UIKit

class TCRUserCell: UITableViewCell {

    @IBOutlet private weak var headImgView: UIImageView!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var mutedBtn: UIButton!
    @IBOutlet private weak var volumeLabel: UILabel!
    
    public func configureCell(_ user: TCRUser) {
        if TTManager.me == user {
            headImgView.image = #imageLiteral(resourceName: "7")
            idLabel.text = user.uid.description + "(我)"
        } else {
            idLabel.text = user.uid.description
            headImgView.image = #imageLiteral(resourceName: "4")
        }
        mutedBtn.isSelected = user.mutedSelf
        volumeLabel.text = "volume: \(user.audioLevel)"
    }

}
