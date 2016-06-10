//
//  RegisterDeviceHandler.m
//  Bytez
//
//  Created by Jeyaraj on 12/23/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "RegisterDeviceHandler.h"
#import "APIHandler.h"
#import "StringConstants.h"
#import "DeviceDetailsModel.h"
#import "BytezSessionHandler.h"
#import "APIKeyConstants.h"
#import "DataHandler.h"

@implementation RegisterDeviceHandler

+(NSString *)getRegisteredUserId
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userId= [userDefaults stringForKey:CONSTANT_REGISTERED_DEVICE_KEY];
//    return @"78";
    return userId;
}

-(void)registerDeviceWithSuccessHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    NSString * userId= [RegisterDeviceHandler getRegisteredUserId];
    if (userId==nil || userId==NULL) {
        NSDictionary *dictionary=[NSDictionary dictionaryWithObjectsAndKeys:[DeviceDetailsModel deviceUDID],API_REQUEST_REGISTER_DEVICE_ID, nil];
        
        [APIHandler registerDevice:dictionary successHandler:^(id obj) {
            long status= [[[obj objectForKey:API_REGISTER_STATUS] objectForKey: API_REGISTER_STATUS]longValue];
            if (status==200||status==302) {
                NSDictionary * userDict=[obj objectForKey:API_REGISTER_USER];
                NSString * userId= [userDict objectForKey:API_REGISTER_USER_ID];
                [self saveuserId:userId];
                if ([BytezSessionHandler Instance].deviceToken!=nil) {
                    
                }
                NSDictionary *dictionary=[NSDictionary dictionaryWithObjectsAndKeys:[BytezSessionHandler Instance].deviceToken,API_REQUEST_REGISTER_DEVICE_TOKEN,userId,API_REQUEST_USER_ID, nil];
                [DataHandler registerPushNotification:dictionary successHandler:^(id obj) {
                    NSLog(@"Register DeviceToken Responser: %@",obj);
                } failureHandler:^(NSError *error) {
                    NSLog(@"Register DeviceToken failure: %@",error);
                }];
                successHandler(userId);
            }else
            {
                failureHanlder([NSError errorWithDomain:@"" code:status userInfo:nil]);
            }
        } failureHandler:^(NSError * error) {
            failureHanlder(error);
        }];
    }
    else
    {
        successHandler(userId);
    }
}

//-(NSString *)getUniqueDeviceIdentifierAsString
//{
//
//    NSString *appName=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
//
//    NSString *strApplicationUUID = [SSKeychain passwordForService:appName account:@"incoding"];
//    if (strApplicationUUID == nil)
//    {
//        strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//        [SSKeychain setPassword:strApplicationUUID forService:appName account:@"incoding"];
//    }
//
//    return strApplicationUUID;
//}

-(void)saveuserId:(NSString *) userId
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setValue:userId forKey:CONSTANT_REGISTERED_DEVICE_KEY];
    [userDefaults synchronize];
}
@end
