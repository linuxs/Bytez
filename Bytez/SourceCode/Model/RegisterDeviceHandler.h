//
//  RegisterDeviceHandler.h
//  Bytez
//
//  Created by Jeyaraj on 12/23/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RegisterDeviceHandler : NSObject

+ (NSString *)getRegisteredUserId;

- (void) registerDeviceWithSuccessHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

@end
