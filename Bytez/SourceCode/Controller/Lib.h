//  Lib.h
//  ios-pilot-app
//
//  Created by Sathish on 12/1/15.
//  Copyright © 2015 OptiSol Business Solutions pvt ltd. All rights reserved.

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MapKit/MapKit.h>
#import "Reachability.h"

#define AppSettingsKey @"myapp.settings"

@interface NSString (Utilities)
- (BOOL) isEmail;
- (BOOL) isPhoneNumber;
- (BOOL) isUserName;
- (NSString*)trim;
@end

@interface UIImage (Crop){
    
}
+ (UIImage *)getInstance;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality image:(UIImage *)img;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
- (UIImage *)crop:(CGRect)rect;
- (UIImage *)croppedImage:(CGRect)bounds;
- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality image:(UIImage *)img;
- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

@end

@interface UIView(Extended)
- (UIImage *) imageByRenderingView;
@end

@interface Lib : NSObject {
    
}
+ (Lib *)getInstance;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (NSString *)timeFormatted:(int)totalSeconds;
+(void)saveImageToPhotoAlbum:(UIImage*)image;
+(BOOL)isHasConnection;
+(NSString*)stringFromDictOrEmpty:(NSDictionary*)dict :(id)key;
+ (NSArray*)sortListData:(NSArray*)dataSource sortWithKey:(NSString*)myKey isAsc:(BOOL)isAsc;
+(BOOL)object:(id)object classNamed:(NSString*)name;
+(BOOL)isIphone;
+(NSString*)docDirPath;
 
+(void)showConfirmAlert:(NSString*)title withMessage:(NSString*)msg tag:(NSInteger)tag delegate:(id)delegate;
+(void)showConfirmAlert:(NSString*)title withMessage:(NSString*)msg delegate:(id)delegate;
+(void)showAlert:(NSString*)title withMessage:(NSString*)msg delegate:(id)delegate;
+(void)showAlert:(NSString*)title withMessage:(NSString*)msg;
+(id)getValueOfKey:(NSString*)key;
+(void)setValue:(id)value ofKey:(NSString*)key;

+(void)showLoadingViewOn2:(UIView *)aView withAlert:(NSString *)text;
+(BOOL)hasLoadingViewOnView:(UIView*)aView;
+(void)removeLoadingViewOn:(UIView *)superView;
+(NSDate*)getThisWeek;
+(NSDate*)getThisMonth;
+(NSDate*)getLastMonth;
+(void)customWebview : (UIWebView *)aWebView;
+(void)showIndicatorViewOn2:(UIView *)aView;
+(void)removeIndcatorViewOn:(UIView *)superView;

+(void)saveImage:(UIImage*)image withPath:(NSString*)imagePath;

+ (BOOL) checkRetina;
//+ (NSString *)getModel;

+(UIImage*)scaleAndRotateImage:(UIImage *)image;
//+ (NSMutableArray *)decodePolyLine:(NSString *)encodedStr;
+ (UIColor *)randomColor;
//+ (MKPolyline *) polylineFromPoints:(NSArray *)pathArray;
+(NSString*)getLanguage;
 @end
