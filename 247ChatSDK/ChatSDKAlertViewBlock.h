//
//  ChatSDKMaximizeButton.m
//  247ChatSDK
//
//  Created by Atul Khatri on 30/10/13.
//  Copyright (c) 2013 VVDN Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^UIActionAlertViewCallBackHandler)(UIAlertView *alertView, NSInteger buttonIndex);

@interface UIAlertView (AddBlockCallBacks) <UIAlertViewDelegate>

- (void)showDialogWithHandler:(UIActionAlertViewCallBackHandler)handler;

@end
