//
//  TCRUser.m
//  TTTChatRoom
//
//  Created by Work on 2019/1/18.
//  Copyright © 2019 Work. All rights reserved.
//

#import "TCRUser.h"

@implementation TCRUser
- (instancetype)initWithUid:(int64_t)uid {
    self = [super init];
    if (self) {
        _uid = uid;
    }
    return self;
}
@end
