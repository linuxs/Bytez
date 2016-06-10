//
//  RecentImagesResponseDTO.h
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusResponseDTO.h"
#import "ResponseImageDTO.h"


@interface RecentImagesResponseDTO : NSObject

@property(strong,nonatomic) StatusResponseDTO *status;
@property(strong,nonatomic) NSMutableArray * imageList;

@end
