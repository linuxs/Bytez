//
//  LocationUpdateHandler.h
//  Bytez
//
//  Created by Jeyaraj on 12/24/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

@interface LocationUpdateHandler : UIViewController<CLLocationManagerDelegate>

@property (strong,nonatomic) CLLocationManager *locationManger;

-(void) startUpdatingLocation;

-(BOOL)refreshRecentSearch;
-(void)imagePosted:(BOOL)posted;

-(void) addLocationupdateObserver:(id)observerObject;
-(void) removeLocationUpdateObeserver:(id) observerObject;

-(void)showProgress;
-(void)hideProgress;

-(void)showTabbar;
-(void)hideTabbar;

@end
