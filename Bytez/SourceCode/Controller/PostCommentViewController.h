//
//  PostCommentViewController.h
//  Bytez
//
//  Created by HMSPL on 05/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentImageResponseDTO.h"
#import "LocationUpdateHandler.h"
#import "ResponseImageDTO.h"

@interface PostCommentViewController : LocationUpdateHandler

@property(strong,atomic) NSArray *commentsResponse;
@property(strong,nonatomic) ResponseImageDTO *imageDetails;
@property(strong,atomic) NSString *imageUrl;
@property(assign,nonatomic) BOOL isFromHomeFeed;

- (void) commentPostedHandler:(void(^)(NSUInteger,NSUInteger,bool))handler;

@end
