//
//  ChatSDKLocation.m
//  ChatSample
//
//  Created by MBP on 12/03/14.
//  Copyright (c) 2014 Apple . All rights reserved.
//

#import "ChatSDKLocation.h"

@implementation ChatSDKLocation
@synthesize locationManager;
@synthesize userlocation;
@synthesize delegate;

-(id)init
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //Only applies when in foreground otherwise it is very significant changes
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    //check location service status of device.
    locationServiceEnabled=[CLLocationManager locationServicesEnabled];
    return self;
}


- (void)startTracking {
//    locationServiceEnabled=[CLLocationManager locationServicesEnabled];
//    if (!locationServiceEnabled) {
//        [self showEnableLocation];
//    }
    [locationManager startUpdatingLocation];
}

- (void)stopTracking {
    [locationManager stopUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    float distance=[userlocation distanceFromLocation:[locations lastObject]];
    
    if (distance>5 || !userlocation)
    {
        userlocation=(CLLocation*)[locations lastObject];
        NSLog(@"distance = %f",distance);
        [self.delegate updateLoaction:userlocation];
    }
    userlocation=(CLLocation*)[locations lastObject];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    userlocation=(CLLocation*)newLocation;
    
    float distance=[oldLocation distanceFromLocation:newLocation];
    
    
    if (distance>5 || !userlocation)
    {
        //Update location only if location distance is 5meter or more.
        [self.delegate updateLoaction:userlocation];
    }
    //NSLog(@"Entered new Location with the coordinates Latitude: %f Longitude: %f", currentCoordinates.latitude, currentCoordinates.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    NSString *errorString;
    
    //NSLog(@"Error: %@",[error localizedDescription]);
    switch([error code]) {
        case kCLErrorDenied:
            [manager stopUpdatingLocation];
            //Access denied by user
            errorString = @"Access to Location Services denied by user";
            //Do something...
            break;
        case kCLErrorLocationUnknown:
            //Probably temporary...
            errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            errorString = @"An unknown error has occurred";
            break;
    }
    
    NSLog(@"Error = %@",errorString);
    //if error while getting location then make its nil so that
    userlocation=nil;
    

}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Status = %d",status);
    
    switch(status) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager startUpdatingLocation];
            //Access denied by user
            //errorString = @"Access to Location Services denied by user";
            //Do something...
            break;
        case kCLAuthorizationStatusRestricted:
            //Probably temporary...
            //errorString = @"Location data unavailable";
            //Do something else...
            break;
            
        case kCLAuthorizationStatusDenied:
            //[self showEnableLocation];
            
            //Probably temporary...
            //errorString = @"Location data unavailable";
            //Do something else...
            break;
        case kCLAuthorizationStatusAuthorized:
            [locationManager startUpdatingLocation];
            //Probably temporary...
            //errorString = @"Location data unavailable";
            //Do something else...
            break;
        default:
            
            break;
    }
}


-(void)showEnableLocation
{
    //if error while getting location then make its nil so that chatSDK will not use last location.
    userlocation=nil;
    
    locationServiceEnabled=[CLLocationManager locationServicesEnabled];
    NSInteger value=0;
    if (!locationServiceEnabled) {
        NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
        value = [def integerForKey:@"locationPrompt"];
        if (value>=2) {
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Unable to get your location data." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
            //if error while getting location then make its nil so that chatSDK will not use last location.
            userlocation=nil;
        }
        if (value<2) {
            value=value+1;
            [def setInteger:value forKey:@"locationPrompt"];
            [def synchronize];
        }
        
        return;
        
    }
    
    
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:@"Unable to get your location data." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}





@end
