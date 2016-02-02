//
//  ChatSDKCAServerDetailParsing.m
//  ChatSample
//
//  Created by Rajneesh071 on 05/04/14.
//  Copyright (c) 2014 Apple . All rights reserved.
//

#import "ChatSDKCAServerDetailParsing.h"

@implementation ChatSDKCAServerDetailParsing

-(id)initWithContentsOfURL:(NSURL *)url{
   self=[super initWithContentsOfURL:url];
    if (self) {
        self.delegate=self;
        _caXmlResponse=[NSMutableDictionary new];
        [self parse];
    }
    return self;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    foundStr=[NSMutableString new];
    if ([elementName isEqualToString:@"CheckAvailability"]) {
        isCheckAvailability=YES;
    }
    if (isCheckAvailability) {
        
        if ([elementName isEqualToString:@"queue"]) {
            foundedQueue=[NSMutableString new];
        }
        if ([elementName isEqualToString:@"url"]) {
            foundURL=[NSMutableString new];
        }
    }
}
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    [foundStr appendString:string];
}
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"CheckAvailability"]) {
        isCheckAvailability=NO;
    }
    if (isCheckAvailability) {
    if ([elementName isEqualToString:@"queue"]) {
        
        [foundedQueue appendString:foundStr];
        NSString *new=[[NSString alloc] initWithString:foundedQueue];
        [_caXmlResponse setObject:@"" forKey:new];
    }
    if ([elementName isEqualToString:@"url"]) {
        NSString *new=[[NSString alloc] initWithString:foundStr];
        [_caXmlResponse setObject:new forKey:foundedQueue];
    }
    }
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"parsing error > %@",parseError.description);
}

@end

