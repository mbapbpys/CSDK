//
//  NativeModalAction.m
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 17/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ChatSDKBridgeAction.h"

@implementation ChatSDKBridgeAction

@synthesize params = chatParams;


- (id)initWithAction:(NSString *)action andParams:(NSDictionary *)params {
    self = [super init];
    if (self) {
        self.action = action;
        chatParams = params;
    }
    return self;
}

// Getter-setter for action
- (NSString *)action {
    return chatAction;
}

- (void)setAction:(NSString *)action {
    if (chatAction != action) {
        chatAction = [action lowercaseString];
    }
}

@end
