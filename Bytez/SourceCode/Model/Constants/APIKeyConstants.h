//
//  APIKeyConstants.h
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#ifndef Bytez_APIKeyConstants_h
#define Bytez_APIKeyConstants_h

//REQUEST CONSTANTS
static NSString * const GOOGLE_MAP_API_KEY=@"AIzaSyBcKfJFcLnJVcSIPGd3BSavKRwI9P-U5FQ";

static NSString * const API_REQUEST_REGISTER_DEVICE_ID      = @"device_id";
static NSString * const API_REQUEST_REGISTER_DEVICE_TOKEN   = @"device_token";
static NSString * const API_REQUEST_POST_IMAGE_KEY          = @"image";
static NSString * const API_REQUEST_LATITUDE                = @"latitude";
static NSString * const API_REQUEST_LONGTITUDE              = @"langitude";
static NSString * const API_REQUEST_LOCATION                = @"location";
static NSString * const API_REQUEST_USER_ID                 = @"user_id";
static NSString * const API_REQUEST_DESCRIPTION             = @"description";

static NSString * const API_REQUEST_COMMENT_IMAGE_ID        =@"image_id";
static NSString * const API_REQUEST_COMMENT_COMMENTS        =@"comments";
static NSString * const API_REQUEST_COMMENT_ID              =@"comment_id";
static NSString * const API_REQUEST_COMMENT_USER_ID         =@"user_id";

//Get recent image api
static NSString * const API_REQUEST_RECENT_LATITUDE                 = @"user_latitude";
static NSString * const API_REQUEST_RECENT_LONGTITUDE               = @"user_langitude";
static NSString * const API_REQUEST_RECENT_MILES                    = @"user_miles";
static NSString * const API_REQUEST_RECENT_LAST_UPDATE_TIME         = @"latest_updated_on";
static NSString * const API_REQUEST_RECENT_PULL_DOWN_REFREST        = @"is_pull_down";

static NSString * const API_REQUEST_LIKE_IMAGE_ID            =@"image_id";
static NSString * const API_REQUEST_LIKE_USER_ID             =@"user_id";

static NSString * const API_REQUEST_MYCAVE_TIME_PERIOD       =@"user_periods";

//Response Constants

//REGISTER API
static NSString * const API_STATUS                  =@"status";
static NSString * const API_STATUS_MESSAGE          =@"message";

static NSString * const API_REGISTER_STATUS       = @"status";
static NSString * const API_REGISTER_MESSAGE      = @"message";
static NSString * const API_REGISTER_USER         = @"user";
static NSString * const API_REGISTER_CREATED_ON   = @"created_On";
static NSString * const API_REGISTER_DEVICE_ID    = @"deviceId";
static NSString * const API_REGISTER_USER_ID      = @"userId";

static NSString * const API_RECENT_IMAGES               =@"images";
static NSString * const API_RECENT_IMAGE_ID             =@"imageId";
static NSString * const API_RECENT_IMAGE_NAME           =@"imageName";
static NSString * const API_RECENT_IMAGE_DESCRIPTION    =@"description";
static NSString * const API_RECENT_LATITUDE             =@"latitude";
static NSString * const API_RECENT_LONGITUDE            =@"langitude";
static NSString * const API_RECENT_USER_ID              =@"userId";
static NSString * const API_RECENT_CREATED_ON           =@"created_On";
static NSString * const API_RECENT_IS_DELETED           =@"isDeleted";
static NSString * const API_RECENT_LIKES                =@"likes";
static NSString * const API_RECENT_COMMENTS             =@"comments";
static NSString * const API_RECENT_IS_LIKED             =@"isLiked";
static NSString * const API_RECENT_IS_REPORTED          =@"isReported";
static NSString * const API_RECENT_LOCATION             =@"location";
static NSString * const API_RECENT_SPAM_REPORT          =@"spamReport";
static NSString * const API_RECENT_UNREAD_COUNT         =@"unreadCount";
static NSString * const API_RECENT_UNREAD_COMMENT_COUNT =@"unreadCommentCount";
static NSString * const API_RECENT_UNREAD_LIKES_COUNT   =@"unreadLikeCount";

static NSString * const API_COMMENTS_COMMENTSLIST       =@"Comments";
static NSString * const API_COMMENTS_ID                 =@"commentId";
static NSString * const API_COMMENTS_IMAGE_ID           =@"imageId";
static NSString * const API_COMMENTS_COMMENT            =@"comments";
static NSString * const API_COMMENTS_USER_ID            =@"userId";
static NSString * const API_COMMENTS_CREATED_ON         =@"created_On";

static NSString * const API_REPORT_REASON               =@"reason";

static NSString * const API_NEAR_BY_RESULTS             =@"results";
static NSString * const API_NEAR_BY_PLACE_NAME          =@"name";
static NSString * const API_NEAR_BY_VICINITY            =@"vicinity";

static NSString * const API_MY_CAVE_IMAGES              =@"images";


static NSString * const API_RESPONSE_VALUE_LIKE_TRUE    =@"True";
static NSString * const API_RESPONSE_VALUE_LIKE_FALSE   =@"False";

#endif
