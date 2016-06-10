//
//  SettingsModel.h
//  Bytez
//
//  Created by HMSPL on 04/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol SettingsModelDelegate <NSObject>

@required

-(void) updateSettingsScreenWith:(NSInteger)mile pushNotification:(BOOL)status;

@end

@interface SettingsModel : NSObject

@property (strong,nonatomic) id<SettingsModelDelegate> delegate;
-(void) initView;
-(void) updatePushNotificationStatus :(BOOL) status;
-(void) updateRecentImageDistance :(BOOL)status;
-(void) saveImageRadius:(NSString*) radius;

@end
