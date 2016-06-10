//
//  ResponseImageDTO.h
//  Bytez
//
//  Created by HMSPL on 02/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResponseImageDTO : NSObject

@property(assign,nonatomic) NSInteger imageId;

@property(strong,nonatomic) NSString * imageName;
@property(strong,nonatomic) NSString * latitude;
@property(strong,nonatomic) NSString * longitude;
@property(strong,nonatomic) NSString * imageDescription;
@property(strong,nonatomic) NSString * Liked;
@property(strong,nonatomic) NSString * postedTime;
@property(strong,nonatomic) NSString * location;

@property(strong,nonatomic) NSString * createdOnTime;

@property(assign,nonatomic) long long createdOn;
@property(assign,nonatomic) long userId;
@property(assign,nonatomic) long numberOfLikes;
@property(assign,nonatomic) long numberOfComments;
@property(assign,nonatomic) long spamReport;
@property(assign,nonatomic) long unReadCommentCount;
@property(assign,nonatomic) long unReadLikeCount;

@property(strong,nonatomic) NSDate *createdOnDate;
@property(strong,nonatomic) NSString *strReportedByMe;

@property(assign,nonatomic) BOOL isLikedByMe;
@property(assign,nonatomic) BOOL isDeleted;
@property(assign,nonatomic) BOOL isReportedByMe;

@property(strong,nonatomic) NSString *displayImage;
@property(strong,nonatomic) NSString *displayText;


@end
