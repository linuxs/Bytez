//
//  LocationUpdateHandler.m
//  Bytez
//
//  Created by Jeyaraj on 12/24/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "LocationUpdateHandler.h"
#import "AppDelegate.h"
//#import <SystemConfiguration/SystemConfiguration.h>
//#import "Reachability.h"

@implementation LocationUpdateHandler
{
    
}
-(BOOL)refreshRecentSearch
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.isImagePosted;
}

-(void)imagePosted:(BOOL)posted
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isImagePosted=posted;
}
-(void)startUpdatingLocation
{
    self.locationManger = [[CLLocationManager alloc] init];
    self.locationManger.delegate=self;
    self.locationManger.desiredAccuracy=kCLLocationAccuracyBest; //kCLLocationAccuracyThreeKilometers
    self.locationManger.distanceFilter=kCLDistanceFilterNone; //kCLLocationAccuracyThreeKilometers
    if ([self.locationManger respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManger requestWhenInUseAuthorization];
    }
    [self.locationManger startUpdatingLocation];
}

-(void)addLocationupdateObserver:(id)observerObject
{
    
}

-(void)removeLocationUpdateObeserver:(id)observerObject
{
    
}

-(void)showProgress
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showProgress];
}

-(void)hideProgress
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeProgress];
}

-(void)showTabbar
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController setTabBarHidden:NO animated:YES];
//    appDelegate.viewController.tabBarController.tabBarItem.badgeValue=@"10";
}

-(void)hideTabbar
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController setTabBarHidden:YES animated:YES];
}

@end
