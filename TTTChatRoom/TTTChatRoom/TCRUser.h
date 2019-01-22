//
//  TCRUser.h
//  TTTChatRoom
//
//  Created by Work on 2019/1/18.
//  Copyright © 2019 Work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTTRtcEngineVoiceKit/TTTRtcEngineVoiceKit.h>

@interface TCRUser : NSObject
@property (nonatomic, assign) int64_t uid;
@property (nonatomic, assign) TTTRtcClientRole role;
@property (nonatomic, assign) BOOL mutedSelf;
@property (nonatomic, assign) int audioLevel;

- (instancetype)initWithUid:(int64_t)uid;
@end

