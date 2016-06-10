//
//  RecentImageModel.m
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "RecentImageModel.h"
#import "DataHandler.h"
#import "Reachability.h"
#import "APIKeyConstants.h"
#import "RecentImagesResponseDTO.h"
#import "AppDelegate.h"
#import "RegisterDeviceHandler.h"
#import "BytezSessionHandler.h"
#import "AlertConstants.h"

@implementation RecentImageModel
{
    NSUInteger currentlyLikedImageId;
    
    NSMutableArray *mageIdToDelete;
}
- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;;
}

-(void) getRecentImageWithLat:(NSString*)latitude andLongitude:(NSString*)longitude forPullDownToRefresh:(BOOL)isPullDownToRefresh
{
    currentlyLikedImageId=-1;
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
    }
    if (self.recentImageList==nil) {
        self.recentImageList=[NSMutableArray array];
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:latitude forKey:API_REQUEST_RECENT_LATITUDE];
    [dict setObject:longitude forKey:API_REQUEST_RECENT_LONGTITUDE];
    [dict setObject:[RegisterDeviceHandler getRegisteredUserId] forKey:API_REQUEST_COMMENT_USER_ID];
    if ([self.recentImageList count]==0) {
        [dict setObject:@"false" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
    }
    else if (isPullDownToRefresh) {
        [dict setObject:@"false" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
        [dict setObject:[BytezSessionHandler Instance].bytezRadius forKey:API_REQUEST_RECENT_MILES];
        ResponseImageDTO *firstImage= [self.recentImageList objectAtIndex:0];
        [dict setObject:firstImage.createdOnTime forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
        [DataHandler getRecentImages:dict successHandler:^(id obj) {
            BOOL hasNewImages=NO;
            RecentImagesResponseDTO *response=(RecentImagesResponseDTO*)obj;
            for (int i=(int)response.imageList.count - 1;i>=0;i--) {
                ResponseImageDTO *newImage = [response.imageList objectAtIndex:i];
                if (![self.recentImageList containsObject:newImage]) {
                    [self.recentImageList insertObject:newImage atIndex:0];
                    hasNewImages=YES;
                }
            }
            [[self delegate] refreshRecentImageList:hasNewImages];
        } failureHandler:^(NSError *error) {
            [[self delegate] refreshRecentImageList:NO];
        }];
        return;
    }else
    {
        [dict setObject:@"true" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
    }
    if ([self.recentImageList count]>0) {
        ResponseImageDTO *firstImage= [self.recentImageList objectAtIndex:[self.recentImageList count]-1];
        [dict setObject:firstImage.createdOnTime forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
    }else{
        [dict setObject:@"" forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
    }
    [dict setObject:[BytezSessionHandler Instance].bytezRadius forKey:API_REQUEST_RECENT_MILES];
    [DataHandler getRecentImages:dict successHandler:^(id obj) {
        BOOL hasNewImages=NO;
        
        RecentImagesResponseDTO *responseDto=(RecentImagesResponseDTO*)obj;
        for (ResponseImageDTO *response in responseDto.imageList) {
            if (![self.recentImageList containsObject:response]) {
                hasNewImages=YES;
                [self.recentImageList addObject:response];
            }
        }
        if ([self.recentImageList count]==0) {
            [[self delegate] shownoFeedView];
        }
        [[self delegate] refreshRecentImageList:hasNewImages];
        
    } failureHandler:^(NSError *error) {
        [[self delegate] refreshRecentImageList:NO];
    }];
    //    }
}

-(void)getPopularImageWithLat:(NSString*)latitude andLongitude:(NSString*)longitude forPullDownToRefresh:(BOOL)isPullDownToRefresh
{
    currentlyLikedImageId=-1;
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
    }
    if (self.popularImageList==nil) {
        self.popularImageList=[NSMutableArray array];
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:latitude forKey:API_REQUEST_RECENT_LATITUDE];
    [dict setObject:longitude forKey:API_REQUEST_RECENT_LONGTITUDE];
    [dict setObject:[RegisterDeviceHandler getRegisteredUserId] forKey:API_REQUEST_COMMENT_USER_ID];
    if ([self.popularImageList count]==0) {
        [dict setObject:@"false" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
    }
    else if (isPullDownToRefresh) {
        [dict setObject:@"false" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
        [dict setObject:[BytezSessionHandler Instance].bytezRadius forKey:API_REQUEST_RECENT_MILES];
        ResponseImageDTO *firstImage= [self.popularImageList objectAtIndex:0];
        [dict setObject:firstImage.createdOnTime forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
        [DataHandler getPopularImages:dict successHandler:^(id obj) {
            BOOL hasNewImages=NO;
            RecentImagesResponseDTO *response=(RecentImagesResponseDTO*)obj;
            for (int i=(int)response.imageList.count-1;i>=0;i--) {
                ResponseImageDTO *newImage = [response.imageList objectAtIndex:i];
                if (![self.popularImageList containsObject:newImage]) {
                    [self.popularImageList insertObject:newImage atIndex:0];
                    hasNewImages=YES;
                }
            }
            [[self delegate] refreshPopularImageList:hasNewImages];
        } failureHandler:^(NSError *error) {
            [[self delegate] refreshPopularImageList:NO];
            
        }];
        return;
    }else
    {
        [dict setObject:@"true" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
    }
    [dict setObject:[BytezSessionHandler Instance].bytezRadius forKey:API_REQUEST_RECENT_MILES];
    if ([self.popularImageList count]>0) {
        ResponseImageDTO *firstImage= [self.popularImageList objectAtIndex:[self.popularImageList count]-1];
        [dict setObject:firstImage.createdOnTime forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
    }else{
        [dict setObject:@"" forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
    }
    NSLog(@"Popular Request %@",dict);
    [DataHandler getPopularImages:dict successHandler:^(id obj) {
        BOOL hasNewImages=NO;
        
        RecentImagesResponseDTO *responseDto=(RecentImagesResponseDTO*)obj;
        for (ResponseImageDTO *response in responseDto.imageList) {
            if (![self.popularImageList containsObject:response]) {
                hasNewImages=YES;
                [self.popularImageList addObject:response];
            }
        }
        [[self delegate] refreshPopularImageList:hasNewImages];
    } failureHandler:^(NSError *error) {
        [[self delegate] refreshPopularImageList:NO];
    }];
    
}

-(void)refreshPopularImages:(NSString *)latitude andLongitude:(NSString *)longitude
{
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
    }
    if (self.popularImageList==nil) {
        self.popularImageList=[NSMutableArray array];
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:latitude forKey:API_REQUEST_RECENT_LATITUDE];
    [dict setObject:longitude forKey:API_REQUEST_RECENT_LONGTITUDE];
    [dict setObject:[RegisterDeviceHandler getRegisteredUserId] forKey:API_REQUEST_COMMENT_USER_ID];
    [dict setObject:@"false" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
    [dict setObject:[BytezSessionHandler Instance].bytezRadius forKey:API_REQUEST_RECENT_MILES];
    [dict setObject:@"" forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
    [DataHandler getPopularImages:dict successHandler:^(id obj) {
        RecentImagesResponseDTO *responseDto=(RecentImagesResponseDTO*)obj;
        [self.popularImageList removeAllObjects];
        self.popularImageList=responseDto.imageList;
        if ([self.popularImageList count]==0) {
            [[self delegate] refreshPopularImageList:NO];
        }else{
            [[self delegate] refreshPopularImageList:YES];
        }
    } failureHandler:^(NSError *error) {
        [[self delegate] refreshPopularImageList:NO];
    }];
    
}

-(void)refreshRecentImages:(NSString *)latitude andLongitude:(NSString *)longitude
{
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
    }
    if (self.recentImageList==nil) {
        self.recentImageList=[NSMutableArray array];
    }
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setObject:latitude forKey:API_REQUEST_RECENT_LATITUDE];
    [dict setObject:longitude forKey:API_REQUEST_RECENT_LONGTITUDE];
    [dict setObject:[RegisterDeviceHandler getRegisteredUserId] forKey:API_REQUEST_COMMENT_USER_ID];
    [dict setObject:@"false" forKey:API_REQUEST_RECENT_PULL_DOWN_REFREST];
    [dict setObject:@"" forKey:API_REQUEST_RECENT_LAST_UPDATE_TIME];
    [dict setObject:[BytezSessionHandler Instance].bytezRadius forKey:API_REQUEST_RECENT_MILES];
    [DataHandler getRecentImages:dict successHandler:^(id obj) {
        BOOL hasNewImages=NO;
        
        RecentImagesResponseDTO *responseDto=(RecentImagesResponseDTO*)obj;
        [self.recentImageList removeAllObjects];
        self.recentImageList =responseDto.imageList;
        if ([self.recentImageList count]==0) {
            [[self delegate] shownoFeedView];
        }
        else
            hasNewImages=YES;
        [[self delegate] refreshRecentImageList:hasNewImages];
    } failureHandler:^(NSError *error) {
        [[self delegate] refreshRecentImageList:NO];
    }];
}

-(void)getImageCommentsForImage:(NSString *)imageId
{
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
    }
    NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
    NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:imageId,API_REQUEST_COMMENT_IMAGE_ID,userId,API_REQUEST_COMMENT_USER_ID, nil];
    
    [DataHandler getImageComments:requestDetails successHandler:^(NSArray* obj) {
        [self.delegate requestedImageComments:obj];
    } failureHandler:^(NSError *error) {
        [self.delegate showAlertWithMessage:@""];
    }];
}

-(ResponseImageDTO*)getRecentResponseImageDto:(NSInteger)imageId
{
    for (ResponseImageDTO *response in self.recentImageList) {
        if (response.imageId==imageId) {
            return response;
            break;
        }
    }
    
    for (ResponseImageDTO *response in self.popularImageList) {
        if (response.imageId==imageId) {
            return response;
            break;
        }
    }
    return NULL;
}

#pragma mark Like Image

-(void)likeImageWithImageID:(NSInteger)imageId
{
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
    }
    if (currentlyLikedImageId==-1) {
        currentlyLikedImageId=imageId;
        [self updateRecentImageListWithLikeCount:1];
        currentlyLikedImageId=-1;
        NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
        NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)imageId],API_REQUEST_COMMENT_IMAGE_ID,userId,API_REQUEST_COMMENT_USER_ID, nil];
        
        [DataHandler likeImage:requestDetails successHandler:^(id success) {
            
        } failureHandler:^(NSError *error) {
            currentlyLikedImageId=-1;
        }];
    }
}

-(void)updateLikeForImageWithImageId:(NSInteger)imageId
{
    currentlyLikedImageId=imageId;
    [self updateRecentImageListWithLikeCount:1];
    currentlyLikedImageId=-1;
}

-(void)updateRecentImageListWithLikeCount:(NSInteger)newLikeCount
{
    for (int i=0;i<[self.recentImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.recentImageList objectAtIndex:i];
        if (recentImage.imageId==currentlyLikedImageId) {
            if ([recentImage.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_TRUE]) {
                [recentImage setLiked:API_RESPONSE_VALUE_LIKE_FALSE];
                [recentImage setNumberOfLikes:[recentImage numberOfLikes]-newLikeCount];
            }else
            {
                [recentImage setLiked:API_RESPONSE_VALUE_LIKE_TRUE];
                [recentImage setNumberOfLikes:[recentImage numberOfLikes]+newLikeCount];
            }
            
            [self.delegate refreshRowAtIndex:i];
            break;
        }
    }
    
    for (int i=0;i<[self.popularImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.popularImageList objectAtIndex:i];
        if (recentImage.imageId==currentlyLikedImageId) {
            if ([recentImage.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_TRUE]) {
                [recentImage setLiked:API_RESPONSE_VALUE_LIKE_FALSE];
                [recentImage setNumberOfLikes:[recentImage numberOfLikes]-newLikeCount];
            }else
            {
                [recentImage setLiked:API_RESPONSE_VALUE_LIKE_TRUE];
                [recentImage setNumberOfLikes:[recentImage numberOfLikes]+newLikeCount];
            }
            [self.delegate refreshPopularRowAtIndex:i];
            break;
        }
    }
}


-(void)updateLikeForImageWithImageId:(NSInteger)imageId withLikeCount:(NSInteger)likeCount
{
    currentlyLikedImageId=imageId;
    if(likeCount!=0)
        [self updateRecentImageListWithLikeCountFromComments];
    currentlyLikedImageId=-1;
}
-(void)updateRecentImageListWithLikeCountFromComments
{
    for (int i=0;i<[self.recentImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.recentImageList objectAtIndex:i];
        if (recentImage.imageId==currentlyLikedImageId) {
            
                [recentImage setLiked:[BytezSessionHandler Instance].likedCountInComments.Liked];
                [recentImage setNumberOfLikes:[BytezSessionHandler Instance].likedCountInComments.numberOfLikes];
            
            [self.delegate refreshRowAtIndex:i];
            break;
        }
    }
    
    
    for (int i=0;i<[self.popularImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.popularImageList objectAtIndex:i];
        if (recentImage.imageId==currentlyLikedImageId) {
            [recentImage setLiked:[BytezSessionHandler Instance].likedCountInComments.Liked];
            [recentImage setNumberOfLikes:[BytezSessionHandler Instance].likedCountInComments.numberOfLikes];
            [self.delegate refreshPopularRowAtIndex:i];
            break;
        }
    }
}


-(void)updateCommentCountForImage:(NSUInteger)imageId WithCount:(NSUInteger)count
{
    for (int i=0;i<[self.recentImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.recentImageList objectAtIndex:i];
        if (recentImage.imageId==imageId) {
            //            [recentImage setNumberOfComments:[recentImage numberOfComments]+1];
            [recentImage setNumberOfComments:count];
            [self.delegate refreshRowAtIndex:i];
            break;
        }
    }
    
    for (int i=0;i<[self.popularImageList count];i++) {
        ResponseImageDTO *popularImage=[ self.popularImageList objectAtIndex:i];
        if (popularImage.imageId==imageId) {
            //            [recentImage setNumberOfComments:[recentImage numberOfComments]+1];
            [popularImage setNumberOfComments:count];
            [self.delegate refreshPopularRowAtIndex:i];
            break;
        }
    }
}

#pragma mark Report image

-(void)reportImageWithImageId:(NSInteger)imageId forReason:(NSString *)reason
{
    if (![self connected]) {
        [self.delegate showFailureToastWithMessage:ALERT_NO_NETWORK];
        return;
    }
    if (self.currentlyReportedImage==-1) {
        self.currentlyReportedImage=imageId;
        NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
        NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)imageId],API_REQUEST_COMMENT_IMAGE_ID,userId,API_REQUEST_COMMENT_USER_ID, nil];
        
        [DataHandler reportImage:requestDetails successHandler:^(id response) {
            [self updateReportCountFor:self.currentlyReportedImage WithCount:1];
            [self.delegate showAlertWithMessage:ALERT_REPORT_IMAGE];
            self.currentlyReportedImage=-1;
        } failureHandler:^(NSError *er) {
            //            [self.delegate showFailureToastWithMessage:@""];
            self.currentlyReportedImage=-1;
        }];
    }
}
-(void)updateReportCountFor:(NSUInteger)imageId WithCount:(NSUInteger)count
{
    for (int i=0;i<[self.recentImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.recentImageList objectAtIndex:i];
        if (recentImage.imageId==imageId) {
            recentImage.spamReport+=count;
            recentImage.strReportedByMe=@"True";
            if (recentImage.spamReport>5) {
                //                [self.recentImageList removeObject:recentImage];
            }
            [self.delegate refreshRecentImageList:YES];
            break;
        }
    }
    
    for (int i=0;i<[self.popularImageList count];i++) {
        ResponseImageDTO *popularImage=[ self.popularImageList objectAtIndex:i];
        if (popularImage.imageId==imageId) {
            popularImage.spamReport+=count;
            popularImage.strReportedByMe=@"True";
            if (popularImage.spamReport>5) {
                //                [self.popularImageList removeObject:popularImage];
            }
            [self.delegate refreshPopularImageList:YES];
            break;
        }
    }
}

#pragma mark DeleteImage

-(void)deleteImageWithImageId:(NSArray *)imageId
{
    NSSet *set=[[NSSet alloc]initWithArray:imageId];
    mageIdToDelete = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithArray:imageId]];
    
    NSDictionary *requestDict=[NSDictionary dictionaryWithObjectsAndKeys:[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_USER_ID,set,API_REQUEST_COMMENT_IMAGE_ID, nil];
    
    [self updateImageListAfterImageDeleteSuccess];
    
    [DataHandler deleteImage:requestDict successHandler:^(id response) {
//        if ([RecentImageModel statusResponseDTO:[response objectForKey:API_STATUS]].status==200) {
//        }
        
    }failureHandler:^(NSError *error) {
        
    }];
}

//changes
-(void) updateImageListAfterImageDeleteSuccess
{
    BOOL isDeletedImageFound = false;
    BOOL isDeleteImage=false;
    NSInteger unreadCount = 0;
    
    for (int i=0;i<[self.recentImageList count];i++) {
        ResponseImageDTO *recentImage=[ self.recentImageList objectAtIndex:i];
        for (int j=0;j<[mageIdToDelete count];j++) {
            NSInteger imageId = [[mageIdToDelete objectAtIndex:j] integerValue];
            if (recentImage.imageId == imageId) {
                unreadCount=recentImage.unReadCommentCount + recentImage.unReadLikeCount;
                [self.recentImageList removeObjectAtIndex:i];
                if (self.recentImageList.count==0) {
                    isDeleteImage=false;
                    [[self delegate] shownoFeedView];
                }else{
                    isDeleteImage=true;
                    [self.delegate refreshRecentImageList:YES];
                    isDeletedImageFound =true;
                }
                //[self.delegate refreshRecentImageList:YES];
               // isDeletedImageFound =true;
                break;
            }
        }
        if (isDeletedImageFound) {
            isDeletedImageFound = false;
            break;
        }
        
    }
    isDeletedImageFound = false;
    
    for (int i=0;i<[self.popularImageList count];i++) {
        ResponseImageDTO *popularImage=[ self.popularImageList objectAtIndex:i];
        for (int j=0;j<[mageIdToDelete count];j++) {
            NSInteger imageId = [[mageIdToDelete objectAtIndex:j] integerValue];
            if (popularImage.imageId == imageId) {
                unreadCount=popularImage.unReadCommentCount + popularImage.unReadLikeCount;
                [self.popularImageList removeObjectAtIndex:i];
                //[self.delegate refreshPopularImageList:YES];
                //isDeletedImageFound= true;
                if (self.popularImageList.count==0) {
                    isDeleteImage=false;
                    [[self delegate] shownoFeedView];
                }else{
                    isDeleteImage=true;
                    [self.delegate refreshPopularImageList:YES];
                    isDeletedImageFound= true;
                }
                break;
            }
        }
        
        if (isDeletedImageFound) {
            isDeletedImageFound = false;
            break;
        }
    }
    if (unreadCount!=0) {
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdelegate updateMyCaveUnreadCommentAfterDelete:unreadCount];
    }
}

+(StatusResponseDTO*)statusResponseDTO:(NSDictionary*)responseDict
{
    StatusResponseDTO *status=[[StatusResponseDTO alloc]init];
    status.status=[[responseDict objectForKey:API_STATUS] integerValue];
    status.message=[responseDict objectForKey:API_STATUS_MESSAGE];
    return status;
}

@end
