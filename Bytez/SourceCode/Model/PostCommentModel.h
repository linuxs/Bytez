//
//  PostCommentModel.h
//  Bytez
//
//  Created by HMSPL on 17/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PostCommentModelDelegate <NSObject>

@required

//-(void) commentSuccess;
-(void) showSuccessAlertWithMessage:(NSString*) message;
-(void) showFailureAlertWithMessage:(NSString*)message;

-(void) updateLikeImage;

-(void) navigateToHome;
-(void) refreshCommentList;


@end
@interface PostCommentModel : NSObject

@property(assign,nonatomic) id<PostCommentModelDelegate> delegate;
@property (assign,nonatomic) NSUInteger reportCount;
@property(strong,nonatomic) NSMutableArray *listOfComments;

-(void)getImageCommentsForImage:(NSString*)imageId;

-(void)submitComment:(NSString*)comment forImage:(NSUInteger)imageId;

-(void)deleteComment:(NSString*)imageId;

-(void)reportImageWithImageId:(NSInteger)imageId forReason:(NSString*)reason;

-(void)likeImageWithImageID:(NSInteger)imageId;

@end
