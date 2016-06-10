//
//  CommentsDTO.h
//  Bytez
//
//  Created by HMSPL on 16/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentsDTO : NSObject

@property(assign,nonatomic) long commentId;
@property(assign,nonatomic) NSInteger imageId;
@property(strong,nonatomic) NSString* comment;
@property(assign,nonatomic) long userId;
@property(assign,nonatomic) long long createdOn;
@property(assign,nonatomic) NSUInteger commentHeight;

@end
