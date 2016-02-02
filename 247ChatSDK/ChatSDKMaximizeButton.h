//
//  ChatSDKMaximizeButton.h
//  247ChatSDK
//
//  Created by Atul Khatri on 18/10/13.
//  Copyright (c) 2013 VVDN Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatSDKMaximizeButton : UIButton{
    NSMutableArray *positionsArray;
    int btnWidth;
    int btnHeight;
}

@property int portraitPos;
@property int landscapePos;

-(void)rotateButton;
-(void)checkRotation;
-(void)resetBadge;
-(void)incrementBadgeCount;
-(void)hideWithAnimation;
-(void)showWithAnimation;
@end
