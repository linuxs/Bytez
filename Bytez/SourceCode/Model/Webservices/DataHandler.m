//
//  DataHandler.m
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "DataHandler.h"
#import "APIHandler.h"
#import "RecentImagesResponseDTO.h"
#import "StatusResponseDTO.h"
#import "ResponseImageDTO.h"
#import "APIKeyConstants.h"
#import "NearByPlacesResponseDTO.h"
#import "CommentImageResponseDTO.h"
#import "CommentsDTO.h"

@implementation DataHandler

#pragma mark Recent and popular images

+(void)getPopularImages:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler getPopularImages:requestDetails successHandler:^(id obj) {
        successHandler([DataHandler getRecentResponseDtoFrom:obj]);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

+ (void) getRecentImages:(NSDictionary *)requestDetails successHandler:(void(^)(id obj))successHandler failureHandler:(void(^)(NSError *))failureHanlder
{
    [APIHandler getRecentImages:requestDetails successHandler:^(id obj) {
        successHandler([DataHandler getRecentResponseDtoFrom:obj]);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

+(RecentImagesResponseDTO*) getRecentResponseDtoFrom: (id) responseObject
{
    StatusResponseDTO *status=[[StatusResponseDTO alloc]init];
    status.status=[[[responseObject objectForKey:API_STATUS]objectForKey:API_STATUS] integerValue];
    status.message=[[responseObject objectForKey:API_STATUS]objectForKey:API_STATUS_MESSAGE];
    
    RecentImagesResponseDTO *recentImageRespone=[[RecentImagesResponseDTO alloc]init];
    recentImageRespone.status=status;
    
    if (200==status.status) {
        recentImageRespone.imageList=[DataHandler getRecentImageListFrom:[responseObject objectForKey:API_RECENT_IMAGES]];
    }
    
    return recentImageRespone;
}

+(NSMutableArray*) getRecentImageListFrom:(NSArray*)responseImageList
{
    if (responseImageList==nil) {
        return [NSMutableArray array];
    }
    NSMutableArray *imageList=[[NSMutableArray alloc]init];
    
    for (id responseImage in responseImageList) {
        ResponseImageDTO *imageDto=[[ResponseImageDTO alloc]init];
        imageDto.imageId=[[responseImage objectForKey:API_RECENT_IMAGE_ID] integerValue];
        imageDto.imageName=[responseImage objectForKey:API_RECENT_IMAGE_NAME];
        imageDto.imageDescription=[responseImage objectForKey:API_RECENT_IMAGE_DESCRIPTION];
        imageDto.latitude=[responseImage objectForKey:API_RECENT_LATITUDE];
        imageDto.longitude=[responseImage objectForKey:API_RECENT_LONGITUDE];
        imageDto.userId=[[responseImage objectForKey:API_RECENT_USER_ID] longValue];
        imageDto.createdOn=[[responseImage objectForKey:API_REGISTER_CREATED_ON] longLongValue];
        imageDto.Liked=[responseImage objectForKey:API_RECENT_IS_LIKED];
        imageDto.numberOfComments=[[responseImage objectForKey:API_RECENT_COMMENTS] longValue];
        imageDto.numberOfLikes=[[responseImage objectForKey:API_RECENT_LIKES] longValue];
        imageDto.isDeleted=[[responseImage objectForKey:API_RECENT_IS_DELETED] boolValue];
        imageDto.location=[responseImage objectForKey:API_RECENT_LOCATION];
        imageDto.spamReport=[[responseImage objectForKey:API_RECENT_SPAM_REPORT] longValue];
        imageDto.unReadCommentCount=[[responseImage objectForKey:API_RECENT_UNREAD_COMMENT_COUNT] longValue];
        imageDto.unReadLikeCount=[[responseImage objectForKey:API_RECENT_UNREAD_LIKES_COUNT] longValue];
        imageDto.strReportedByMe=[responseImage objectForKey:API_RECENT_IS_REPORTED];
        [imageList addObject:imageDto];
        
    }
    return imageList;
}

#pragma mark Image Like

+(void)likeImage:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    
    [APIHandler likeImageWith:requestDetails successHandler:^(id response) {
        StatusResponseDTO *status=[DataHandler statusResponseDTO:[response objectForKey:API_STATUS]];
//        if (status.status==200) {
            successHandler(status);
//        }else
//        {
//            failureHanlder([NSError errorWithDomain:status.message code:status.status userInfo:nil]);
//        }
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}


#pragma mark Image Comments

+(void)submitImageComment:(NSDictionary*)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler postCommentFor:requestDetails successHandler:^(id obj) {
        successHandler(obj);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}


+(void)getImageComments:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler getImageComments:requestDetails successHandler:^(id obj) {
        CommentImageResponseDTO *response=[[CommentImageResponseDTO alloc]init];
        response.commentsList=[DataHandler commentDTOFrom:[obj objectForKey:API_COMMENTS_COMMENTSLIST]];
        successHandler(response.commentsList);
    } failureHandler:^(NSError * error) {
        failureHanlder(error);
    }];
}

+(void)deleteComment:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler deleteComment:requestDetails successHandler:^(id response) {
        successHandler(response);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

+(NSMutableArray*)commentDTOFrom:(NSArray*)commentsList
{
    if (commentsList==nil) {
        return [NSMutableArray array];
    }
    NSMutableArray *commentList=[[NSMutableArray alloc]init];
    
    for (id responseComment in commentsList) {
        CommentsDTO *comment=[[CommentsDTO alloc]init];
        comment.commentId=[[responseComment objectForKey:API_COMMENTS_ID]longValue];
        comment.imageId=[[responseComment objectForKey:API_COMMENTS_IMAGE_ID]longValue];
        comment.comment=[responseComment objectForKey:API_COMMENTS_COMMENT];
        comment.userId=[[responseComment objectForKey:API_COMMENTS_USER_ID]longValue];
        comment.createdOn=[[responseComment objectForKey:API_COMMENTS_CREATED_ON]longLongValue];
        [commentList addObject:comment];
    }
    return commentList;
}

#pragma mark Report image

+(void)reportImage:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler reportImage:requestDetails successHandler:^(id obj) {
        StatusResponseDTO *status=[DataHandler statusResponseDTO:[obj objectForKey:API_STATUS]];
        if (status.status==200) {
            successHandler(status);
        }else
        {
            failureHanlder([NSError errorWithDomain:status.message code:status.status userInfo:nil]);
        }
        
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

+(void)deleteImage:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler deleteImage:requestDetails successHandler:^(id response) {
        successHandler(response);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

#pragma mark NearbyPlaces

+(void)getMyNearbyPlacesWithLat:(NSString*)latitude longitude:(NSString*)longitude  successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler getMyNearbyPlacesWithLat:latitude longitude:longitude successHandler:^(id obj) {
        NSArray *placesList=[obj objectForKey:API_NEAR_BY_RESULTS];
        NSMutableArray *placeResponseDTO=[[NSMutableArray alloc]init];
        for (int i=0; i<placesList.count; i++) {
            NSDictionary *dict=[placesList objectAtIndex:i];
            NearByPlacesResponseDTO *responseDTO=[[NearByPlacesResponseDTO alloc]init];
            responseDTO.placeName=[dict objectForKey:API_NEAR_BY_PLACE_NAME];
            responseDTO.vicinity=[dict objectForKey:API_NEAR_BY_VICINITY];
            
            [placeResponseDTO addObject:responseDTO];
        }
        
        successHandler(placeResponseDTO);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}
//Changes
//+(void)getMyNearbyPlacesWithLat:(NSString*)latitude longitude:(NSString*)longitude radius:(NSString *)miles  successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder{
//    [APIHandler getMyNearbyPlacesWithLat:latitude longitude:longitude radius:miles successHandler:^(id obj) {
//        NSArray *placesList=[obj objectForKey:API_NEAR_BY_RESULTS];
//        NSMutableArray *placeResponseDTO=[[NSMutableArray alloc]init];
//        for (int i=0; i<placesList.count; i++) {
//            NSDictionary *dict=[placesList objectAtIndex:i];
//            NearByPlacesResponseDTO *responseDTO=[[NearByPlacesResponseDTO alloc]init];
//            responseDTO.placeName=[dict objectForKey:API_NEAR_BY_PLACE_NAME];
//            responseDTO.vicinity=[dict objectForKey:API_NEAR_BY_VICINITY];
//            [placeResponseDTO addObject:responseDTO];
//        }
//        successHandler(placeResponseDTO);
//    } failureHandler:^(NSError *error) {
//          failureHanlder(error);
//    }];
//}

#pragma mark Mycave

+(void)getMyCaveDetails:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler getMyCaveDetails:requestDetails successHandler:^(id obj) {
        successHandler([DataHandler getRecentImageListFrom:[obj objectForKey:API_MY_CAVE_IMAGES]]);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}
#pragma mark Push notification

+(void)registerPushNotification:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler registerPushNotification:requestDetails successHandler:^(id response) {
        successHandler(response);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

+(void)unregisterPushNotification:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    [APIHandler registerPushNotification:requestDetails successHandler:^(id response) {
        successHandler(response);
    } failureHandler:^(NSError *error) {
        failureHanlder(error);
    }];
}

#pragma mark Dictionary to Class object

+(StatusResponseDTO*)statusResponseDTO:(NSDictionary*)responseDict
{
    StatusResponseDTO *status=[[StatusResponseDTO alloc]init];
    status.status=[[responseDict objectForKey:API_STATUS] integerValue];
    status.message=[responseDict objectForKey:API_STATUS_MESSAGE];
    return status;
}

@end
