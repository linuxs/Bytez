//
//  CommentImageResponseDTO.h
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusResponseDTO.h"

@interface CommentImageResponseDTO : NSObject

@property(strong,nonatomic) StatusResponseDTO *commentStatus;
@property(strong,nonatomic) NSArray *commentsList;

@end
