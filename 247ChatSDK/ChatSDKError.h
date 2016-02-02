//
//  ChatSDKError.h
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 20/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatSDKError : NSObject
{
    NSInteger code;
    NSString *message;
}

@property (nonatomic,assign) NSInteger code;
@property (nonatomic,strong) NSString *message;




@end
