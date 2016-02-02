//
//  ChatSDKWebView.h
//  247ChatSDK
//
//  Created by Atul Khatri on 04/10/13.
//  Copyright (c) 2013 VVDN Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatSDKWebView : UIWebView
-(void)resetWebView;
-(void)resetWebViewWithFrame;
-(void)resetWebViewForIpad;
-(void)resetWebViewForIpadWithFrame;
-(void)showWithAnimation;
-(void)hideWithAnimation;
@end
