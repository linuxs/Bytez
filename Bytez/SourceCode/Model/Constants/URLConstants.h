//
//  URLConstants.h
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#ifndef Bytez_URLConstants_h
#define Bytez_URLConstants_h

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)


static NSString * const URL_BASE=@"http://bytezapp.com/bytez/";

//static NSString * const URL_BASE=@"http://192.237.253.117:8080";

static NSString * const URL_IMAGEPATH=@"http://bytezapp.com/";

static NSString * const URL_POST_IMAGE = @"resources/rest/postImage";
static NSString * const URL_RECENT_IMAGES = @"resources/rest/getRecent";
static NSString * const URL_POPULAR_IMAGES = @"resources/rest/getPopular";

static NSString * const URL_REGISTER = @"resources/rest/register";
static NSString * const URL_REPORT_IMAGE = @"resources/rest/reportImage";
static NSString * const URL_DELETE_IMAGE = @"resources/rest/deleteMultipleSelectionImage";

static NSString * const URL_MULTPLE_DELETE_IMAGE =@"resources/rest/deleteMultipleSelectionImage";

static NSString * const URL_POST_COMMENT = @"resources/rest/putComment";
static NSString * const URL_GET_IMAGE_COMMENTS = @"resources/rest/getComments";
static NSString * const URL_DELETE_COMMENT=@"resources/rest/deleteComment";

static NSString * const URL_LIKE_IMAGE = @"resources/rest/putLike";

static NSString * const URL_GET_MY_CAVE = @"resources/rest/getMyCave";
static NSString * const URL_REGISTER_MY_DEVICE_TOKEN =@"resources/rest/registerDeviceToken";

#endif
