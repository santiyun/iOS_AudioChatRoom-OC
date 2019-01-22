//
//  TCRUserCell.m
//  TTTChatRoom
//
//  Created by Work on 2019/1/19.
//  Copyright © 2019 Work. All rights reserved.
//

#import "TCRUserCell.h"
#import "TCRManager.h"

@interface TCRUserCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;

@end

@implementation TCRUserCell

- (void)configureCell:(TCRUser *)user {
    if (TCRManager.manager.me == user) {
        _headImgView.image = [UIImage imageNamed:@"7"];
        _idLabel.text = [NSString stringWithFormat:@"%lld(我)", user.uid];
    } else {
        _headImgView.image = [UIImage imageNamed:@"4"];
        _idLabel.text = [NSString stringWithFormat:@"%lld", user.uid];
    }
    _mutedBtn.selected = user.mutedSelf;
    _volumeLabel.text = [NSString stringWithFormat:@"volume: %d", user.audioLevel];
}

@end
