//
//  ChatSDK.m
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 09/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ChatSDK.h"
#import "ChatSDKBridgeAction.h"
#import "ChatSDKJSBridge.h"
#import <dispatch/dispatch.h>
#import "ChatSDKError.h"
#import "ChatSDKConstants.h"
#import "ChatSDKResources.h"
#import "ChatSDKWebView.h"
#import "ChatSDKMaximizeButton.h"
#import "ChatSDKAlertViewBlock.h"
#import "ChatSDKLocation.h"
#import "ChatSDKCAServerDetailParsing.h"
#import "Reachability.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000     
    // App compiled with iOS7 or later
    int COMPILED_WITH_VER =7;
#else
    // App compiled with iOS6
    int COMPILED_WITH_VER =6;
#endif

static UIWindow *chatWindow = nil;
static ChatSDK *sharedInstance = nil;

typedef enum {
    ChatSDKStartError,
    ChatSDKAnimationError,
    ChatSDKNetworkError,
    ChatSDKEndError,
    ChatSDKUnknownError,
    ChatSDKChatNotStartedError,
    ChatSDKInvalidParameterError
}ChatSDKErrorCode;

@interface ChatSDK ()<UIWebViewDelegate,ChatSDKJSBridgeDelegate,ChatSDKLocationDelegate>
{
    // Add new instance variable
    dispatch_queue_t backgroundQueue;
    ChatSDKWebView *chatWebview;
    ChatSDKMaximizeButton *chatButton;
    NSDictionary *contextInfoDict;
    UIActivityIndicatorView *indicatorView;
    ChatSDKError *sdkError;
    UIDeviceOrientation orientation;
    // Boolean variable to have check on first load
    BOOL firstTimeFlag;
    // Array which holds position
    ChatSDKResources *chatSDKResources;
    Reachability *internetReachable;
    ChatSDKJSBridge *cache;
    NSURLCache *globalCache;
    
    NSString *chatSDKqueueId;
    ChatSDKLocation *chatSDKLocation;
    ChatSDKCAServerDetailParsing *chatSDKCAServerDetailParsing;
}

@property (nonatomic,strong) ChatSDKLocation *chatSDKLocation;
@property (nonatomic,strong) ChatSDKMaximizeButton *chatButton;
@property (nonatomic,strong) NSDictionary *contextInfoDict;
@property (nonatomic,strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic,assign) BOOL firstTimeFlag;


@property (nonatomic,strong) NSString *chatSDKqueueId;
// Defining Methods
-(NSInteger)getErrorCode:(NSInteger )errorCode;
-(NSString *)getErrorMessage:(NSInteger )errorCode;
-(ChatSDKMaximizeButton *)createChatButton;

@end

@implementation ChatSDK

@synthesize chatSDKCallbacks;
@synthesize chatButton = _chatButton;
@synthesize contextInfoDict = _contextInfoDict;
@synthesize indicatorView = _indicatorView;
@synthesize firstTimeFlag = _firstTimeFlag;
@synthesize chatSDKqueueId=_chatSDKqueueId;
@synthesize allowLocationAccess=_allowLocationAccess;
@synthesize chatSDKLocation=_chatSDKLocation;

- (id)init
{
    if (self = [super init])
    {
        chatSDKCallbacks = [[ChatSDKCallbacks alloc] init];
        chatSDKResources = [[ChatSDKResources alloc] init];
        
        
        //By default allow sdk to access location.
        self.allowLocationAccess=YES;
        
        //register notification for background and foreground
        [self registerNotificationForApplicationState];
        
        [chatSDKResources initializeValues];
        
        sdkError = [[ChatSDKError alloc] init];
        
        backgroundQueue = dispatch_queue_create("com.inc247.dispatchQueue", NULL);

        //live
        //parse checkAvailabilitty from server.
        [self getMultipleCAServerURL];

        [self startNetworkCheck];
    }
    return self;
}
/********************************************************************************
 ** Function Name       : startNetworkCheck
 ** Description         : Start network notifier for tracking internet rechability changes
 ** Input Parameters    : nil
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/

-(void)startNetworkCheck
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus:)
                                                 name:kReachabilityChangedNotification object:nil];
    
    if (!internetReachable)
    {
        internetReachable = [Reachability reachabilityForInternetConnection];
        
        [internetReachable startNotifier];
        
        if (![self isReachableToInternet])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Check internet connection , Internet is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }
    
    
}
/********************************************************************************
 ** Function Name       : isReachableToInternet
 ** Description         : check weather network is rechable or not
 ** Input Parameters    : nil
 ** Output Parameters   : BOOL
 ** Return Values       : BOOL
 *******************************************************************************/

-(BOOL)isReachableToInternet
{
    
    Reachability *objReachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus1 internetStatus = [objReachability currentReachabilityStatus];
    
    if(internetStatus != NotReachable1)
    {
        return YES;
    }
    
    
    return NO;
    
}

// Network delegate if network state changed

- (void)checkNetworkStatus:(NSNotification *)notice {
    // called after network status changes
    
    
    NetworkStatus1 internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable1:
        {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Check internet connection , Internet is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [alert show];
            
            break;
        }
        case ReachableViaWiFi1:
        {
            
            break;
        }
        case ReachableViaWWAN1:
        {
            
            break;
        }
    }
}

-(void)getMultipleCAServerURL
{
    NSString *url=chatSDKResources.chatsdkConfigUrl;
    
    //local url
    //url=@"http://localhost/livechatsdk/check_availability.xml"
    chatSDKCAServerDetailParsing=[[ChatSDKCAServerDetailParsing alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    NSLog(@"chatSDKCAServerDetailParsing >> %@",chatSDKCAServerDetailParsing.caXmlResponse);
}
+(ChatSDK *)getSDKInstance
{
    if(sharedInstance != nil){
        return sharedInstance;
    }else{
        NSLog(@"Please call initializeChat before calling any other method of ChatSDK.");
        return nil;
    }
}

/********************************************************************************
 ** Function Name       : initializeChat
 ** Description         : Initialize all of the required core SDK resources
 ** Input Parameters    : appDelegate       -- Instance of AppDelegate
 ** Output Parameters   : None
 ** Return Values       : ChatSDK instance  -- Shared Instance of ChatSDK 
*******************************************************************************/
+(ChatSDK *)initializeChat:(id)anonymous
{
    static dispatch_once_t onceToken;
    static ChatSDK *chatSDK = nil;
    dispatch_once(&onceToken, ^{ chatSDK = [[ChatSDK alloc] init];
    });
    // Assigning the local chatWindow to application window
    chatWindow = [anonymous window];
    chatWindow.autoresizesSubviews = YES;
    sharedInstance = chatSDK;
    return chatSDK;
}

/********************************************************************************
 ** Function Name       : setChatDelegate
 ** Description         : Set the delegate chatSDKDelegate to listener
 ** Input Parameters    : listener
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)setChatDelegate:(id)listener
{
    ChatSDKCallbacks *objCallBacks = self.chatSDKCallbacks;
    [objCallBacks setDelegate:listener];
}

/********************************************************************************
 ** Function Name       : checkAgentAvailability
 ** Description         : Check if agents are available for chat
 ** Input Parameters    : queueId
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)checkAgentAvailability :(NSString*) queueId;
{
    if(_indicatorView!=nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"247ChatSDK" message:@"Process allready Running" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        // Starting the indicator view initially
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.center = chatWindow.center;
        [chatWindow addSubview:_indicatorView];
        [_indicatorView startAnimating];
        
        //https://api-pe-assist.px.247-inc.com/en/ca/rest/checkAvailability?queueId=lnd-queue-customer-support&accountId=lnd-account-1
        
        NSDictionary *caAgentUrl=[NSDictionary dictionaryWithDictionary:chatSDKCAServerDetailParsing.caXmlResponse];
        
        NSString *agentAvailabilityURL=[caAgentUrl objectForKey:queueId];
        
        //If we don't have any agentQueueURL of the given queueId the we have to use chatSDKResources value (url,queueId,accountId) to create url of checkAgentAvailability.
        if (!agentAvailabilityURL) {
            agentAvailabilityURL = [NSString stringWithFormat:@"%@?queueId=%@&accountId=%@",chatSDKResources.chatAgentavailabilityURL,chatSDKResources.chatsdkQueueId,chatSDKResources.chatsdkAccountId];
        }
        
        //NSString *agentAvailabilityURL = [NSString stringWithFormat:@"%@?queueId=%@&accountId=%@",chatSDKResources.chatAgentavailabilityURL,chatSDKResources.chatsdkQueueId,chatSDKResources.chatsdkAccountId];
        
        dispatch_async(backgroundQueue, ^(void) {
            NSError* error = nil;
            NSData* data;
            
            
            /* fetching list of SBC from webserver */
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:agentAvailabilityURL] options:0 error:&error];
            /* If list fetched then parse the JSON data for list of SBC */
            if (!error) {
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                     options:kNilOptions
                                                                       error:&error];
                
                NSDictionary* dataDictionary = [json objectForKey:@"data"];
                NSString *agentStatus = [dataDictionary objectForKey:@"caStatus"];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT AGENT AVAILABILITY
                    [chatSDKCallbacks onChatAgentAvailabilityDelegateHandler:[agentStatus boolValue]];
                    if(_indicatorView!=nil)
                    {
                        [_indicatorView stopAnimating];
                        [_indicatorView removeFromSuperview];
                        _indicatorView = nil;
                    }
                });
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    // Fetching Error Code
                    ChatSDKErrorCode  errorCode = ChatSDKNetworkError;
                    sdkError.code = [self getErrorCode:errorCode];
                    sdkError.message = [self getErrorMessage:errorCode];
                    if(_indicatorView!=nil)
                    {
                        [_indicatorView stopAnimating];
                        [_indicatorView removeFromSuperview];
                        _indicatorView=nil;
                    }
                    // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ONCHATERROR
                    [chatSDKCallbacks onChatErrorDelegateHandler:sdkError];
                    
                });
                
            }
            
        });
    }
}


/********************************************************************************
 ** Function Name       : startChat
 ** Description         : This method is used to load the chat view in the 
                          application
 ** Input Parameters    : contextInfo -- Dictionary containing any application
                                         specific pre-chat related context information
                          queueId -- String contain queueId passed by appdeveloper
                                     Will be send to agent consol while then envoke getQueueId function.
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)startChat:(NSDictionary*)contextInfo andQueue:(NSString*) queueId;
{
    if (![self isReachableToInternet])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Check internet connection , Internet is not available" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [alert show];
    }

    if([chatSDKResources isXMLValid])
    {
        if(!chatWebview)
        {
            //Saving default cache to globalCache for restoring it at chat minimized & end chat
            globalCache = [NSURLCache sharedURLCache];
            
            //Create an instance of our custom NSURLCache object to use to check any outgoing requests in our app
            cache = [[ChatSDKJSBridge alloc] init];
            
            //Setting cache to JSBridge cache
            [NSURLCache setSharedURLCache:nil];
            [NSURLCache setSharedURLCache:cache];
            
            //Saving the contextInfo globally
            _contextInfoDict = contextInfo;
            
            //saving queue id globally
            _chatSDKqueueId=queueId;
            
            
            // Check the device
            chatWebview = [[ChatSDKWebView alloc] init];
            
            //[[chatWebview scrollView] setBounces: NO];
           // chatWebview.scalesPageToFit = YES;
           // chatWebview.contentMode = UIViewContentModeScaleAspectFit;
            //chatWebview.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VER>=7)
                {
                    //Default resizing
                    [chatWebview resetWebViewForIpadWithFrame];
                }else{
                    [chatWebview resetWebViewForIpad];
                }
            }
            else
            {
                if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VER>=7)
                {
                    [chatWebview resetWebViewWithFrame];
                }else{
                    [chatWebview resetWebView];
                }
            }
            
            //Making maximize button
            if(!_chatButton)
            {
                _chatButton = [self createChatButton];
            }
            [_chatButton rotateButton];
            [chatWindow addSubview:_chatButton];
            _chatButton.hidden=YES;
            
            // Setting ChatSDKJSBridgeDelegate to self
            [NSURLCache setChatSDKJSBridgeDelegate:self];
            [chatWebview setDelegate:self];
            
            NSURL *websiteUrl = [NSURL URLWithString:chatSDKResources.chatsdkURL];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
            [chatWebview loadRequest:urlRequest];
            //[chatWindow addSubview:chatWebview];
            
            // Starting the indicator view initially
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _indicatorView.center = chatWindow.center;
            [chatWindow addSubview:_indicatorView];
            [_indicatorView startAnimating];
        }
        else
        {
            // Calling maximizeChat()
            [self maximizeChat];
        }        
    }else{
        
        // Fetching Error Code
        ChatSDKErrorCode  errorCode = ChatSDKInvalidParameterError;
        sdkError.code = [self getErrorCode:errorCode];
        sdkError.message = [self getErrorMessage:errorCode];
        // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ONCHATERROR
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [chatSDKCallbacks onChatErrorDelegateHandler:sdkError];
        });
    }
}

/********************************************************************************
 ** Function Name       : maximizeChat
 ** Description         : This method is optional, used to bring back the chat into view
                          if chat has been minimized by user action or by the application
 ** Input Parameters    : None
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)maximizeChat
{
    //Setting cache to JSBridge cache
    [NSURLCache setSharedURLCache:nil];
    [NSURLCache setSharedURLCache:cache];
    
    [_chatButton hideWithAnimation];
    chatWebview.hidden = NO;    
    [chatWindow bringSubviewToFront:chatWebview];
    
    //TODO
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // And adding the animation on webview as per the animation style from plist.
        // Calling a local function which will remove the chatwebview with animation.
        //[self addChatWebviewWithAnimation:chatSDKResources.animationStyle and:TRUE];
        if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VER>=7)
        {
            //Default resizing
            [chatWebview resetWebViewForIpadWithFrame];
        }else{
            [chatWebview resetWebViewForIpad];
        }
    }
    else
    {
        //Added// ResetWebView
        if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VER>=7)
        {
            [chatWebview resetWebViewWithFrame];
        }else{
            [chatWebview resetWebView];
        }
    }
    [chatWebview showWithAnimation];
    dispatch_async(dispatch_get_main_queue(), ^(void) {        
        //Resetting badge count
        [_chatButton resetBadge];
        
        // Creating a blank NSDictionary.
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT MAXIMIZECHAT
        [chatSDKCallbacks onChatMaximizedDelegateHandler:tempDict];
    });

    //send minimize notification to JS Bridge
    [self updateApplicationStatus:@"maximize"];
}

/********************************************************************************
 ** Function Name       : minimizeChat
 ** Description         : This is an optional method that could be used by the 
                          application to minimize the chat view.
 ** Input Parameters    : None
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)minimizeChat
{
    //send minimize notification to JS Bridge
    [self updateApplicationStatus:@"minimize"];
    
    //Add chatbutton on screen and hide chatsdkwebview
    [chatWebview hideWithAnimation];
    _chatButton.hidden=NO;
    [_chatButton showWithAnimation];
    [_chatButton checkRotation];
    [chatWindow bringSubviewToFront:_chatButton];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Creating a blank NSDictionary.
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT MINIMIZECHAT
        [chatSDKCallbacks onChatMinimizedDelegateHandler:tempDict];
    });
       
    //Setting default cache
    [NSURLCache setSharedURLCache:nil];
    [NSURLCache setSharedURLCache:globalCache];
    
}

/********************************************************************************
 ** Function Name       : endChat
 ** Description         : This is an optional method that could be called to 
                          programmatically end chat session and close the chat view.
 ** Input Parameters    : None
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)endChat
{
    // Assigning flag to FALSE.
    _firstTimeFlag = FALSE;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // And adding the animation on webview as per the animation style from plist.
        // Calling a local function which will remove the chatwebview with animation.
        //[self removeChatWebviewWithAnimation:chatSDKResources.animationStyle and:FALSE];
    }
    else
    {

    }
    
    // Check whether the chatWebview is present or not
    if(chatWebview!=nil)
    {
        [chatWebview removeFromSuperview];
        chatWebview = nil;
    }
    // Remove maximizeButton from superView
    if(_chatButton!=nil)
    {
        [_chatButton removeFromSuperview];
        _chatButton = nil;
    }
    
    
    //stop location tracking on chat close.
    [_chatSDKLocation stopTracking];
    _chatSDKLocation=nil;
    
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Creating a blank NSDictionary.
        NSDictionary *tempDict = [[NSDictionary alloc] init];
        // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ENDCHAT
        [chatSDKCallbacks onChatEndedDelegateHandler:tempDict];
    });
    
    //Setting default cache
    [NSURLCache setSharedURLCache:nil];
    [NSURLCache setSharedURLCache:globalCache];
}

//Method for chatButtonClicked()
-(void)chatButtonClicked
{
    [self maximizeChat];
}


/********************************************************************************
 ** Function Name       : updateApplicationStatus
 ** Description         : This method will update ApplicationStatus to JS bridge.
 ** Input Parameters    : status
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)updateApplicationStatus :(NSString*)status
{
    NSDictionary *Dic=[NSDictionary dictionaryWithObjectsAndKeys:status,@"applicationStatus", nil];
    NSDictionary *sendingDic=[NSDictionary dictionaryWithObjectsAndKeys:Dic,@"result", nil];
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendingDic options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [chatWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",@"ApplicationStatus",jsonStr]];
}


/********************************************************************************
 ** Function Name       : updateLoaction
 ** Description         : This method will update location to JS bridge.
 ** Input Parameters    : location
 ** Output Parameters   : None
 ** Return Values       : void
 *******************************************************************************/
-(void)updateLoaction :(CLLocation*)newLocation
{
    
    NSString*location=[self getStringOfLocation:newLocation];
    
    NSLog(@"location > %@",location);
    
    [chatWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@);",@"ReceivedLocation",location]];
}


//get location string from CLLocation object
-(NSString*)getStringOfLocation:(CLLocation*)location
{
    NSString *latitudeString = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    NSString *longitudeString = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    NSDictionary *Dic=[NSDictionary dictionaryWithObjectsAndKeys:latitudeString,@"latitude",longitudeString,@"longitude", nil];
    NSDictionary *sendingDic=[NSDictionary dictionaryWithObjectsAndKeys:Dic,@"result", nil];
    NSError *jsonError;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendingDic options:0 error:&jsonError];
    
    if (jsonError != nil)
    {
        //call error callback function here
        NSLog(@"Error creating JSON from the response  : %@",[jsonError localizedDescription]);
        
    }
    
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //NSLog(@"jsonStr = %@", jsonStr);
    
    if (jsonStr == nil)
    {
        NSLog(@"location is null = %@", location);
    }
    
    
    return jsonStr;
}






#pragma mark ChatSDKJSBridge Delegate

- (NSDictionary *)executeNative:(ChatSDKBridgeAction *)nativeAction error:(NSError **)error {
   
    //-----------MINIMIZE CHAT------------//
    if ([nativeAction.action isEqualToString:@"minimizechat"])
    {       
        dispatch_async(dispatch_get_main_queue(), ^{
            // Calling minimizeChat()
            [self minimizeChat];
        });
        
        // Sending callback to Bridge.js
        NSDictionary *resultDict = [[NSDictionary alloc] init];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",resultDict,@"data", nil];
        return tempDict;
        
        
    }//-----------END CHAT------------//
    else if ([nativeAction.action isEqualToString:@"endchat"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Caling endChat()
            [self endChat];
        });
        return nil;
        
    }//-----------ONAGENTMESSAGE------------//
    else if ([nativeAction.action isEqualToString:@"onagentmessage"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Do Desired UI update
            NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:nativeAction.params];
            // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ONAGENTMESSAGE
            [chatSDKCallbacks onAgentMessageDelegateHandler:[tempDict objectForKey:@"data"]];

        });
       
        // Sending callback to Bridge.js
        NSDictionary *resultDict = [[NSDictionary alloc] init];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",resultDict,@"data", nil];
        return tempDict;
        
        
    }//-----------GETCONTEXT------------//
    else if ([nativeAction.action isEqualToString:@"getcontext"])
    {
        // Sending callback to Bridge.js with contextInfoDictionary
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",_contextInfoDict,@"data", nil];
        return tempDict;
        
        
    }
    //-----------getqueue------------//
    else if ([nativeAction.action isEqualToString:@"getqueueid"])
    {
        NSDictionary *queueIdDic=[[NSDictionary alloc] initWithObjectsAndKeys:_chatSDKqueueId,@"QueueId", nil];
        // Sending callback to Bridge.js with contextInfoDictionary
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",queueIdDic,@"data", nil];
        return tempDict;
        
        
    }
    
    //-----------CHATSTARTED------------//
    else if ([nativeAction.action isEqualToString:@"chatstarted"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ONCHATSTARTED
            [chatSDKCallbacks onChatStartedDelegateHandler:[nativeAction.params objectForKey:@"data"]];
            
        });
        
        // Sending callback to Bridge.js
        NSDictionary *resultDict = [[NSDictionary alloc] init];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",resultDict,@"data", nil];
        return tempDict;
        
    }//-----------LOG VALUE------------//
    else if ([nativeAction.action isEqualToString:@"logvalue"])
    {        
        NSLog(@"JS CONSOLE: %@",[nativeAction.params objectForKey:@"data"]);
        
        // Sending callback to Bridge.js
        NSDictionary *resultDict = [[NSDictionary alloc] init];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",resultDict,@"data", nil];
        return tempDict;
    }//-----------SHOW DIALOG------------//
    else if ([nativeAction.action isEqualToString:@"showdialog"])
    {
        NSDictionary* dialogParams= [nativeAction.params objectForKey:@"data"];
        
        UIAlertView* dialog = nil;
        if([[dialogParams objectForKey:@"type"] isEqualToString:@"confirm"])
        {
            dialog= [[UIAlertView alloc] initWithTitle:@"Confirm" message:[dialogParams objectForKey:@"message"] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        }else if([[dialogParams objectForKey:@"type"] isEqualToString:@"alert"]){
            dialog= [[UIAlertView alloc] initWithTitle:@"Alert" message:[dialogParams objectForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [dialog showDialogWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                NSLog(@"##### Dialog Button Clicked");
                int buttonClicked=0;
                if([alertView numberOfButtons]>1){
                    if(buttonIndex==0){
                        buttonClicked=0;
                        NSLog(@"Confirm Dialog: Cancel button pressed");
                    }else{
                        NSLog(@"Confirm Dialog: OK button pressed");
                        buttonClicked=1;
                    }
                }else{
                    NSLog(@"Alert Dialog: OK button pressed");
                    buttonClicked=1;
                }
                
                NSString* stringWithId=[[NSString alloc] initWithFormat:@"{ \"id\": \"%@\",\"result\": \"true\",\"action\": \"true\",\"data\": {\"result\": \"%i\"}}",[nativeAction.params objectForKey:@"id"],buttonClicked];
                
                [chatWebview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.NativeBridge._complete('%@')",stringWithId]];
            }];
        });
        
        NSDictionary *resultDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[NSNumber numberWithBool:true]] forKeys:[NSArray arrayWithObject:@"ignore"]];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:true],@"result",[NSNumber numberWithBool:true],@"action",nil,@"id",resultDict,@"data", nil];
        
        NSLog(@"## Response: %@",resultDict);
        return tempDict;
        
    }
    else if ([nativeAction.action isEqualToString:@"getlocation"])
    {
        
        // Sending callback to Bridge.js
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        NSNumber *status;
        if (_allowLocationAccess) {
            
            [resultDict setObject:[NSString stringWithFormat:@"%f",_chatSDKLocation.locationManager.location.coordinate.latitude] forKey:@"latitude"];
            [resultDict setObject:[NSString stringWithFormat:@"%f",_chatSDKLocation.locationManager.location.coordinate.longitude] forKey:@"longitude"];
            status=[NSNumber numberWithBool:true];
        }
        else{
            [resultDict setObject:@"Location access is disabled from application side." forKey:@"error"];
            status=[NSNumber numberWithBool:false];
        }
        
        status=[NSNumber numberWithBool:true];
        NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:status,@"result",[NSNumber numberWithBool:true],@"action",[nativeAction.params objectForKey:@"id"],@"id",resultDict,@"data", nil];
        return tempDict;
        
    }
    return nil;
}

#pragma mark WebView Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
   [_indicatorView startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    /*
     start location tracing after loading webView Completely.
     because we are sending it to JS Bridge via webView,
     so we have to send it after loading webView completely.
     */
    if (self.allowLocationAccess) {
        _chatSDKLocation  = [[ChatSDKLocation alloc] init];
        _chatSDKLocation.delegate=self;
        [_chatSDKLocation startTracking];
    }
    
    
    //Keyboard Up Event Fix on iOS7, compiled with iOS7
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VER>=7)
    {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            
            [chatWebview stringByEvaluatingJavaScriptFromString:@"document.addEventListener('touchstart',function(e){var tag = e.target.tagName; if(tag && ((tag.toLowerCase() === 'input' && e.target.type === 'text') || (tag.toLowerCase() === 'textarea'))){setTimeout(function(){e.target.focus();},0);}}); window.onorientationchange = function(){if((window.orientation == 90 || window.orientation == -90 || window.orientation == 0 || window.orientation == 180) && (document.activeElement && (document.activeElement.tagName.toLowerCase() === 'input' || document.activeElement.tagName.toLowerCase() === 'textarea'))){ var elem = document.activeElement;elem.blur();elem.focus();}}; var metaTag = document.getElementsByTagName(\"meta\"); metaTag[0].parentNode.removeChild(metaTag[0]);"];
        }
        else{
            
            [chatWebview stringByEvaluatingJavaScriptFromString:@"document.addEventListener('touchstart',function(e){var tag = e.target.tagName; if(tag && ((tag.toLowerCase() === 'input' && e.target.type === 'text') || (tag.toLowerCase() === 'textarea'))){setTimeout(function(){e.target.focus();},0);}}); window.onorientationchange = function(){if((window.orientation == 90 || window.orientation == -90) && (document.activeElement && (document.activeElement.tagName.toLowerCase() === 'input' || document.activeElement.tagName.toLowerCase() === 'textarea'))){ var elem = document.activeElement;elem.blur();elem.focus();}}; var metaTag = document.getElementsByTagName(\"meta\"); metaTag[0].parentNode.removeChild(metaTag[0]);"];
        }
    }
    
    //Viewport fix
    NSString* js =
    @"var meta = document.createElement('meta'); "
    @"meta.setAttribute( 'name', 'viewport' ); "
    @"meta.setAttribute( 'content', 'width = 320px, initial-scale = 1.0, user-scalable = yes' ); "
    @"document.getElementsByTagName('head')[0].appendChild(meta)";
    [chatWebview stringByEvaluatingJavaScriptFromString: js];
    
    if(_indicatorView!=nil)
    {
        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
        _indicatorView = nil;
    }
    
    // This is done as per requirement when the spinner finished loading then we have to load the chatwebview
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        // And adding the animation on webview as per the animation style from plist.
        // CAlling a local function which will add the chatwebview with animation.
        //[self addChatWebviewWithAnimation:chatSDKResources.animationStyle and:FALSE];
    }
    else
    {
//        [chatWindow addSubview:chatWebview];
    }
    [chatWebview showWithAnimation];
    [chatWindow addSubview:chatWebview];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if(_indicatorView!=nil)
    {
        [_indicatorView stopAnimating];
        [_indicatorView removeFromSuperview];
        _indicatorView = nil;
    }
    NSLog(@"indidfailloadwitherror");
    _firstTimeFlag = FALSE;
    orientation = [[UIDevice currentDevice] orientation];
    
    //TODO 
    //[chatWebview resetWebView];

    [chatWebview loadHTMLString:ERROR_PAGE_STRING baseURL:nil];
    [chatWindow addSubview:chatWebview];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([[[request URL] absoluteString] rangeOfString:@"chatsdk_closedialog"].location != NSNotFound)
    {
        // Calling Function to destroy ChatWebview.
        [self endChat];
        _firstTimeFlag = FALSE;
        // Creating a blank NSDictionary.
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSDictionary *tempDict = [[NSDictionary alloc] init];
            // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ENDCHAT
            [chatSDKCallbacks onChatEndedDelegateHandler:tempDict];
        });
        return NO;
    }
    else if([[[request URL] absoluteString] hasPrefix:[NSString stringWithFormat:@"http://%@",chatSDKResources.customUrlScheme]])
    {
        // Creating a blank NSDictionary.
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // CALLING DELEGATE FUNCTION WITH URL WHICH WILL NOTIFY APPLICATION ABOUT CUSTOM URL
            NSDictionary *tempDict = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObject:[[request URL] absoluteString]] forKeys:[NSArray arrayWithObject:@"url"]];
            [chatSDKCallbacks onNavigationRequestHandler:tempDict];
        });
        return NO;
    }
    else if([[[request URL] absoluteString] hasPrefix:[NSString stringWithFormat:@"http://chat_exec_agentmessage"]])
    {
        NSDictionary *params=nil;
        NSString *escapedQuery = [[[request URL] query] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        params = [NSJSONSerialization JSONObjectWithData:[escapedQuery dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Increment badge count if chat is minimized
            if(chatWebview.hidden)
            {
                [_chatButton incrementBadgeCount];
            }
            // Creating dictionary
            NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:params];
            // CALLING DELEGATE FUNCTION WHICH WILL NOTIFY APPLICATION ABOUT ONAGENTMESSAGE
            [chatSDKCallbacks onAgentMessageDelegateHandler:[tempDict objectForKey:@"data"]];
            
        });
        
        return NO;
    }
    else
    {
        if(_firstTimeFlag == TRUE)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[request URL] absoluteString] ]];
            return NO;
        }
        else
        {
            // Assigning flag to TRUE.
            _firstTimeFlag = TRUE;
            return YES;
        }
    }
    return YES;
}

// UICOLOR FROM HEXADECIMAL VALUE
-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

-(ChatSDKMaximizeButton *)createChatButton
{
    //Creating ChatSDKMaximizeButton
    ChatSDKMaximizeButton *chatBtn = [[ChatSDKMaximizeButton alloc] init];

    NSString *buttonBgColor = chatSDKResources.minimizedButtonBackgroundColor;
    NSString *buttonTextColor = chatSDKResources.minimizedButtonTextColor;
    UIColor *backgroundColor = [self colorFromHexString:buttonBgColor];
    [chatBtn setBackgroundColor:backgroundColor];
    UIColor *textColor = [self colorFromHexString:buttonTextColor];
    [chatBtn setTitleColor:textColor forState:UIControlStateNormal];
    [chatBtn addTarget:self action:@selector(chatButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    return chatBtn;
}

-(NSInteger)getErrorCode:(NSInteger )errorCode
{
    return errorCode;
}

-(NSString *)getErrorMessage:(NSInteger )errorCode
{
    switch (errorCode) {
        case 0:
            return @"An error occurred during chat launch";
            break;
            
        case 1:
            return @"An error occurred in animation";
            break;
            
        case 2:
            return @"Network error occurred in agent availability check";
            break;
            
        case 3:
            return @"An error occurred during ending chat session";
            break;
            
        case 4:
            return @"An unknown error occurred in the SDK. This will end the active chat session";
            break;
            
        case 5:
            return @"An error occurred as startChat has not been called prior to calling other methods on an active chat session";
            break;
            
        case 6:
            return @"An error occurred as the arguments inside configuration xml (Plist) are invalid";
            break;
            
        default:
            return @"";
    }

}


#pragma mark - Application Status(backGround or foreground)
-(void)registerNotificationForApplicationState
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundApp) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foregroundApp) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)backgroundApp
{
    [self updateApplicationStatus:@"background"];
}

-(void)foregroundApp
{
    [self updateApplicationStatus:@"foreground"];
    NSLog(@"foregroundApp");
    
    //start tracking again if app from background to foreground.
    if (self.allowLocationAccess) {
        //[_chatSDKLocation startTracking];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)dealloc {
    // This instance is going away, so unbind it from our custom NSURLCache
    [NSURLCache setChatSDKJSBridgeDelegate:nil];
}
@end
