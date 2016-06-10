//  Lib.m
//  ios-pilot-app
//
//  Created by Sathish on 12/1/15.
//  Copyright © 2015 OptiSol Business Solutions pvt ltd. All rights reserved.

#import "Lib.h"
#import <CommonCrypto/CommonHMAC.h>

#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

static Lib *instance = nil;

@implementation UIImage (Crop)

static UIImage *imageInstance = nil;
+ (UIImage *)getInstance
{
    @synchronized(self)
    {
        if (imageInstance==nil)
        {
            imageInstance = [UIImage new];
        }
    }
    return imageInstance;
}

- (UIImage *)crop:(CGRect)rect {
    if (self.scale > 1.0f) {
        rect = CGRectMake(rect.origin.x * self.scale,
                          rect.origin.y * self.scale,
                          rect.size.width * self.scale,
                          rect.size.height * self.scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return result;
}

- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality image:(UIImage *)imgName{
    BOOL drawTransposed;
    
    switch (imgName.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize userImage:imgName]
               drawTransposed:drawTransposed
         interpolationQuality:quality image:imgName];
}
// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize userImage:(UIImage *)imgName{
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (imgName.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    return transform;
}
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality image:(UIImage *)img{
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = img.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);

    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

@end

const NSString *phoneRegex = @"^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$";//@"^((\\+)|(00))[0-9]{6,14}$";

/*const NSString *emailRegEx =
@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.) {3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";*/

//const NSString *emailRegEx =@"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
const NSString *emailRegEx =@"^[A-Za-z0-9][A-Za-z0-9\\._\\-]*@([A-Za-z0-9]([A-Za-z0-9\\-]+\\.))+[A-Za-z0-9]{2,4}$";

const NSString *numberRegEx = @"[0-9]+";
const NSString *userNameRegex = @"[a-zA-Z0-9._-]{3,15}";

@implementation UIView(Extended)
- (UIImage *) imageByRenderingView {
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end

@implementation NSString (Utilities)
- (BOOL) isPhoneNumber{
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL phoneValidates = [phoneTest evaluateWithObject:[self trim]];
    return phoneValidates;
}

- (BOOL) isEmail {
	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
	return [regExPredicate evaluateWithObject:self];
}

- (NSString*)trim {
    return [self stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (BOOL) isUserName{
    NSPredicate *regExTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", userNameRegex];
    return [regExTest evaluateWithObject:[self trim]];
}

@end


static NSMutableDictionary* settings;
@implementation Lib

+ (Lib *)getInstance
{
    @synchronized(self)
    {
        if (instance==nil)
        {
            instance = [Lib new];
        }
    }
    return instance;
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

+(void)saveImageToPhotoAlbum:(UIImage*)image{
//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//    // Request to save the image to camera roll
//    [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
//        if (error) {
//            NSLog(@"error");
//        } else {
//            NSLog(@"url %@", assetURL);
//        }
//    }];
//    library = nil;
    CIImage *saveToSave = [CIImage imageWithCGImage:image.CGImage];;//[[CIImage alloc] initWithCGImage:image.CGImage options:nil];;//image.CIImage;
    // 2
    CIContext *softwareContext = [CIContext
                                  contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)} ];
    // 3
    CGImageRef cgImg = [softwareContext createCGImage:saveToSave
                                             fromRect:[saveToSave extent]];
    // 4
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:cgImg
                                 metadata:[saveToSave properties]
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                              // 5
                              CGImageRelease(cgImg);
                               NSLog(@"url %@ -- %@", assetURL,error);
                          }];
}
+ (NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

+ (NSArray*)sortListData:(NSArray*)dataSource sortWithKey:(NSString*)myKey isAsc:(BOOL)isAsc
{
	NSArray * result = nil;
	
	if (dataSource.count >0) {
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:myKey ascending:isAsc];
		NSArray * tmpListEpisodeSorted = [dataSource sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		result = tmpListEpisodeSorted;
	}
	return result;
}

+(BOOL)object:(id)object classNamed:(NSString*)name {
    return [[[object class] description] isEqualToString:name];
}

//+(NSString*)imageBase64:(UIImage*)image {
//    NSString* retStr = nil;
//    NSData* data = UIImageJPEGRepresentation(image, 1.0);
//    if (data) {
//        retStr = [data base64EncodedString];
//    }
//    return retStr;
//}
//+(NSString*)randomID {
//    return [NSString stringWithFormat:@"%i%00i",[[NSDate date] timeIntervalSince1970],arc4random() % 999];
//}
//
//+ (NSString *)GetUUID{
//    CFUUIDRef theUUID = CFUUIDCreate(NULL);
//    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
//    CFRelease(theUUID);
//    return (NSString *)string;
//}

+(NSString*)docDirPath {
    return [NSHomeDirectory() stringByAppendingString:@"/Documents"];
}

+(void)showConfirmAlert:(NSString*)title withMessage:(NSString*)msg tag:(NSInteger)tag delegate:(id)delegate{
    if (!title || [title isEqual: @""]) {
        title = @"Error";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:delegate
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO",nil];
    alertView.tag = tag;
    [alertView show];
    alertView = nil;
}
+(void)showConfirmAlert:(NSString*)title withMessage:(NSString*)msg delegate:(id)delegate{
    if (!title || [title isEqual: @""]) {
        title = @"Error";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:delegate
                                              cancelButtonTitle:@"YES"
                                              otherButtonTitles:@"NO",nil];
    [alertView show];
    alertView = nil;
}

+(void)showAlert:(NSString*)title withMessage:(NSString*)msg delegate:(id)delegate{
    if (!title || [title isEqual: @""]) {
        title = @"Error";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.delegate= delegate;
    [alertView show];
    alertView = nil;
    
}

+(void)showAlert:(NSString*)title withMessage:(NSString*)msg {
    if (!title || [title isEqual: @"" ]) {
        title = @"Error";
    }
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    alertView = nil;
}

+ (BOOL)isHasConnection {
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        return NO;
    }
    return YES;
}

+(id)getValueOfKey:(NSString*)key {	
	if (!settings) {
		settings = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:AppSettingsKey]];
		if (!settings) {
			settings = [[NSMutableDictionary alloc] init];
		}
	}
	if ([settings objectForKey:key]) {
		return [settings objectForKey:key];
	}
	
	return nil;
}

+(void)setValue:(id)value ofKey:(NSString*)key {
	if (!settings) {
		settings = [NSMutableDictionary dictionaryWithDictionary:[[[NSUserDefaults standardUserDefaults] objectForKey:AppSettingsKey] mutableCopy]];
		if (!settings) {
			settings = [[NSMutableDictionary alloc] init];
		}
	}
    if (value) {
        [settings setObject:value  forKey:[key mutableCopy]];
    } else {
        [settings removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setObject:settings forKey:AppSettingsKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString*)stringFromDictOrEmpty:(NSDictionary*)dict :(id)key {
    if (dict &&
        [dict objectForKey:key] &&
        ![[NSNull null] isEqual:[dict objectForKey:key]]) {
        return [dict objectForKey:key];
    }
    return @"";
}

+ (void)showLoadingViewOn2:(UIView *)aView withAlert:(NSString *)text{
	
	UIView *loadingView = [[UIView alloc] init];
	loadingView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin|
	UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
	loadingView.frame = ([Lib isIphone])?CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height):CGRectMake(0, 0, aView.frame.size.width, aView.frame.size.height-80);
	loadingView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
	loadingView.tag = 1011;
	UILabel *loadingLabel = [[UILabel alloc ] init];
	
	UIView* roundedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 80)];
	roundedView.center = CGPointMake(loadingView.frame.size.width/2, loadingView.frame.size.height/2);
	roundedView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
	roundedView.layer.borderColor = [UIColor clearColor].CGColor;
	roundedView.layer.borderWidth = 1.0;
	roundedView.layer.cornerRadius = 10.0;
	[loadingView addSubview:roundedView];
	roundedView.autoresizingMask = loadingLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	
	loadingLabel.text = text;
	loadingLabel.frame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y + 50, 200, 30);
	//loadingLabel.adjustsFontSizeToFitWidth = YES;
	loadingLabel.textAlignment = NSTextAlignmentCenter;
	loadingLabel.font = [UIFont boldSystemFontOfSize:14];	
	loadingLabel.backgroundColor = [UIColor clearColor];
	loadingLabel.textColor = [UIColor whiteColor];
	[loadingView addSubview:loadingLabel];
	
	UIActivityIndicatorView *activityIndication = [[UIActivityIndicatorView alloc] init];
	activityIndication.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	activityIndication.frame = CGRectMake((loadingView.frame.size.width - 30)/2,
										  roundedView.frame.origin.y + 15,
										  30,
										  30);
	
	[activityIndication startAnimating];	
	[loadingView addSubview:activityIndication];
	activityIndication.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;

	//	[activityIndication release];
	[aView addSubview:loadingView];
}

+ (void)removeLoadingViewOn:(UIView *)superView{
	for (UIView *aView in superView.subviews) {
		if ((aView.tag == 1011)  && [aView isKindOfClass:[UIView class]]) {
			[aView removeFromSuperview];
		}
	}
}

+(BOOL)hasLoadingViewOnView:(UIView*)aView {
    return ([aView viewWithTag:1011] != nil);
}

+ (void)showIndicatorViewOn2:(UIView *)aView{
	
	UIActivityIndicatorView *activityIndication = [[UIActivityIndicatorView alloc] init];
	activityIndication.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
	int width = [Lib isIphone]?20:30;
	activityIndication.frame = CGRectMake((aView.frame.size.width - width)/2,
										  (aView.frame.size.height-width)/2,
										  width,
										  width);
	
	activityIndication.tag = 1012;
	[activityIndication startAnimating];	
	activityIndication.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	
	
	[aView addSubview:activityIndication];
}

+ (void)removeIndcatorViewOn:(UIView *)superView {
	for (UIView *aView in superView.subviews) {
		if ((aView.tag == 1012)  && [aView isKindOfClass:[UIActivityIndicatorView class]]) {
			[aView removeFromSuperview];
		}
	}
}


+(NSDate*)getThisWeek {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components weekday] - 1))]; 
    NSDate *thisWeek  = [cal dateFromComponents:components];
    return thisWeek;
}

+(NSDate*)getThisMonth {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components day] -1))]; 
    NSDate *thisMonth = [cal dateFromComponents:components];
    return thisMonth;
}

+(NSDate*)getLastMonth {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents* components = [cal components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[[NSDate alloc] init]];
    
    [components setDay:([components day] - ([components day] -1))];
    [components setMonth:([components month] - 1)]; 
    NSDate *lastMonth = [cal dateFromComponents:components];

    return lastMonth;
}

+(BOOL)isIphone {
    return !(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad);
}

+ (void)customWebview : (UIWebView *)aWebView {
	// tranparent WebView
	aWebView.opaque = NO;
	aWebView.backgroundColor = [UIColor clearColor];
	// web view
	id scroller = [aWebView.subviews objectAtIndex:0];
	
	for (UIView *subView in [scroller subviews])
		if ([[[subView class] description] isEqualToString:@"UIImageView"])
			subView.hidden = YES;
    
}

//+(void)saveImage:(UIImage*)image withPath:(NSString *)imagePath{
//    
//    image = [UIImage imageWithImage:image scaledToSize:CGSizeMake(189, 189*image.size.height/image.size.width)];
//    
//    NSData *imageData = UIImageJPEGRepresentation(image,1.0); //convert image into .png format.
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];//create instance of NSFileManager
//    
//    NSString *fullPath = [NSHomeDirectory() stringByAppendingPathComponent:imagePath]; //add our image to the path
//    
//    [fileManager createFileAtPath:fullPath contents:imageData attributes:nil]; //finally save the path (image)
//} 

+ (BOOL) checkRetina{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        return YES;
    } else {
        // non-Retina display
        return NO;
    }
}

//+ (NSString *)getModel {
//    size_t size;
//    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//    char *model = malloc(size);
//    sysctlbyname("hw.machine", model, &size, NULL, 0);
//    NSString *sDeviceModel = [NSString stringWithCString:model encoding:NSUTF8StringEncoding];
//    free(model);                              
//    if ([sDeviceModel isEqual:@"i386"])      return @"Simulator";  //iPhone Simulator
//    if ([sDeviceModel isEqual:@"iPhone1,1"]) return @"iPhone1G";   //iPhone 1G
//    if ([sDeviceModel isEqual:@"iPhone1,2"]) return @"iPhone3G";   //iPhone 3G
//    if ([sDeviceModel isEqual:@"iPhone2,1"]) return @"iPhone3GS";  //iPhone 3GS
//    if ([sDeviceModel isEqual:@"iPhone3,1"]) return @"iPhone4";    //@"iPhone3GS";  //iPhone 4 - AT&T
//    if ([sDeviceModel isEqual:@"iPhone3,2"]) return @"iPhone4";    //@"iPhone3GS";  //iPhone 4 - Other carrier
//    if ([sDeviceModel isEqual:@"iPhone3,3"]) return @"iPhone4";    //iPhone 4 - Other carrier
//    if ([sDeviceModel isEqual:@"iPhone4,1"]) return @"iPhone4S";   //iPhone 4S
//    if ([sDeviceModel isEqual:@"iPod1,1"])   return @"iPod1stGen"; //iPod Touch 1G
//    if ([sDeviceModel isEqual:@"iPod2,1"])   return @"iPod2ndGen"; //iPod Touch 2G
//    if ([sDeviceModel isEqual:@"iPod3,1"])   return @"iPod3rdGen"; //iPod Touch 3G
//    if ([sDeviceModel isEqual:@"iPod4,1"])   return @"iPod4thGen"; //iPod Touch 4G
//    if ([sDeviceModel isEqual:@"iPad1,1"])   return @"iPadWiFi";   //iPad Wifi
//    if ([sDeviceModel isEqual:@"iPad1,2"])   return @"iPad3G";     //iPad 3G
//    if ([sDeviceModel isEqual:@"iPad2,1"])   return @"iPad2";      //iPad 2 (WiFi)
//    if ([sDeviceModel isEqual:@"iPad2,2"])   return @"iPad2";      //iPad 2 (GSM)
//    if ([sDeviceModel isEqual:@"iPad2,3"])   return @"iPad2";      //iPad 2 (CDMA)
//    
//    NSString *aux = [[sDeviceModel componentsSeparatedByString:@","] objectAtIndex:0];
//    
//    //If a newer version exist
//    if ([aux rangeOfString:@"iPhone"].location!=NSNotFound) {
//        int version = [[aux stringByReplacingOccurrencesOfString:@"iPhone" withString:@""] intValue];
//        if (version == 3) return @"iPhone4";
//        if (version >= 4) return @"iPhone4s";
//        
//    }
//    if ([aux rangeOfString:@"iPod"].location!=NSNotFound) {
//        int version = [[aux stringByReplacingOccurrencesOfString:@"iPod" withString:@""] intValue];
//        if (version >=4) return @"iPod4thGen";
//    }
//    if ([aux rangeOfString:@"iPad"].location!=NSNotFound) {
//        int version = [[aux stringByReplacingOccurrencesOfString:@"iPad" withString:@""] intValue];
//        if (version ==1) return @"iPad3G";
//        if (version >=2) return @"iPad2";
//    }
//    //If none was found, send the original string
//    return sDeviceModel;
//}

+(UIImage*)scaleAndRotateImage:(UIImage *)image
{
    // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    int kMaxResolution = width;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    CGFloat scaleRatio = 1;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;

    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    scaleRatio=1;
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -1, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    [self setRotatedImage:imageCopy];
    return imageCopy;
}

+ (UIColor *)randomColor{
    CGFloat red = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat green = ( arc4random() % 256 / 256.0 );  //  0.5 to 1.0, away from white
    CGFloat blue = ( arc4random() % 256 / 256.0 );  //  0.5 to 1.0, away from black
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    return color;
}

+(NSString*)getLanguage {
    NSString* lang = @"en";
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"da"]) {
        lang = @"da";
    }
    return lang;
}

@end
