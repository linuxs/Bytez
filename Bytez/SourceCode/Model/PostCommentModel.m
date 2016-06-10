//
//  PostCommentModel.m
//  Bytez
//
//  Created by HMSPL on 17/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "PostCommentModel.h"
#import "DataHandler.h"
#import "APIKeyConstants.h"
#import "Reachability.h"
#import "CommentsDTO.h"
#import "AlertConstants.h"
#import "RegisterDeviceHandler.h"
#import "StatusResponseDTO.h"

@implementation PostCommentModel
{
    NSString* selectedCommentId;
}
- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;;
}
-(void)submitComment:(NSString *)comment forImage:(NSUInteger)imageId
{
    if (![self connected]) {
        [self.delegate showFailureAlertWithMessage:ALERT_NO_NETWORK];
    }
    
    //Convert Emoji to unicode
   NSString *uniText = [NSString stringWithUTF8String:[comment UTF8String]];
   // NSString *textDescription=comment;
    NSString *textDescription=uniText;
    NSData *data = [textDescription dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *requestedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu",(unsigned long)imageId],API_REQUEST_COMMENT_IMAGE_ID,description,API_REQUEST_COMMENT_COMMENTS,[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_COMMENT_USER_ID, nil];

    
    //NSDictionary *requestedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lu",(unsigned long)imageId],API_REQUEST_COMMENT_IMAGE_ID,comment,API_REQUEST_COMMENT_COMMENTS,[RegisterDeviceHandler getRegisteredUserId],API_REQUEST_COMMENT_USER_ID, nil];
    [DataHandler submitImageComment:requestedDictionary successHandler:^(id response) {
        if ([PostCommentModel statusResponseDTO:[response objectForKey:API_STATUS]].status==200) {
            //            [self.delegate showSuccessAlertWithMessage:ALERT_COMMENT_POSTED];
            [self getImageCommentsForImage:[NSString stringWithFormat:@"%lu",(unsigned long)imageId]];
        }else if ([PostCommentModel statusResponseDTO:[response objectForKey:API_STATUS]].status==206)
        {
            [self.delegate showFailureAlertWithMessage:@"Image Not Exits"];
        }
    } failureHandler:^(NSError *error) {
        [self.delegate showFailureAlertWithMessage:@"Try Again"];
    }];
}
-(void)reportImageWithImageId:(NSInteger)imageId forReason:(NSString*)reason
{
    if (![self connected]) {
        [self.delegate showFailureAlertWithMessage:ALERT_NO_NETWORK];
    }
    NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
    NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)imageId],API_REQUEST_COMMENT_IMAGE_ID,userId,API_REQUEST_COMMENT_USER_ID,reason,API_REPORT_REASON, nil];
    
    [DataHandler reportImage:requestDetails successHandler:^(id response) {
        self.reportCount++;
            [self.delegate showSuccessAlertWithMessage:@"Image Reported Successfully"];
    } failureHandler:^(NSError *er) {
        [self.delegate showFailureAlertWithMessage:er.localizedDescription];
    }];
}
-(void)getImageCommentsForImage:(NSString *)imageId
{
    if (![self connected]) {
        [self.delegate showFailureAlertWithMessage:ALERT_NO_NETWORK];
    }
    NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
    NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:imageId,API_REQUEST_COMMENT_IMAGE_ID,userId,API_REQUEST_COMMENT_USER_ID, nil];
    
    [DataHandler getImageComments:requestDetails successHandler:^(NSArray* obj) {
        self.listOfComments=[obj mutableCopy];
        if ([self.listOfComments count]>0) {
            
            if ( self!=nil && self.delegate!=nil) {
                dispatch_after(0.2, dispatch_get_main_queue(), ^{
                    [self.delegate refreshCommentList];

                });

//                [self.delegate refreshCommentList];
            }
        }
    } failureHandler:^(NSError *error) {
    }];
}

-(void)deleteComment:(NSString *)imageId
{
    if (![self connected]) {
        [self.delegate showFailureAlertWithMessage:ALERT_NO_NETWORK];
    }
    selectedCommentId=imageId;
    
    NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
    NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:imageId,API_REQUEST_COMMENT_ID,userId,API_REQUEST_COMMENT_USER_ID, nil];
    
    [DataHandler deleteComment:requestDetails successHandler:^(id response) {
        if ([PostCommentModel statusResponseDTO:[response objectForKey:API_STATUS]].status==200) {
            //            [self.delegate showSuccessAlertWithMessage:ALERT_COMMENT_POSTED];
            for (CommentsDTO *commentResponse in self.listOfComments) {
                if (commentResponse.commentId == [selectedCommentId longLongValue]) {
                    [self.listOfComments removeObject:commentResponse];
                    break;
                }
            }
            [self.delegate refreshCommentList];
        }
    } failureHandler:^(NSError *error) {
        [self.delegate showFailureAlertWithMessage:error.localizedDescription];
    }];
}


-(void)likeImageWithImageID:(NSInteger)imageId
{
    if (![self connected]) {
        [self.delegate showFailureAlertWithMessage:ALERT_NO_NETWORK];
    }
    
    [self.delegate updateLikeImage];
        NSString * userId=[RegisterDeviceHandler getRegisteredUserId];
        NSDictionary *requestDetails=[[NSDictionary alloc]initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld",(long)imageId],API_REQUEST_COMMENT_IMAGE_ID,userId,API_REQUEST_COMMENT_USER_ID, nil];
        
        [DataHandler likeImage:requestDetails successHandler:^(StatusResponseDTO *success) {
//            if (success.status==200) {
//                if ( self!=nil && self.delegate!=nil) {
//                }
//            }else if(success.status==206)
//                [self.delegate showFailureAlertWithMessage:@"Image Not Exists"];
        }
                failureHandler:^(NSError *error) {
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
