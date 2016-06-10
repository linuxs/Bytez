//
//  MyCaveModel.h
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol MyCaveModelDelegate <NSObject>

@required

-(void)updateMyCaveDetails;
-(void) updateLikesCountWith:(NSString*)likesCount AndCommentsCountWith:(NSString*)commentsCount;

@end

@interface MyCaveModel : NSObject

@property(strong,nonatomic) id<MyCaveModelDelegate> delegate;

@property(strong,nonatomic) NSMutableArray *arrayMyCaveImages;

-(void)getMyCaveImages;

-(void)deleteImageWithImageId:(NSArray*)imageId;

@end
