//
//  MyCaveModel.m
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "MyCaveModel.h"
#import "DataHandler.h"
#import "AlertConstants.h"
#import "APIKeyConstants.h"
#import "ResponseDTO/ResponseImageDTO.h"
#import "RegisterDeviceHandler.h"
#import "StatusResponseDTO.h"
#import "BytezSessionHandler.h"

@implementation MyCaveModel
{
    NSMutableArray *imageIdToDelete;
}
-(void)getMyCaveImages{

    NSDictionary *requestDict=[NSDictionary dictionaryWithObjectsAndKeys:[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_USER_ID,@"30",API_REQUEST_MYCAVE_TIME_PERIOD, nil];
    
    [DataHandler getMyCaveDetails:requestDict successHandler:^(id response) {
        
        self.arrayMyCaveImages=response;
        
        if ([self.arrayMyCaveImages count]>0) {
        
        long likesCount=0;
        long commentCount=0;
            long unreadCount=0;
        
        for (ResponseImageDTO *responseImages in self.arrayMyCaveImages) {
            likesCount+=responseImages.numberOfLikes;
            commentCount+=responseImages.numberOfComments;
            unreadCount+=(responseImages.unReadCommentCount + responseImages.unReadLikeCount);
        }
            if (unreadCount<0) {
                unreadCount=0;
            }
       
        [self.delegate updateLikesCountWith:[NSString stringWithFormat:@"%ld",likesCount] AndCommentsCountWith:[NSString stringWithFormat:@"%ld",(unsigned long)[self.arrayMyCaveImages count]]];
        
            [[BytezSessionHandler Instance] updateBadgeCountForMyCave:unreadCount];
        }else{
            [self.delegate updateLikesCountWith:@"0" AndCommentsCountWith:@"0"];
            [[BytezSessionHandler Instance] updateBadgeCountForMyCave:0];
        }
        [self.delegate updateMyCaveDetails];
    } failureHandler:^(NSError *error) {
        
    }];
}
-(void)deleteImageWithImageId:(NSArray*)imageId
{
    NSSet *set=[[NSSet alloc]initWithArray:imageId];
    imageIdToDelete = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithArray:imageId]];
    
    NSDictionary *requestDict=[NSDictionary dictionaryWithObjectsAndKeys:[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_USER_ID,set,API_REQUEST_COMMENT_IMAGE_ID, nil];
    
    [DataHandler deleteImage:requestDict successHandler:^(id response) {
        if ([MyCaveModel statusResponseDTO:[response objectForKey:API_STATUS]].status==200) {
            [BytezSessionHandler Instance].shouldReloadPopular=YES;
            [BytezSessionHandler Instance].shouldReloadRecent=YES;
            
            for(int i =0; i < imageIdToDelete.count; i++) {
            NSLog(@"%@",self.arrayMyCaveImages);
            for (ResponseImageDTO* responseImage in self.arrayMyCaveImages) {
                
                NSLog(@"%ld",(long)responseImage.imageId);
                NSLog(@"%ld",(long)[[imageIdToDelete objectAtIndex:i] longLongValue]);
                if (responseImage.imageId== [[imageIdToDelete objectAtIndex:i] longLongValue]) {
                    [self.arrayMyCaveImages removeObject:responseImage];
                     break;
                }
            }
            }
            if ([self.arrayMyCaveImages count]>0) {
                
                long likesCount=0;
                long commentCount=0;
                long unreadCount=0;
                
                for (ResponseImageDTO *responseImages in self.arrayMyCaveImages) {
                    likesCount+=responseImages.numberOfLikes;
                    commentCount+=responseImages.numberOfComments;
                    unreadCount+=(responseImages.unReadCommentCount + responseImages.unReadLikeCount);
                }
                
                [self.delegate updateLikesCountWith:[NSString stringWithFormat:@"%ld",likesCount] AndCommentsCountWith:[NSString stringWithFormat:@"%ld",(unsigned long)[self.arrayMyCaveImages count]]];
                [[BytezSessionHandler Instance] updateBadgeCountForMyCave:unreadCount];
            }else
            {
                [self.delegate updateLikesCountWith:@"0" AndCommentsCountWith:@"0"];
                [[BytezSessionHandler Instance] updateBadgeCountForMyCave:0];
            }
            
            [self.delegate updateMyCaveDetails];
        }
    } failureHandler:^(NSError *error) {
        
    }];
}
+(StatusResponseDTO*)statusResponseDTO:(NSDictionary*)responseDict
{
    StatusResponseDTO *status=[[StatusResponseDTO alloc]init];
    status.status=[[responseDict objectForKey:API_STATUS] integerValue];
    status.message=[responseDict objectForKey:API_STATUS_MESSAGE];
    return status;
}
@end
