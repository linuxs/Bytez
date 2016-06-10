//
//  APIHandler.h
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIHandler : NSObject

+ (void) postImageWith:(NSDictionary *)requestDetails withImageData:(NSData*)data successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder progressHandler:(void(^)(double ))progress;

+ (void) getRecentImages:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void) getPopularImages:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void) registerDevice:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void) reportImage:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void) getImageComments:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void)likeImageWith:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder;

+ (void)deleteImage:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder;

+ (void)deleteComment:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder;

+ (void) postCommentFor:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void) getMyCaveDetails:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+ (void) getMyNearbyPlacesWithLat:(NSString*)latitude longitude:(NSString*)longitude successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder;

+(void) registerPushNotification:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder;

+(void) unregisterPushNotification:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder;
//Changes
//+(void)getMyNearbyPlacesWithLat:(NSString*)latitude longitude:(NSString*)longitude radius:(NSString *)miles  successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder;


@end
