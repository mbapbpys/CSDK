//
//  ChatSDKResources.m
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 26/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ChatSDKResources.h"

// Global Dictionary
static NSDictionary *chatSDKDefaultsDict;
static NSDictionary *chatSDKConfigDict;

@implementation ChatSDKResources

@synthesize customizeMinimizeState;
@synthesize minimizedButtonPositionPortrait,minimizedButtonPositionLandscape,minimizedButtonBackgroundColor,minimizedButtonTextColor;
@synthesize animationStyle;
@synthesize halignLandscape,halignPortrait;
@synthesize valignLandscape,valignPortrait;
@synthesize heightLandscape,heightPortrait;
@synthesize widthLandscape,widthPortrait;
@synthesize paddingTopPortrait,paddingTopLandscape;
@synthesize paddingBottonLandscape,paddingBottonPortrait;
@synthesize paddingLeftLandscape,paddingLeftPortrait;
@synthesize paddingRightLandscape,paddingRightPortrait,customUrlScheme;
@synthesize chatsdkURL,chatAgentavailabilityURL,chatsdkAccountId,chatsdkQueueId;
@synthesize chatsdkConfigUrl;

bool isValid=YES;

+(ChatSDKResources *)getSDKResourcesInstance
{
    static dispatch_once_t onceToken;
    static ChatSDKResources *chatSDKResources = nil;
    dispatch_once(&onceToken, ^{ chatSDKResources = [[ChatSDKResources alloc] init];
        NSLog(@"Creating Shared object of Chat SDK Resources");
    });

    return chatSDKResources;
}
-(void)initializeValues
{
    chatSDKDefaultsDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatsdkdefaults" ofType:@"plist"]];
    chatSDKConfigDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatsdkconfig" ofType:@"plist"]];
    
    // Initialising chatsdkDefaultsDict values
    customizeMinimizeState = [[chatSDKDefaultsDict objectForKey:@"custom minimize state"] boolValue];
    NSString *tempBgColor = [[chatSDKDefaultsDict objectForKey:@"Mimimized button position"] objectForKey:@"backgroundColor"];
    if(tempBgColor!=nil)
    {
        self.minimizedButtonBackgroundColor= tempBgColor;
        if([tempBgColor isEqualToString:@""])
        {
            isValid=NO;
        }
    }
    NSString *tempTextColor = [[chatSDKDefaultsDict objectForKey:@"Mimimized button position"] objectForKey:@"textColor"];
    
    if(tempTextColor!=nil)
    {
        self.minimizedButtonTextColor = tempTextColor;
        if([tempTextColor isEqualToString:@""])
        {
            isValid=NO;
        }
    }
    
    NSString *tempPortraitPosition = [[chatSDKDefaultsDict objectForKey:@"Mimimized button position"] objectForKey:@"Portrait"];
    if(tempPortraitPosition!=nil)
    {
        if([tempPortraitPosition isEqualToString:@"middle-left"])
        {
            self.minimizedButtonPositionPortrait = tempPortraitPosition;
        }else{
            self.minimizedButtonPositionPortrait = @"middle-right";
        }
    }
    NSString *tempLandscapePosition = [[chatSDKDefaultsDict objectForKey:@"Mimimized button position"] objectForKey:@"Landscape"];
    if(tempLandscapePosition!=nil)
    {
        if([tempLandscapePosition isEqualToString:@"middle-left"])
        {
            self.minimizedButtonPositionLandscape = tempLandscapePosition;
        }else{
            self.minimizedButtonPositionLandscape = @"middle-right";
        }
    }
    NSString *tempAnimationStyle = [chatSDKDefaultsDict objectForKey:@"Animation style"];
    if(tempAnimationStyle!=nil)
    {
        if([tempAnimationStyle isEqualToString:@"top-bottom"] || [tempAnimationStyle isEqualToString:@"bottom-top"] || [tempAnimationStyle isEqualToString:@"left-right"] || [tempAnimationStyle isEqualToString:@"right-left"]){
            self.animationStyle = tempAnimationStyle;
        }else{
            self.animationStyle = @"bottom-top";
        }
    }
    NSString *tempHAlignPortrait = [[chatSDKDefaultsDict objectForKey:@"halign"] objectForKey:@"Portrait"];
    if(tempHAlignPortrait!=nil)
    {
        self.halignPortrait = tempHAlignPortrait;
    }
    NSString *tempHAlignLandscape = [[chatSDKDefaultsDict objectForKey:@"halign"] objectForKey:@"Landscape"];
    if(tempHAlignLandscape!=nil)
    {
        self.halignLandscape = tempHAlignLandscape;
    }
    NSString *tempVAlignPortrait = [[chatSDKDefaultsDict objectForKey:@"valign"] objectForKey:@"Portrait"];
    if(tempVAlignPortrait!=nil)
    {
        self.valignPortrait = tempVAlignPortrait;
    }
    NSString *tempVAlignLandscape = [[chatSDKDefaultsDict objectForKey:@"valign"] objectForKey:@"Landscape"];
    if(tempVAlignLandscape!=nil)
    {
        self.valignLandscape = tempVAlignLandscape;
    }
    NSString *tempHeightPortrait = [[chatSDKDefaultsDict objectForKey:@"height"] objectForKey:@"Portrait"];
    if(tempHeightPortrait!=nil)
    {
        self.heightPortrait = tempHeightPortrait;
    }
    NSString *tempHeightLandscape = [[chatSDKDefaultsDict objectForKey:@"height"] objectForKey:@"Landscape"];
    if(tempHeightLandscape!=nil)
    {
        self.heightLandscape = tempHeightLandscape;
    }
    NSString *tempWidthPortrait = [[chatSDKDefaultsDict objectForKey:@"width"] objectForKey:@"Portrait"];
    if(tempWidthPortrait!=nil)
    {
        self.widthPortrait = tempWidthPortrait;
    }
    NSString *tempWidthLandscape = [[chatSDKDefaultsDict objectForKey:@"width"] objectForKey:@"Landscape"];
    if(tempWidthLandscape!=nil)
    {
        self.widthLandscape = tempWidthLandscape;
    }
    NSString *tempPaddingTopPortrait = [[chatSDKDefaultsDict objectForKey:@"padding-top"] objectForKey:@"Portrait"];
    if(tempPaddingTopPortrait!=nil)
    {
        self.paddingTopPortrait = tempPaddingTopPortrait;
    }
    NSString *tempPaddingTopLandscape = [[chatSDKDefaultsDict objectForKey:@"padding-top"] objectForKey:@"Landscape"];
    if(tempPaddingTopLandscape!=nil)
    {
        self.paddingTopLandscape = tempPaddingTopLandscape;
    }/////
    NSString *tempPaddingBottomPortrait = [[chatSDKDefaultsDict objectForKey:@"padding-bottom"] objectForKey:@"Portrait"];
    if(tempPaddingBottomPortrait!=nil)
    {
        self.paddingBottonPortrait = tempPaddingBottomPortrait;
    }
    NSString *tempPaddingBottomLandscape = [[chatSDKDefaultsDict objectForKey:@"padding-bottom"] objectForKey:@"Landscape"];
    if(tempPaddingBottomLandscape!=nil)
    {
        self.paddingBottonLandscape = tempPaddingBottomLandscape;
    }
    NSString *tempPaddingLeftPortrait = [[chatSDKDefaultsDict objectForKey:@"padding-left"] objectForKey:@"Portrait"];
    if(tempPaddingLeftPortrait!=nil)
    {
        self.paddingLeftPortrait = tempPaddingLeftPortrait;
    }
    NSString *tempPaddingLeftLandscape = [[chatSDKDefaultsDict objectForKey:@"padding-left"] objectForKey:@"Landscape"];
    if(tempPaddingLeftLandscape!=nil)
    {
        self.paddingLeftLandscape = tempPaddingLeftLandscape;
    }
    NSString *tempPaddingRightPortrait = [[chatSDKDefaultsDict objectForKey:@"padding-right"] objectForKey:@"Portrait"];
    if(tempPaddingRightPortrait!=nil)
    {
        self.paddingRightPortrait = tempPaddingRightPortrait;
    }
    NSString *tempPaddingRightLandscape = [[chatSDKDefaultsDict objectForKey:@"padding-right"] objectForKey:@"Landscape"];
    if(tempPaddingRightLandscape!=nil)
    {
        self.paddingRightLandscape = tempPaddingRightLandscape;
    }
    NSString *tempCustomURLScheme = [chatSDKDefaultsDict objectForKey:@"customURLScheme"];
    if(tempCustomURLScheme!=nil)
    {
        self.customUrlScheme = tempCustomURLScheme;
    }
    //Values from chatsdkconfig.plist
    NSString *tempChatsdkURL = [chatSDKConfigDict objectForKey:@"chatsdk_url"];
    if(tempChatsdkURL!=nil)
    {
        if([tempChatsdkURL isEqualToString:@""]){
            isValid=NO;
        }
        self.chatsdkURL = tempChatsdkURL;
    }
    NSString *tempChatAgentavailabilityURL = [chatSDKConfigDict objectForKey:@"chatsdk_agentavailability_url"];
    if(tempChatAgentavailabilityURL!=nil)
    {
        self.chatAgentavailabilityURL = tempChatAgentavailabilityURL;
    }
    NSString *tempChatsdkAccountId = [chatSDKConfigDict objectForKey:@"chatsdk_accountId"];
    if(tempChatsdkAccountId!=nil)
    {
        self.chatsdkAccountId = tempChatsdkAccountId;
    }
    NSString *tempChatsdkQueueId = [chatSDKConfigDict objectForKey:@"chatsdk_queueId"];
    if(tempChatsdkQueueId!=nil)
    {
        self.chatsdkQueueId = tempChatsdkQueueId;
    }
    
    NSString *tempChatsdkConfigUrl = [chatSDKConfigDict objectForKey:@"chatsdk_config_url"];
    if(tempChatsdkQueueId!=nil)
    {
        self.chatsdkConfigUrl = tempChatsdkConfigUrl;
    }
    
    if((tempChatsdkURL==nil)||(tempChatAgentavailabilityURL==nil)||(tempChatsdkAccountId==nil)||(tempChatsdkQueueId==nil)||(tempPortraitPosition==nil)||(tempLandscapePosition==nil)||(tempCustomURLScheme==nil)||(tempBgColor==nil)||(tempTextColor==nil)){
        isValid=NO;
    }
}

-(bool)isXMLValid{       
    return isValid;
}

@end
