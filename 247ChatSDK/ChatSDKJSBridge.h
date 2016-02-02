//
//  JSBridge.h
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 17/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>

@class ChatSDKBridgeAction;
@protocol ChatSDKJSBridgeDelegate;

@interface ChatSDKJSBridge : NSURLCache
{
    id <ChatSDKJSBridgeDelegate> __weak bridgeDelegate;
}

@property(weak) id <ChatSDKJSBridgeDelegate> delegate;
@end

//Declaring protocol
@protocol ChatSDKJSBridgeDelegate <NSObject>
- (NSDictionary *)executeNative:(ChatSDKBridgeAction *)action error:(NSError **)error;
@end

// Getter-setter for ChatSDKJSBridgeDelegate
@interface NSURLCache (ChatSDKJSBridge)
+ (id <ChatSDKJSBridgeDelegate>)ChatSDKJSBridgeDelegate;

+ (void)setChatSDKJSBridgeDelegate:(id <ChatSDKJSBridgeDelegate>)delegate;


@end