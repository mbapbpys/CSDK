//
//  NativeModalAction.h
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 17/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatSDKBridgeAction : NSObject
{
    NSString *chatAction;
    NSDictionary *chatParams;
}

@property(copy) NSString *action;
@property(strong) NSDictionary *params;

- (id)initWithAction:(NSString *)action andParams:(NSDictionary *)params;

@end
