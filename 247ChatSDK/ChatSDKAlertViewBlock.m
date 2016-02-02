//
//  ChatSDKMaximizeButton.m
//  247ChatSDK
//
//  Created by Atul Khatri on 30/10/13.
//  Copyright (c) 2013 VVDN Tech. All rights reserved.
//

#import "ChatSDKAlertViewBlock.h"
#import <objc/runtime.h>

@implementation UIAlertView (AddBlockCallBacks)

static NSString *dialogDelegate = @"dialogDelegate";

- (void)showDialogWithHandler:(UIActionAlertViewCallBackHandler)handler {
    
    objc_setAssociatedObject(self, (__bridge  const void *)(dialogDelegate), handler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setDelegate:self];
    [self show];  //call UIAlertView show method
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIActionAlertViewCallBackHandler completionHandler = objc_getAssociatedObject(self, (__bridge  const void *)(dialogDelegate));
    
    if (completionHandler != nil) {
        
        completionHandler(alertView, buttonIndex);
    }
}

@end
