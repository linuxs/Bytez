//
//  BytezSessionHandler.h
//  Bytez
//
//  Created by HMSPL on 04/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseImageDTO.h"

@interface BytezSessionHandler : NSObject

+ (BytezSessionHandler*) Instance;

@property (assign,nonatomic) BOOL shouldReloadRecent;
@property (assign,nonatomic) BOOL shouldReloadPopular;
@property (assign,nonatomic) BOOL reloadMyCave;
@property (strong,nonatomic) NSString *deviceToken;
@property (assign,nonatomic) NSUInteger LikedImageId;
@property (strong,nonatomic) ResponseImageDTO *likedCountInComments;
@property (strong,nonatomic) NSString *currentTime;

- (BOOL) reloadRecentAndPopular;
- (BOOL) reloadPopular;

-(BOOL) termsAndConditionsAccepted;
-(BOOL) appTourCompleted;

-(void) setTermsAndConditionsStatus:(BOOL)agree;
-(void) setAppTourStatus:(BOOL)status;

-(void) setBytezRadius:(NSString*)radius;
-(void) setPushNotificationStatus:(BOOL)status;

-(NSString*) bytezRadius;
-(BOOL) pushNotificationStatus;

-(void)updateBadgeCountForMyCave:(NSUInteger)count;

-(NSDate*)serverTime;

- (void)setFlashOnOffCamera:(NSString *)position;
- (NSString *)getFlashOnOffCamera;


@end
