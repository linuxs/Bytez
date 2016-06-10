//
//  BytezSessionHandler.m
//  Bytez
//
//  Created by HMSPL on 04/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "BytezSessionHandler.h"
#import "AppDelegate.h"
#import "StringConstants.h"

@implementation BytezSessionHandler

+(BytezSessionHandler*)Instance
{
    static BytezSessionHandler *sharedInstance=nil;
    static dispatch_once_t  oncePredecate;
    
    dispatch_once(&oncePredecate,^{
        sharedInstance=[[BytezSessionHandler alloc] init];
        
    });
    return sharedInstance;
}

#pragma mark Status

-(NSDate *)serverTime
{
    if (self.currentTime==nil) {
        return [NSDate date];
    }
    return [NSDate date];
}

-(void)setAppTourStatus:(BOOL)status
{
    if (status) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@"Yes" forKey:CONSTANT_APP_TOUR];
        [userDefaults synchronize];
    }
}

-(void)setTermsAndConditionsStatus:(BOOL)agree
{
    if (agree) {
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        [userDefaults setValue:@"Yes" forKey:CONSTANT_TERMS_AND_CONDITIONS];
        [userDefaults synchronize];
    }
}

-(BOOL)termsAndConditionsAccepted{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userId= [userDefaults stringForKey:CONSTANT_TERMS_AND_CONDITIONS];
    if (userId!=nil) {
        return YES;
    }
    return NO;
}

-(BOOL)appTourCompleted
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userId= [userDefaults stringForKey:CONSTANT_APP_TOUR];
    if (userId!=nil) {
        return YES;
    }
    return NO;
}

-(void) setBytezRadius :(NSString*)radius
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:radius forKey:CONSTANT_BYTEZ_RADIUS];
    [userDefaults synchronize];
    [BytezSessionHandler Instance].shouldReloadRecent=YES;
}
-(BOOL)reloadRecentAndPopular
{
    return [BytezSessionHandler Instance].shouldReloadRecent;
}
-(BOOL)reloadPopular
{
    return [BytezSessionHandler Instance].shouldReloadPopular;
}

-(void) setPushNotificationStatus :(BOOL) status
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if (status) {
        [userDefaults setObject:@"yes" forKey:CONSTANT_PUSHNOTIFICATION_STATUS];
    }else{
        [userDefaults setObject:@"no" forKey:CONSTANT_PUSHNOTIFICATION_STATUS];
    }
    [userDefaults synchronize];
}


-(NSString*) bytezRadius
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userId= [userDefaults stringForKey:CONSTANT_BYTEZ_RADIUS];
    if (userId==nil) {
        return @"3";
    }
    return userId;
}


-(BOOL) pushNotificationStatus
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userId= [userDefaults stringForKey:CONSTANT_PUSHNOTIFICATION_STATUS];
    if ([userId isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
        
    }
}

-(void)updateBadgeCountForMyCave:(NSUInteger)count
{
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdelegate updateMyCaveUnreadComment:count];
}


- (void)setFlashOnOffCamera:(NSString *)position {
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:position forKey:SET_FRONT_BACK_CAMERA_POSITION];
}


- (NSString *)getFlashOnOffCamera {
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *position= [userDefaults stringForKey:SET_FRONT_BACK_CAMERA_POSITION];
    
    return position;
}

@end
