//
//  SettingsModel.m
//  Bytez
//
//  Created by HMSPL on 04/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "SettingsModel.h"
#import "BytezSessionHandler.h"
#import "DataHandler.h"
#import "APIKeyConstants.h"
#import "AppDelegate.h"
#import "RegisterDeviceHandler.h"

@implementation SettingsModel

-(void)initView
{
    NSString *radiusString= [BytezSessionHandler Instance].bytezRadius;
    if ([radiusString isEqualToString:@"3"]) {
        [self.delegate updateSettingsScreenWith:1 pushNotification:YES];
    }else if([radiusString isEqualToString:@"5"])
    {
        [self.delegate updateSettingsScreenWith:2 pushNotification:YES];
    }
    else
    {
        [self.delegate updateSettingsScreenWith:0 pushNotification:YES];
    }
}

-(void) updatePushNotificationStatus :(BOOL) status
{
    NSDictionary *dictionary;
    if (status) {
        if ([BytezSessionHandler Instance].deviceToken==nil) {
            
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
            {
                // iOS 8 Notifications
                [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }
            else
            {
                // iOS < 8 Notifications
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
                 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
            }
            return;
        }
        dictionary=[NSDictionary dictionaryWithObjectsAndKeys:[BytezSessionHandler Instance].deviceToken,API_REQUEST_REGISTER_DEVICE_TOKEN,[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_USER_ID, nil];
    }else{
        dictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"",API_REQUEST_REGISTER_DEVICE_TOKEN,[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_USER_ID, nil];
    }
    [DataHandler registerPushNotification:dictionary successHandler:^(id obj) {
        NSLog(@"Register DeviceToken Responser: %@",obj);
    } failureHandler:^(NSError *error) {
        NSLog(@"Register DeviceToken failure: %@",error);
    }];
    [[BytezSessionHandler Instance] setPushNotificationStatus:status];
}

-(void)updateRecentImageDistance:(BOOL)status
{
    
}

-(void)saveImageRadius:(NSString *)radius
{
    [[BytezSessionHandler Instance] setBytezRadius:radius];
}
@end
