//
//  RecentImageModel.h
//  Bytez
//
//  Created by Jeyaraj on 12/17/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseImageDTO.h"

@protocol RecentImageModelDelegate <NSObject>

@required


-(void) refreshPopularImageList:(BOOL)refresh;
-(void) refreshRecentImageList:(BOOL)refresh;
-(void) refreshRowAtIndex:(NSUInteger)rowNumber;
-(void) refreshPopularRowAtIndex:(NSUInteger)rowNumber;
-(void) shownoFeedView;

-(void)requestedImageComments:(NSArray*)commentsArray;
-(void) showAlertWithMessage:(NSString*) message;
-(void) showFailureToastWithMessage:(NSString*)message;

@end

@interface RecentImageModel : NSObject

@property (assign,atomic) id<RecentImageModelDelegate> delegate;
@property (strong,atomic) NSMutableArray *recentImageList;
@property (strong,nonatomic) NSMutableArray *popularImageList;
@property (assign,nonatomic) NSUInteger currentlyReportedImage;

-(void) getRecentImageWithLat:(NSString*)latitude andLongitude:(NSString*)longitude forPullDownToRefresh:(BOOL)isPullDownToRefresh;

-(void)getPopularImageWithLat:(NSString*)latitude andLongitude:(NSString*)longitude forPullDownToRefresh:(BOOL)isPullDownToRefresh;

-(void)refreshRecentImages:(NSString*) latitude andLongitude:(NSString*)longitude;

-(void) refreshPopularImages:(NSString*) latitude andLongitude:(NSString*)longitude;

-(void)getImageCommentsForImage:(NSString*)imageId;

-(void)likeImageWithImageID:(NSInteger)imageId;

-(void)updateLikeForImageWithImageId:(NSInteger)imageId;

-(void)updateLikeForImageWithImageId:(NSInteger)imageId withLikeCount:(NSInteger)likeCount;

-(void)reportImageWithImageId:(NSInteger)imageId forReason:(NSString *)reason;

-(ResponseImageDTO*)getRecentResponseImageDto:(NSInteger)imageId;

-(void)updateCommentCountForImage:(NSUInteger)imageId WithCount:(NSUInteger)count;

-(void)updateReportCountFor:(NSUInteger)imageId WithCount:(NSUInteger)count;

-(void)deleteImageWithImageId:(NSArray*)imageId;

@end
