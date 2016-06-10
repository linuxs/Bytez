//
//  RegisterDeviceResponseDTO.h
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StatusResponseDTO.h"

@interface RegisterDeviceResponseDTO : NSObject

@property (strong, atomic) StatusResponseDTO * status;
@property (strong, atomic) NSString * created_On;

@end
