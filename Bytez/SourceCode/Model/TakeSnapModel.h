//
//  TakeSnapModel.h
//  Bytez
//
//  Created by Jeyaraj on 12/23/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TakeSnapModelDelegate <NSObject>

@required

-(void) showAlertWithMessage:(NSString*) message;
-(void) showFailureAlertWithMessage:(NSString*) message;
-(void) navigateTohome;

@end

@interface TakeSnapModel : NSObject

@property (assign,atomic) id<TakeSnapModelDelegate> delegate;

-(void) postImageWithData:(NSData*)data alongWithDescription:(NSString*) description AndLocation:(NSString*)locationName latitude:(NSString*)lat longtitude:(NSString*)longitude progress:(void (^)(double))progressHandler;

-(NSString*) getByteArrayForImage:(UIImage*)image;

@end
