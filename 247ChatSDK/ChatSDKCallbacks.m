//
//  ChatSDKCallbacks.m
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 09/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ChatSDKCallbacks.h"


@implementation ChatSDKCallbacks

@synthesize delegate;

// Delegate to start chat
-(void)onChatStartedDelegateHandler:(NSDictionary *)dataDictionary
{
    [delegate onChatStarted:dataDictionary];
}

// Delegate to End Chat
-(void)onChatEndedDelegateHandler:(NSDictionary *)dataDictionary
{
    [delegate onChatEnded:dataDictionary];
}

// Delegate to check Agent availability
-(void)onChatAgentAvailabilityDelegateHandler:(BOOL)connectedAgent
{
    [delegate onChatAgentAvailability:connectedAgent];
}

// Delegate to notify new message
-(void)onAgentMessageDelegateHandler:(NSDictionary *)dataDictionary
{
    [delegate onAgentMessage:dataDictionary];
}

// Delegate to minimize chat window
-(void)onChatMinimizedDelegateHandler:(NSDictionary *)dataDictionary
{
    [delegate onChatMinimized:dataDictionary];
}

// Delegate to maximize chat window
-(void)onChatMaximizedDelegateHandler:(NSDictionary *)dataDictionary
{
    [delegate onChatMaximized:dataDictionary];
}

// Delegate to show error
-(void)onChatErrorDelegateHandler:(ChatSDKError *)error
{
    [delegate onChatError:error];
}

//Delegate for custom url handling
-(void)onNavigationRequestHandler:(NSDictionary *)dataDictionary
{
    [delegate onNavigationRequest:dataDictionary];
}

@end
