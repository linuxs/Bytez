//
//  TakeSnapModel.m
//  Bytez
//
//  Created by Jeyaraj on 12/23/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "TakeSnapModel.h"
#import "APIHandler.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BytezSessionHandler.h"
#import "AlertConstants.h"
#import "APIKeyConstants.h"
#import "RegisterDeviceHandler.h"

@implementation TakeSnapModel

-(NSString *)getByteArrayForImage:(UIImage *)image
{
    //image=[UIImage imageNamed:@"placeholder@2x.png"];
    NSData *data = UIImagePNGRepresentation(image);
    NSString *byteArray  = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
//    [self.delegate setImage:nil];
    return byteArray;
}

-(void) postImageWithData:(NSData*)data alongWithDescription:(NSString*) description AndLocation:(NSString*)locationName latitude:(NSString*)lat longtitude:(NSString*)longitude progress:(void (^)(double))progressHandler
{
    NSDictionary *requestDictionary=[NSDictionary dictionaryWithObjectsAndKeys:description,API_REQUEST_DESCRIPTION,lat,API_REQUEST_LATITUDE,longitude,API_REQUEST_LONGTITUDE,locationName,API_REQUEST_LOCATION,[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_USER_ID, nil];
    
    [APIHandler postImageWith:requestDictionary withImageData:data successHandler:^(id obj) {
//        [self.delegate showAlertWithMessage:ALERT_IMAGE_POSTED];
        [BytezSessionHandler Instance].reloadMyCave=YES;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate removeProgress];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [self.delegate navigateTohome];
    } failureHandler:^(NSError * error) {
        [self.delegate showFailureAlertWithMessage:@"Please try again."];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate removeProgress];
        
    } progressHandler:^(double progress) {
        progressHandler(progress);
    }];
}

@end
