//
//  ChatSDKCAServerDetailParsing.h
//  ChatSample
//
//  Created by Rajneesh071 on 05/04/14.
//  Copyright (c) 2014 Apple . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatSDKCAServerDetailParsing : NSXMLParser<NSXMLParserDelegate>
{
    NSMutableString *foundedQueue;
    NSMutableString *foundURL;
    NSMutableString *foundStr;
    BOOL isCheckAvailability;
}
@property(nonatomic,strong)NSMutableDictionary *caXmlResponse;
@end
