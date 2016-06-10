//
//  APIHandler.m
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "APIHandler.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"
#import "URLConstants.h"
#import "AppDelegate.h"
#import "BytezSessionHandler.h"
#import "APIKeyConstants.h"
#import "AFURLSessionManager.h"

@implementation APIHandler

#pragma mark RegisterDevice

+(void)registerDevice:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_REGISTER];
    
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

#pragma mark Upload image

+(void)postImageWith:(NSDictionary *)requestDetails withImageData:(NSData *)data successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder  progressHandler:(void(^)(double ))progress
{
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_POST_IMAGE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", nil];
    AFHTTPRequestOperation *requestOperation = [manager POST:url parameters:requestDetails constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: data name:API_REQUEST_POST_IMAGE_KEY fileName:@"temp.png" mimeType:@"image/png"];
    }
                                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                           NSLog(@"Success: %@ - %@", operation.responseString, responseObject);
                                           successHandler(responseObject);
                                       }
                                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                           NSLog(@"Error: %@ - %@", operation.responseString, error);
                                           failureHanlder(error);
                                       }];
    [requestOperation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        double percentDone = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
        //Upload Progress bar here
        NSLog(@"progress updated(percentDone) : %f", percentDone);
        progress(percentDone);
    }];
    [requestOperation start];
}

#pragma mark Like image

+(void)likeImageWith:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_LIKE_IMAGE];
    
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

#pragma mark Comments

+(void)postCommentFor:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_POST_COMMENT];
    
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

+(void)getImageComments:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_GET_IMAGE_COMMENTS];
    
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];

}

+(void)deleteComment:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_DELETE_COMMENT];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

#pragma mark MyCave

+(void)getMyCaveDetails:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_GET_MY_CAVE];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [BytezSessionHandler Instance].currentTime= operation.response.allHeaderFields[@"Date"];
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

#pragma mark Home feed

+(void)getPopularImages:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_POPULAR_IMAGES];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        [BytezSessionHandler Instance].currentTime= operation.response.allHeaderFields[@"Date"];
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

+(void)getRecentImages:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    //2015-01-07 10:41:48 created on format
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_RECENT_IMAGES];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@ - %@",responseObject,operation.response.allHeaderFields[@"Date"]);
//        [responseObject setValue:operation.response.allHeaderFields[@"Date"] forKey:@"CurrentDate"];
        [BytezSessionHandler Instance].currentTime= operation.response.allHeaderFields[@"Date"];
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

#pragma mark Report image

+(void)reportImage:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_REPORT_IMAGE];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

+(void)deleteImage:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_DELETE_IMAGE];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}

#pragma mark Push notification

+(void)registerPushNotification:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_REGISTER_MY_DEVICE_TOKEN];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];

}

+(void)unregisterPushNotification:(NSDictionary *)requestDetails successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"%@%@",URL_BASE,URL_REGISTER_MY_DEVICE_TOKEN];
    [manager POST:url parameters:requestDetails constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];

}

#pragma mark Google Places API

+(void)getMyNearbyPlacesWithLat:(NSString*)latitude longitude:(NSString*)longitude  successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    manager.responseSerializer=[AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSString * url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=500&sensor=true&key=%@",latitude,longitude,GOOGLE_MAP_API_KEY];
    
    //  NSString * url=@"https://maps.googleapis.com/maps/api/place/search/json?location=12.9758,80.2205&radius=500&types=food&sensor=true&key=AIzaSyBcKfJFcLnJVcSIPGd3BSavKRwI9P-U5FQ";
    [manager POST:url parameters:nil constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        successHandler(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        failureHanlder(error);
    }];
}



//Changes
//+(void)getMyNearbyPlacesWithLat:(NSString*)latitude longitude:(NSString*)longitude radius:(NSString *)miles  successHandler:(void (^)(id))successHandler failureHandler:(void (^)(NSError *))failureHanlder{
//    if ([[[BytezSessionHandler Instance]bytezRadius] isEqualToString:@"1"]) {
//        miles=@"100";
//    }else if([[[BytezSessionHandler Instance]bytezRadius] isEqualToString:@"3"]){
//        miles=@"300";
//    }else{
//        miles=@"50000";
//    }
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
//    manager.responseSerializer=[AFJSONResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
//    NSString *url=[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=%@,%@&radius=%@&types=@""&sensor=true&key=%@",latitude,longitude,miles,GOOGLE_MAP_API_KEY];
//    NSLog(@"URL Value==%@",url);
//    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
//        successHandler(responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);
//        failureHanlder(error);
//    }];
//}


@end
