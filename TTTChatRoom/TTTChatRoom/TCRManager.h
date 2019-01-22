//
//  TCRManager.h
//  TTTChatRoom
//
//  Created by Work on 2019/1/18.
//  Copyright © 2019 Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineVoiceKit/TTTRtcEngineVoiceKit.h>
#import "TCRUser.h"

@interface TCRManager : NSObject
@property (nonatomic, strong) TTTRtcEngineKit *rtcEngine;
@property (nonatomic, strong) TCRUser *me;

+ (instancetype)manager;
@end

