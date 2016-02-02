//
//  ChatSDK.h
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 09/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatSDKCallbacks.h"


@class ChatSDKCallbacks;

@interface ChatSDK : NSObject
{
    ChatSDKCallbacks *chatSDKCallbacks;
}

@property (nonatomic, strong) ChatSDKCallbacks *chatSDKCallbacks;


/*
 allowLocationAccess : If App developer does not want to Allow ChatSDK to enable location services then they can set value false in it.
 Default value : True
 */
@property (assign) BOOL allowLocationAccess;


// Shared instance of ChatSDK class
+(ChatSDK *)getSDKInstance;
/* initializeChatInitialize     all of the required core SDK resources
 * @param id(in)                An anonymous object as required eg. object of AppDelegate
 * @returns                     An ChatSDK shared Object
 */
+(ChatSDK *)initializeChat:(id)appDelegate;

/*
 * setChatDelegate              This method is used to check if agents are available for chat.
                                Based on the response given to the delegate, the application 
                                developer should enable or disable the “Chat Now” button in 
                                the application
 */
-(void)setChatDelegate:(id)listener;

/*
 * checkAgentAvailability       This method registers the object passed as the argument as the
                                listener of the Chat SDK events created by the [24]7 Native Chat
                                SDK.The object passed in is an instance of a class,
                                which conforms to ChatSDKDelegate that contains abstract functions
                                for the notifications.
 * @param listener(in)          An object that conforms to ChatSDKDelegate
 
 * @param queueId(in)       NSString containing queueId that will be used to check agent availability from multiple agent queue.
 e.g. We have multiple queue1,queue2,queue3..etc, and if we pass queue2 in parameter then this fuction will check agent availability of queue2.
 
 
*/
-(void)checkAgentAvailability :(NSString*)queueId;

/*
 * startChat                    This method is used to load the chat view in the application. Any 
                                pre-chat related context information that is passed as a dictionary
                                into the method will be displayed on the [24]7. Assist, agent console,
                                when the chat gets connected to the agent. The configuration properties
                                (see Section 4 and Section 5) like height, width, alignment, padding, 
                                etc are read from the configuration Plist in the application directly. 
                                Defaults are set for all the configuration properties, so the client app
                                developer does not need to set any of these properties
 * @param contextInfo(in)       NSDictionary containing any application specific pre-chat related context
                                information that will be displayed on the [24]7 Assist agent console when 
                                the chat gets connected to the agent. Some examples of context information
                                that the application may send over to the agent console include email, name
                                & account number.
 
 * @param queueId(in)       NSString containing queueId that will be displayed on the [24]7 Assist agent console when
 the chat gets connected to the agent.
 
 
*/
-(void)startChat:(NSDictionary*)contextInfo andQueue:(NSString*)queueId;

/*
 * maximizeChat                 This is an optional method that is used only in the case when the
                                application has overridden the minimize functionality provided by 
                                theSDK. This method is used to bring back the chat into view if chat
                                has been minimized by user action or by the application. The animation
                                to be used should be configured in the configuration Plist. By default,
                                the chat view will animate bottom to top, and this can be overridden 
                                by changing the configuration in the configuration plist
                                (See Section 4).
 * This method takes no input arguments.
*/
-(void)maximizeChat;

/*
 * minimizeChat                 This is an optional method that could be used by the application to 
                                minimize the chat view. By default, the SDK handles minimizing when 
                                the user clicks on hide or minimize buttons during an active chat 
                                session. This method is to be used only in exceptional cases when 
                                the end-user navigates away from a screen to another screen, and the
                                application developer would like the chat to be minimized instead of 
                                chat continuing to stay on top of the new screen. This method will 
                                cause the chat view to get animated in the reverse direction of how 
                                it came into view. The default animation will be top->bottom since
                                the default animation of the chat coming into view is bottom->top.
 * This method takes no input arguments.
 */
-(void)minimizeChat;

/*
 * endChat                      This is an optional method that could be called to programmatically 
                                end chat session and close the chat view. By default, the SDK handles
                                the action of closing the chat session and the chat view when the 
                                end-user clicks on chat. This method destroys the active session of 
                                the chat, and a new chat must be requested as needed via the startChat 
                                method.
 * This method takes no input arguments.
 */
-(void)endChat;



@end
