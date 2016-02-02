//
//  ChatSDKCallbacks.h
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 09/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChatSDKError.h"

// Delegate declaration (Required to be implemented by Application)
@protocol ChatSDKDelegate <NSObject>

@required
/*
 * onChatAgentAvailability   This notification will be called as a callback of checkAgentAvailability
                             method. It has a Boolean parameter, which denotes the availability of the
                             agent. Based on the response the application developer should enable or 
                             disable the “Chat Now” button in the application.
 * @param connected          A  boolean representing the availability of the chat agent.
 */
-(void)onChatAgentAvailability:(BOOL)connected;

/*
 * onChatError               Notifies application developer when an error has occurred. This is a 
                             required notification to handle errors thrown by the SDK. The argument
                             dictionary contains the error code (see Section 3 for details) & the 
                             exception error string that can be used for debugging.
 * @param data               A NSError object containing error code and exception/error string
 */
-(void)onChatError:(ChatSDKError *)error;


@optional
/*
 * onChatStarted             Notifies application when chat has started. This is an optional 
                             notification and can be used to retrieve the session id of the chat
                             session. The application developer can perform any application specific 
                             functions such as logging upon receipt of this notification.
* @param data                Data dictionary one key/value pair which is the identifier of the active
                             chat session
 */
-(void)onChatStarted:(NSDictionary*)data;

/*
 * onChatEnded               Notifies application when chat has ended and the view has been closed. 
                             This is an optional notification, and should be handled if the client 
                             application needs to do any cleanup after chat has ended. Application
                             developer can perform any application specific functions such as logging
                             upon receipt of this notification.
 * @param data               Empty. Reserved for future use.
 */
-(void)onChatEnded:(NSDictionary*) data;

/*
 * onAgentMessage            Notifies application when a new agent message has been received in the 
                             Chat. This is an optional notification and can be used with a custom 
                             minimize state to inform the user that the agent has sent a message.
 * @param data               Empty. Reserved for future use.
 */
-(void)onAgentMessage:(NSDictionary*)data;

/*
 * onChatMinimized           Notifies application when the chat view has been hidden from the end user. 
                             This is an optional notification and can be used to display a custom 
                             minimized button that the user can click to go back into chat.
 * @param data               Empty. Reserved for future use.
 */
-(void)onChatMinimized:(NSDictionary *)data;

/*
 * onChatMaximized           Notifies application when the chat view has been displayed back to the end 
                             user. This is an optional notification and should be handled if the application 
                             developer needs to perform any application specific functions when chat screen 
                             gets maximized
 * @param data               Empty. Reserved for future use.
 */
-(void)onChatMaximized:(NSDictionary *)data;

/*
 * onNavigationRequest      Notifies application developer when a custom URL specified in configuration XML
                            is received in the  chat and has been clicked by the end user. This is an optional 
                            notification.
 * @param data              Holds a key 'url' with custom URL
 */
-(void)onNavigationRequest:(NSDictionary *)data;

@end

@interface ChatSDKCallbacks : NSObject
{
    id <ChatSDKDelegate> delegate;
}

@property(nonatomic,strong) id<ChatSDKDelegate> delegate;

// Instance methods
-(void)onChatStartedDelegateHandler:(NSDictionary *)dataDictionary;

-(void)onChatEndedDelegateHandler:(NSDictionary *)dataDictionary;

-(void)onChatAgentAvailabilityDelegateHandler:(BOOL)connectedAgent;

-(void)onAgentMessageDelegateHandler:(NSDictionary *)dataDictionary;

-(void)onChatMinimizedDelegateHandler:(NSDictionary *)dataDictionary;

-(void)onChatMaximizedDelegateHandler:(NSDictionary *)dataDictionary;

-(void)onChatErrorDelegateHandler:(ChatSDKError *)error;

-(void)onNavigationRequestHandler:(NSDictionary *)dataDictionary;

@end
