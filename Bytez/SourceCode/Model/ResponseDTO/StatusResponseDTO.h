//
//  StatusResponseDTO.h
//  Bytez
//
//  Created by Jeyaraj on 12/23/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusResponseDTO : NSObject

@property (strong,atomic) NSString * message;
@property (assign,atomic) NSInteger status;

@end
