//
//  JSBridge.m
//  247ChatSDK
//
//  Created by Sourabh Shekhar Singh on 17/09/13.
//  Copyright (c) 2013 . All rights reserved.
//

#import "ChatSDKJSBridge.h"
#import "ChatSDKBridgeAction.h"

@implementation ChatSDKJSBridge

@synthesize delegate = bridgeDelegate;

//Method to intercept url & extract query parameters
- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request
{
    NSLog(@"URL = %@",[request URL]);    
    NSURL *url = [request URL];
    
    //Finding if URL contains chat_exec & extracting query parameterss
    if ([[url absoluteString] rangeOfString:@"/!chat_exec/"].location != NSNotFound)
    {
        NSString *action = nil;
        if ([[url pathComponents] count] > 1)
        {
            //Getting method name using lastPathComponent
            action = [url lastPathComponent];
        }
        NSString *queryString = [url query];
        
        NSString *methodName = [request HTTPMethod];
    
        //Checking if method name is OPTIONS and changing it to GET
        if([methodName isEqualToString:@"OPTIONS"])
        {
            NSDictionary *headerFields= [request allHTTPHeaderFields];
            NSString *headerString=[headerFields objectForKey:@"Access-Control-Request-Method"];
            if ([headerString isEqualToString:@"GET"] )
            {
                methodName=@"GET";
            }
        }
        
        NSDictionary *parameters = nil;    
        //Converting encoded parameters JSON Object into NSDictionary
        @try {
            if ([methodName isEqualToString:@"GET"])
            {
                NSString *encodedQueryString = [queryString stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                parameters = [NSJSONSerialization JSONObjectWithData:[encodedQueryString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:NULL];
            } 
        }
        @catch (NSException *e) {
            NSLog(@"Execption in paramerts JSON to NSDictionary conversion %@",[e description]);
        }
        
        NSLog(@"REQUEST : ACTION=%@, PARAMS=%@",action,parameters);
        
        ChatSDKBridgeAction *bridgeAction = [[ChatSDKBridgeAction alloc] initWithAction:action andParams:parameters];
        NSError *bridgeError = nil;
        
        NSMutableDictionary *nativeResult = [[self.delegate executeNative:bridgeAction error:&bridgeError] mutableCopy];
        
        // Sending error message to JS
        if (bridgeError) {
            [nativeResult setObject:@{ @"code" : [NSNumber numberWithInt:bridgeError.code], @"message" : [bridgeError localizedDescription] } forKey:@"error"];
        }
        
        NSLog(@"RESPONSE : %@",nativeResult);
    
        // Creating response object
        NSCachedURLResponse *cachedURLResponse = nil;
        if (nativeResult) {
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:nativeResult options:NSJSONWritingPrettyPrinted error:&error];
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
      
            NSData *bodyData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*", @"Access-Control-Allow-Headers" : @"Origin, x-requested-with, content-type, accept" ,@"Access-Control-Request-Method":@"POST",@"MIMEType" : @"application/json", @"Cache-Control": @"max-age=315360000" , @"Expires": @"Fri, 01 May 2020 03:47:24 GMT" ,@"Last-Modified" : @"" , @"Etag" : @""};
            NSHTTPURLResponse *urlResponse = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
            cachedURLResponse = [[NSCachedURLResponse alloc] initWithResponse:urlResponse data:bodyData];
      
        }
        return cachedURLResponse;
    }
  
    // If URL does not contain chat_exec, system will handle it
    return [super cachedResponseForRequest:request];
}

@end



@implementation NSURLCache (ChatSDKJSBridge)

+ (id <ChatSDKJSBridgeDelegate>)ChatSDKJSBridgeDelegate {
  NSURLCache *sharedURLCache = [NSURLCache sharedURLCache];
  if ([sharedURLCache isKindOfClass:[ChatSDKJSBridge class]]) {
    return [(ChatSDKJSBridge *) sharedURLCache delegate];
  }
  return nil;
}

+ (void)setChatSDKJSBridgeDelegate:(id <ChatSDKJSBridgeDelegate>)delegate {
  NSURLCache *sharedURLCache = [NSURLCache sharedURLCache];
  if ([sharedURLCache isKindOfClass:[ChatSDKJSBridge class]]) {
    [(ChatSDKJSBridge *) sharedURLCache setDelegate:delegate];
  }
}

@end

