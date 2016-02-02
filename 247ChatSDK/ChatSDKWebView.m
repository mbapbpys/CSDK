//
//  ChatSDKWebView.m
//  247ChatSDK
//
//  Created by Atul Khatri on 04/10/13.
//  Copyright (c) 2013 VVDN Tech. All rights reserved.
//

#import "ChatSDKWebView.h"
#import "ChatSDK.h"
#import "ChatSDKResources.h"
#import <QuartzCore/QuartzCore.h>


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
// App compiled with iOS7 or later
int COMPILED_WITH_VERSION =7;
#else
// App compiled with iOS6
int COMPILED_WITH_VERSION =6;
#endif

@implementation ChatSDKWebView

bool keyboardIsUp=false;
bool orientationPortrait=true;
bool initialized=false;
CGRect keyboardFrame;
CGRect webViewInitialFramePortrait;
CGRect webViewInitialFrameLandscape;
float deviceHeight;
float deviceWidth;
float webViewWidthForIpadPortrait;
float webViewHeightForIpadPortrait;
float webViewWidthForIpadLandscape;
float webViewHeightForIpadLandscape;

float paddingTopPortrait;
float paddingRightPortrait;
float paddingBottomPortrait;
float paddingLeftPortrait;

float paddingTopLandscape;
float paddingRightLandscape;
float paddingBottomLandscape;
float paddingLeftLandscape;

ChatSDKResources* resources=nil;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    keyboardFrame= CGRectMake(0, 0, 0, 0);
    webViewInitialFramePortrait= CGRectMake(0, 0, 0, 0);
    webViewInitialFrameLandscape= CGRectMake(0, 0, 0, 0);
    
    //Registering notifications for keyboard & orientation-change
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    [notifCenter addObserver:self
                    selector:@selector(keyboardWillShowOrHide:)
                        name:UIKeyboardDidShowNotification
                      object:nil];
    [notifCenter addObserver:self
                    selector:@selector(keyboardWillShowOrHide:)
                        name:UIKeyboardWillHideNotification
                      object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged)  name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    resources= [ChatSDKResources getSDKResourcesInstance];
    [resources initializeValues];
    
    [self checkBoundForSuperView];
    
    return self;
}

-(void)checkBoundForSuperView
{
    //Determine height of device
    CGSize result = [[UIScreen mainScreen] bounds].size;
    
    deviceHeight= result.height;
    deviceWidth= result.width;
    
    /*
     //if client need in % basis
     paddingTopPortrait=floorf(([resources.paddingTopPortrait floatValue] / 100) * deviceHeight);
     paddingRightPortrait=floorf(([resources.paddingRightPortrait floatValue] / 100) * deviceWidth);
     paddingBottomPortrait=floorf(([resources.paddingBottonPortrait floatValue] / 100) * deviceHeight);
     paddingLeftPortrait=floorf(([resources.paddingLeftPortrait floatValue] / 100) * deviceWidth);
     
     
     paddingTopLandscape=floorf(([resources.paddingTopLandscape floatValue] / 100) * deviceWidth);
     paddingRightLandscape=floorf(([resources.paddingRightLandscape floatValue] / 100) * deviceHeight);
     paddingBottomLandscape=floorf(([resources.paddingBottonLandscape floatValue] / 100) * deviceWidth);
     paddingLeftLandscape=floorf(([resources.paddingLeftLandscape floatValue] / 100) * deviceHeight);
     */
    
    
    
    paddingTopPortrait=[resources.paddingTopPortrait floatValue];
    paddingRightPortrait=[resources.paddingRightPortrait floatValue];
    paddingBottomPortrait=[resources.paddingBottonPortrait floatValue];
    paddingLeftPortrait=[resources.paddingLeftPortrait floatValue];
    
    paddingTopLandscape=[resources.paddingTopLandscape floatValue];
    paddingRightLandscape=[resources.paddingRightLandscape floatValue];
    paddingBottomLandscape=[resources.paddingBottonLandscape floatValue];
    paddingLeftLandscape=[resources.paddingLeftLandscape floatValue];
    
    webViewWidthForIpadPortrait= floorf(([resources.widthPortrait floatValue] / 100) * deviceWidth);
    webViewHeightForIpadPortrait= floorf(([resources.heightPortrait floatValue] /100) * deviceHeight);
    
    //reading height in width and width in height
    
    webViewWidthForIpadLandscape= floorf(([resources.widthLandscape floatValue] / 100) * deviceWidth);
    webViewHeightForIpadLandscape= floorf(([resources.heightLandscape floatValue] /100) * deviceHeight);
    
    NSLog(@"called");
    
    //    //If keyboard overlaps then resize the webview height
    //    //Assuming iPad's keyboard height is 308 in Portrait mode & 396 in Landscape mode
    //    float keyboardHeightPortrait=308.0f;
    //    float keyboardHeightLandscape=396.0f;
    //
    //    if((webViewHeightForIpadPortrait+paddingTopPortrait) > (deviceHeight-keyboardHeightPortrait))
    //    {
    //        float diff= (webViewHeightForIpadPortrait+paddingTopPortrait) - (deviceHeight-keyboardHeightPortrait);
    //        webViewHeightForIpadPortrait-=diff;
    //    }
    //    if((webViewHeightForIpadLandscape+paddingTopLandscape) > (deviceWidth-keyboardHeightLandscape))
    //    {
    //        float diff= (webViewHeightForIpadLandscape+paddingTopLandscape) - (deviceWidth-keyboardHeightLandscape);
    //        webViewHeightForIpadLandscape-=diff;
    //    }
    
    NSLog(@"#### Device Height: %f    , Device Width: %f",deviceHeight, deviceWidth);
    NSLog(@"#### WebView Height Portrait: %f    , WebView Width Portrait: %f",webViewHeightForIpadPortrait, webViewWidthForIpadPortrait);
    NSLog(@"#### WebView Height Landscape: %f    , WebView Width Landscape: %f",webViewHeightForIpadLandscape, webViewWidthForIpadLandscape);
    
    //Keyboard Up Event Fix on iOS7, compiled with iOS7
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VERSION>=7)
    {
        self.keyboardDisplayRequiresUserAction = NO;
    }

}


- (void)keyboardWillShowOrHide:(NSNotification*)notif
{
    
    keyboardFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self convertRect:keyboardFrame fromView:nil];
    
    if ([notif.name isEqualToString:UIKeyboardDidShowNotification]) {
        keyboardIsUp=true;
    }else{
        keyboardIsUp=false;
    }
    
    if(![self isHidden])
    {
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            //Code for iPhone
            if(!([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VERSION>=7))
            {
                [self resetWebView];
            }
        }
        else{
            //Code for iPad
//            if(!([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VERSION>=7))
//            {
//                [self resetWebViewForIpad];
//            }
        }
    }
}

-(void)orientationChanged
{
    [self checkBoundForSuperView];
    
    NSLog(@"called orientation for webview");
    if(![self isHidden])
    {
        NSLog(@"2- called orientation for webview");

        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            //Code for iPhone
            if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VERSION>=7)
            {
                [self resetWebViewWithFrame];
            }else{
                //[self endEditing:YES];
                [self resetWebView];
            }
        }
        else{
            //Code for iPad
//            if([[[UIDevice currentDevice] systemVersion] floatValue] >=7.0f && COMPILED_WITH_VERSION>=7)
//            {
//                //Default resizing
//                [self resetWebViewForIpadWithFrame];
//            }else{
                [self resetWebViewForIpad];
//            }
        }
    }
    
}

-(void)resetWebView
{
    NSLog(@"#### RESET WEBVIEW");
    CGRect webViewBounds;
    webViewBounds.origin= CGPointMake(0, 0);
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    webViewBounds.size.height= deviceHeight;
    webViewBounds.size.width= 320.0f;
    self.scrollView.scrollEnabled=YES;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation==
        UIInterfaceOrientationPortraitUpsideDown){
        webViewBounds.origin= CGPointMake(0, 20);
        webViewBounds.size.height= deviceHeight -20;
        if(keyboardIsUp){
            webViewBounds.size.height -= keyboardFrame.size.height;
        }else{
        }
        self.transform = CGAffineTransformIdentity;
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft){
        webViewBounds.origin= CGPointMake(20, 0);
        webViewBounds.size.width= 300.0f;
        if(keyboardIsUp){
            webViewBounds.size.width-=keyboardFrame.size.height;
        }else{
        }
        self.transform = CGAffineTransformMakeRotation(3*M_PI/2);
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight){
        webViewBounds.origin= CGPointMake(0, 0);
        webViewBounds.size.width= 300.0f;
        if(keyboardIsUp){
            webViewBounds.size.width -=keyboardFrame.size.height;
            webViewBounds.origin= CGPointMake(keyboardFrame.size.height, 0);
        }else{
            
        }
        self.transform = CGAffineTransformMakeRotation(M_PI/2);
        
    }
    self.frame = webViewBounds;
}


-(void)resetWebViewWithFrame
{
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation==
        UIInterfaceOrientationPortraitUpsideDown){
        self.frame = CGRectMake(0,20,320,deviceHeight-20);
        [self setBounds:CGRectMake(0, 0 ,320,deviceHeight-20)];
        self.transform = CGAffineTransformIdentity;
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft){
        self.frame = CGRectMake(20, 0,300,deviceHeight);
        [self setBounds:CGRectMake(0, 0 ,deviceHeight,300)];
        self.transform = CGAffineTransformMakeRotation(3*M_PI/2);
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight){
        self.frame = CGRectMake(0,0,300,deviceHeight);
        [self setBounds:CGRectMake(0, 0 ,deviceHeight,300)];
        self.transform = CGAffineTransformMakeRotation(M_PI/2);
    }
}

-(void)showWithAnimation
{
    CGRect currentFrame= self.frame;
    CGRect frameAfterAnimation= self.frame;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(currentOrientation == UIInterfaceOrientationPortrait)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            currentFrame.origin.y-=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            currentFrame.origin.y+=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            currentFrame.origin.x-=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            currentFrame.origin.x+=deviceHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            currentFrame.origin.y+=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            currentFrame.origin.y-=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            currentFrame.origin.x+=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            currentFrame.origin.x-=deviceHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            currentFrame.origin.x-=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            currentFrame.origin.x+=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            currentFrame.origin.y+=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            currentFrame.origin.y-=deviceWidth;
        }
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            currentFrame.origin.x+=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            currentFrame.origin.x-=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            currentFrame.origin.y-=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            currentFrame.origin.y+=deviceWidth;
        }
    }
    
    self.frame=currentFrame;
    self.hidden=NO;
    [UIView animateWithDuration:0.5 animations:^{
        //Assigning new frame
        self.frame= frameAfterAnimation;
    }];
}


-(void)hideWithAnimation
{
    CGRect frameAfterAnimation= self.frame;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(currentOrientation == UIInterfaceOrientationPortrait)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            frameAfterAnimation.origin.y-=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            frameAfterAnimation.origin.y+=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            frameAfterAnimation.origin.x-=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            frameAfterAnimation.origin.x+=deviceHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            frameAfterAnimation.origin.y+=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            frameAfterAnimation.origin.y-=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            frameAfterAnimation.origin.x+=deviceHeight;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            frameAfterAnimation.origin.x-=deviceHeight;
        }
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            frameAfterAnimation.origin.x-=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            frameAfterAnimation.origin.x+=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            frameAfterAnimation.origin.y+=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            frameAfterAnimation.origin.y-=deviceWidth;
        }
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight)
    {
        //Manipulating current frame
        if([resources.animationStyle isEqualToString:@"top-bottom"])
        {
            frameAfterAnimation.origin.x+=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"bottom-top"])
        {
            frameAfterAnimation.origin.x-=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"left-right"])
        {
            frameAfterAnimation.origin.y-=deviceWidth;
        }else if([resources.animationStyle isEqualToString:@"right-left"])
        {
            frameAfterAnimation.origin.y+=deviceWidth;
        }
    }
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         //Assigning new frame
                         self.frame= frameAfterAnimation;
                     }
                     completion:^(BOOL finished){
                         self.hidden=YES;
                     }];
}


-(void)resetWebViewForIpad
{
    CGPoint margin= [self getMargins];
    
    NSLog(@"resetWebViewForIpad  %f  %f  %f  %f",margin.x,margin.y,webViewWidthForIpadLandscape,webViewHeightForIpadLandscape);

    float boundWidth= floorf(([resources.widthLandscape floatValue] / 100) * deviceHeight);
    float boundHeight= floorf(([resources.heightLandscape floatValue] /100) * deviceWidth);

    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation==
        UIInterfaceOrientationPortraitUpsideDown){
        
        self.frame = CGRectMake(margin.x,margin.y,webViewWidthForIpadPortrait,webViewHeightForIpadPortrait-margin.y);
        [self setBounds:CGRectMake(0, 0 ,webViewWidthForIpadPortrait,webViewHeightForIpadPortrait-margin.y)];
        self.transform = CGAffineTransformIdentity;
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft){
        self.transform = CGAffineTransformMakeRotation(3*M_PI/2);

        
        self.frame = CGRectMake(margin.x,margin.y ,webViewHeightForIpadLandscape,webViewWidthForIpadLandscape);
        [self setBounds:CGRectMake(0, 0 ,boundWidth,boundHeight)];
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight){
        self.transform = CGAffineTransformMakeRotation(M_PI/2);

        self.frame = CGRectMake(margin.x,margin.y,webViewHeightForIpadLandscape,webViewWidthForIpadLandscape);
        [self setBounds:CGRectMake(0, 0 ,boundWidth,boundHeight)];
    }
    
}


-(void)resetWebViewForIpadWithFrame
{
    CGPoint margin= [self getMargins];
    float boundWidth= floorf(([resources.widthLandscape floatValue] / 100) * deviceHeight);
    float boundHeight= floorf(([resources.heightLandscape floatValue] /100) * deviceWidth);

    NSLog(@"resetWebViewForIpadWithFrame2  %f  %f",webViewWidthForIpadLandscape,webViewHeightForIpadLandscape);
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation==
        UIInterfaceOrientationPortraitUpsideDown){
        self.frame = CGRectMake(margin.x,margin.y,webViewWidthForIpadPortrait,webViewHeightForIpadPortrait-margin.y);
        [self setBounds:CGRectMake(0, 0 ,webViewWidthForIpadPortrait,webViewHeightForIpadPortrait-margin.y)];
        self.transform = CGAffineTransformIdentity;
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft){
        self.transform = CGAffineTransformMakeRotation(3*M_PI/2);

        self.frame = CGRectMake(margin.x,margin.y,webViewHeightForIpadLandscape,webViewWidthForIpadLandscape );
        [self setBounds:CGRectMake(0, 0 ,boundWidth,boundHeight)];
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight){
        self.transform = CGAffineTransformMakeRotation(M_PI/2);

        self.frame = CGRectMake(margin.x,margin.y,webViewHeightForIpadLandscape,webViewWidthForIpadLandscape);
        [self setBounds:CGRectMake(0, 0 ,boundWidth,boundHeight)];
    }
    

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

//To override alertbox, changes title of alertbox depending on number of buttons
//-(void)willPresentAlertView:(UIAlertView *)alertView{
//    NSLog(@"Manipulating UIAlertView");
//    if([alertView numberOfButtons]>1){
//        [alertView setTitle:@"Confirm"];
//    }else{
//        [alertView setTitle:@"Alert"];
//    }
//}



-(CGPoint)getMargins{
    
    float screenWidth=deviceWidth;
    float screenHeight=deviceHeight;
    
    NSLog(@"$$$$ deviceHeight: %f , deviceWidth: %f , webViewHeight: %f , webViewWidth: %f , webViewLandHeight: %f , webViewLandWidth: %f",deviceHeight, deviceWidth, webViewHeightForIpadPortrait, webViewWidthForIpadPortrait, webViewHeightForIpadLandscape, webViewWidthForIpadLandscape);
    
    float statusBarHeight=20;
    
    NSString* verticleAlign= [[NSString alloc]initWithFormat:@"%@",resources.valignPortrait]; //top, middle, bottom
    NSString* horizontalAlign= [[NSString alloc]initWithFormat:@"%@", resources.halignPortrait]; //center, left, right
    
    float marginLeft=0;
    float marginTop=0;
    
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (currentOrientation == UIInterfaceOrientationPortrait || currentOrientation== UIInterfaceOrientationPortraitUpsideDown){
        
        if([verticleAlign isEqualToString:@"top"])
        {
            marginTop=0;
            
            //Padding Adjustment
            marginTop+=paddingTopPortrait;
        }
        else if([verticleAlign isEqualToString:@"middle"])
        {
            marginTop=(screenHeight-webViewHeightForIpadPortrait)/2;
        }
        else if([verticleAlign isEqualToString:@"bottom"])
        {
            marginTop=(screenHeight-webViewHeightForIpadPortrait);
        }
        
        if([horizontalAlign isEqualToString:@"left"])
        {
            marginLeft=0;
            
            //Padding Adjustment
            marginLeft+=paddingLeftPortrait;
        }
        else if([horizontalAlign isEqualToString:@"center"])
        {
            marginLeft=(screenWidth-webViewWidthForIpadPortrait)/2;
            
            //Padding Adjustment
            marginLeft+=paddingLeftPortrait;
        }
        else if([horizontalAlign isEqualToString:@"right"])
        {
            marginLeft=(screenWidth-webViewWidthForIpadPortrait);
            
            //Padding Adjustment
            marginLeft-=paddingRightPortrait;
        }
        
        //Status bar adjustment
        marginTop+=statusBarHeight;
        
        NSLog(@"$$$$ Portrait Orientation-> MarginLeft: %f, MarginTop: %f ",marginLeft, marginTop);
        
        return CGPointMake(marginLeft, marginTop);
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeLeft){
        
        if([verticleAlign isEqualToString:@"top"])
        {
            marginTop=0;
            
            //Padding Adjustment
            marginTop+=paddingTopLandscape;
        }
        else if([verticleAlign isEqualToString:@"middle"])
        {
            marginTop=(screenWidth-webViewHeightForIpadLandscape)/2;
        }
        else if([verticleAlign isEqualToString:@"bottom"])
        {
            marginTop=(screenWidth-webViewHeightForIpadLandscape);
        }
        
        if([horizontalAlign isEqualToString:@"left"])
        {
            marginLeft=deviceHeight-webViewWidthForIpadLandscape;
            
            //Padding Adjustment
            marginLeft-=paddingLeftLandscape;
            
            //Clipping Fix
            float diff= webViewHeightForIpadLandscape- webViewWidthForIpadLandscape;
            if(!diff==0){ marginLeft-= diff/2; marginTop-=diff/2;}
            
        }
        else if([horizontalAlign isEqualToString:@"center"])
        {
            marginLeft=(screenHeight-webViewWidthForIpadLandscape)/2;
            
            //Padding Adjustment
            marginLeft-=paddingLeftLandscape;
        }
        else if([horizontalAlign isEqualToString:@"right"])
        {
            marginLeft=0;
            
            //Padding Adjustment
            marginLeft+=paddingRightLandscape;
            
            //Clipping Fix
            float diff= webViewHeightForIpadLandscape- webViewWidthForIpadLandscape;
            if(!diff==0){ marginLeft+= diff/2; marginTop-=diff/2;}
        }
        
        //Status bar adjustment
        marginTop+=statusBarHeight;
        NSLog(@"$$$$ Landscape Left Orientation-> MarginLeft: %f, MarginTop: %f ",marginLeft, marginTop);
        
        return CGPointMake(marginTop, marginLeft);
        
    }else if(currentOrientation == UIInterfaceOrientationLandscapeRight){
        if([verticleAlign isEqualToString:@"top"])
        {
            marginTop=deviceWidth-webViewHeightForIpadLandscape;
            
            //Padding Adjustment
            marginTop-=paddingTopLandscape;
        }
        else if([verticleAlign isEqualToString:@"middle"])
        {
            marginTop=(screenWidth-webViewHeightForIpadLandscape)/2;
        }
        else if([verticleAlign isEqualToString:@"bottom"])
        {
            marginTop=(screenWidth-webViewHeightForIpadLandscape);
        }
        
        if([horizontalAlign isEqualToString:@"left"])
        {
            marginLeft=0;
            
            //Padding Adjustment
            marginLeft+=paddingLeftLandscape;
            
            //Clipping Fix
            float diff= webViewHeightForIpadLandscape- webViewWidthForIpadLandscape;
            if(!diff==0){ marginLeft+= diff/2; marginTop+=diff/2;}
        }
        else if([horizontalAlign isEqualToString:@"center"])
        {
            marginLeft=(screenHeight-webViewWidthForIpadLandscape)/2;
            
            //Padding Adjustment
            marginLeft+=paddingLeftLandscape;
        }
        else if([horizontalAlign isEqualToString:@"right"])
        {
            marginLeft=screenHeight-webViewWidthForIpadLandscape;
            
            //Padding Adjustment
            marginLeft-=paddingRightLandscape;
            
            //Clipping Fix
            float diff= webViewHeightForIpadLandscape- webViewWidthForIpadLandscape;
            if(!diff==0){ marginLeft-= diff/2; marginTop+=diff/2;}
        }
        
        //Status bar adjustment
        marginTop-=statusBarHeight;
        NSLog(@"$$$$ Landscape Right Orientation-> MarginLeft: %f, MarginTop: %f ",marginLeft, marginTop);
        
        return CGPointMake(marginTop, marginLeft);
    }
    
    return CGPointMake(0, 0);
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
