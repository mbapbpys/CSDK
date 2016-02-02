//
//  ChatSDKResources.h
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 26/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatSDKResources : NSObject
{
    // CHATSDKDEFAULTS
    BOOL customizeMinimizeState;
    // Minimized Button Position
    NSString *minimizedButtonPositionPortrait;
    NSString *minimizedButtonPositionLandscape;
    NSString *minimizedButtonTextColor;
    NSString *minimizedButtonBackgroundColor;
    // animation style
    NSString *animationStyle;
    // HAlign
    NSString *halignPortrait;
    NSString *halignLandscape;
    //VAlign
    NSString *valignPortrait;
    NSString *valignLandscape;
    // Height
    NSString *heightPortrait;
    NSString *heightLandscape;
    // width
    NSString *widthPortrait;
    NSString *widthLandscape;
    // padding-top
    NSString *paddingTopPortrait;
    NSString *paddingTopLandscape;
    // padding bottom
    NSString *paddingBottonPortrait;
    NSString *paddingBottonLandscape;
    // padding left
    NSString *paddingLeftPortrait;
    NSString *paddingLeftLandscape;
    // padding right
    NSString *paddingRightPortrait;
    NSString *paddingRightLandscape;
    // custom url scheme
    NSString *customUrlScheme;
    
    // CHATSDKCONFIG
    NSString *chatsdkURL;
    NSString *chatAgentavailabilityURL;
    NSString *chatsdkAccountId;
    NSString *chatsdkQueueId;
        NSString *chatsdkConfigUrl;
    
    
    
}

@property (nonatomic ,assign) BOOL customizeMinimizeState;
@property (nonatomic ,strong) NSString *minimizedButtonPositionPortrait;
@property (nonatomic ,strong) NSString *minimizedButtonPositionLandscape;
@property (nonatomic ,strong) NSString *minimizedButtonTextColor;
@property (nonatomic ,strong) NSString *minimizedButtonBackgroundColor;
@property (nonatomic ,strong) NSString *animationStyle;
@property (nonatomic ,strong) NSString *halignPortrait;
@property (nonatomic ,strong) NSString *halignLandscape;
@property (nonatomic ,strong) NSString *valignPortrait;
@property (nonatomic ,strong) NSString *valignLandscape;
@property (nonatomic ,strong) NSString *heightPortrait;
@property (nonatomic ,strong) NSString *heightLandscape;
@property (nonatomic ,strong) NSString *widthPortrait;
@property (nonatomic ,strong) NSString *widthLandscape;
@property (nonatomic ,strong) NSString *paddingTopPortrait;
@property (nonatomic ,strong) NSString *paddingTopLandscape;
@property (nonatomic ,strong) NSString *paddingBottonPortrait;
@property (nonatomic ,strong) NSString *paddingBottonLandscape;
@property (nonatomic ,strong) NSString *paddingLeftPortrait;
@property (nonatomic ,strong) NSString *paddingLeftLandscape;
@property (nonatomic ,strong) NSString *paddingRightPortrait;
@property (nonatomic ,strong) NSString *paddingRightLandscape;
@property (nonatomic ,strong) NSString *customUrlScheme;
@property (nonatomic ,strong) NSString *chatsdkURL;
@property (nonatomic ,strong) NSString *chatAgentavailabilityURL;
@property (nonatomic ,strong) NSString *chatsdkAccountId;
@property (nonatomic ,strong) NSString *chatsdkQueueId;
@property (nonatomic ,strong) NSString *chatsdkConfigUrl;

// Shared instance of ChatSDK class
+(ChatSDKResources *)getSDKResourcesInstance;

-(void)initializeValues;
-(bool)isXMLValid;

@end
