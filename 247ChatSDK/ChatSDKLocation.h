//
//  ChatSDKLocation.h
//  ChatSample
//
//  Created by MBP on 12/03/14.
//  Copyright (c) 2014 Apple . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ChatSDKLocationDelegate;

@interface ChatSDKLocation : NSObject<CLLocationManagerDelegate>
{
    id <ChatSDKLocationDelegate> delegate;
    
    
    CLLocationManager *locationManager;
    CLLocation *userlocation;
    
    BOOL locationServiceEnabled;
}

- (void)startTracking;
- (void)stopTracking;


@property(nonatomic,strong) id<ChatSDKLocationDelegate> delegate;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *userlocation;
@end

//Declaring protocol
@protocol ChatSDKLocationDelegate <NSObject>
-(void)updateLoaction:(CLLocation*)location;
@end
