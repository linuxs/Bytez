//
//  DeviceDetailsModel.m
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "DeviceDetailsModel.h"

@implementation DeviceDetailsModel

+(id)deviceUDID
{
    UIDevice *device=[UIDevice currentDevice];
    NSString  *currentDeviceId = [[device identifierForVendor]UUIDString];    
    return currentDeviceId;
}

+(CGSize)screenSize
{
    CGSize size=[UIScreen mainScreen].bounds.size;
    return size;
}

@end
