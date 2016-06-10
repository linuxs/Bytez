//
//  TakeSnapViewController.m
//  Bytez
//
//  Created by Jeyaraj on 12/22/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import "TakeSnapViewController.h"
#import "AppDelegate.h"
#import "AlertConstants.h"
#import "TakeSnapModel.h"
#import "BZTabBarItem.h"
#import "NearByPlacesViewController.h"
#import "BZTabBarController.h"
#import "LocationUpdateHandler.h"
#import "CameraOverLayView.h"
#import "CameraFocusView.h"
#import "BytezSessionHandler.h"
#import "Lib.h"
#define IS_IPHONE_4 ([[UIScreen mainScreen]bounds].size.height == 480)
#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)
#define IS_IPHONE_5 ([[UIScreen mainScreen]bounds].size.height == 568)
#define IS_IPHONE_6 ([[UIScreen mainScreen]bounds].size.height == 667)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen]bounds].size.height == 736)

#define IS_OS_7_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
//Map View
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
typedef enum {
    ImageOrientationUp,
    ImageOrientationLeft,
    ImageOrientationRight
    
}RotateImage;

@interface TakeSnapViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,CLLocationManagerDelegate,NearByPlacesViewControllerDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>

@property (assign,atomic) NSInteger flashMode;
@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, assign) BOOL isFocusOverlayShown;
@end
@implementation TakeSnapViewController
{
    __weak IBOutlet UIButton *btnCapture;
    __weak IBOutlet UIButton *btnFlash;
    __weak IBOutlet UIButton *btnHome;
    __weak IBOutlet UIButton *btnMyCave;
    __weak IBOutlet UIButton *btnFront;
    __weak IBOutlet UIButton *btnPost;
    
    __weak IBOutlet UIProgressView *progressViewImageUploader;
    __weak IBOutlet UIView *viewCameraLayer;
    __weak IBOutlet UIView *viewHome;
    __weak IBOutlet UIView *viewPost;
    __weak IBOutlet UIView *viewFlash;
    __weak IBOutlet UIView *viewLocation;
    __weak IBOutlet UIView *viewFooter;
    __weak IBOutlet UIView *viewHeader;
    __weak IBOutlet UIView *viewAddCaption;
    __weak IBOutlet UIView *viewDivider;
    __weak IBOutlet UIView *viewProgressView;
    __weak IBOutlet UIView *viewSwipeHandler;
    
    __weak IBOutlet UILabel *lblLocationName;
    __weak IBOutlet UILabel *lblPost;
    
    __weak IBOutlet UIImageView *imgViewProgressBarBat;
    __weak IBOutlet UIImageView *imgViewCroppedImage;
    __weak IBOutlet UIImageView *imgViewCapturedImage;
    
    __weak IBOutlet NSLayoutConstraint *constraintCroppedImageHeight;
    
    __weak IBOutlet NSLayoutConstraint *constraintPostViewLeading;
    __weak IBOutlet NSLayoutConstraint *constraintHomeViewLeading;
    __weak IBOutlet NSLayoutConstraint *constraintFlashLeading;
    __weak IBOutlet NSLayoutConstraint *constraintLocationLeading;
    __weak IBOutlet NSLayoutConstraint *constraintAddCaptionHeight;
    __weak IBOutlet NSLayoutConstraint *constraintHomeViewTrailing;
    __weak IBOutlet NSLayoutConstraint *constraintAddCaptionBottom;
    __weak IBOutlet NSLayoutConstraint *constraintFlashViewTrailing;
    __weak IBOutlet NSLayoutConstraint *constraintCropCameraHeight;
    
    __weak IBOutlet UIImageView *focusImgView;
    __weak IBOutlet UIView *focusAutoView;
    __weak IBOutlet UITextField *txtFieldCaption;
    
    TakeSnapModel *takeSnapModel;
    RotateImage imageOrientationEnum;
    CameraFocusView *camFocus;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    AVCaptureSession *session;
    CLLocationManager *locationManager;
    
    BOOL hasShowFront;
    BOOL isFlashOn;
    BOOL inPostImageMode;
    bool focusing, finishedFocus, focusOnPoint;
    
    CGPoint focusPoint;
    NSTimer *time;
    int keyBoardQwertySize;
    int keyBoardEmojiSize;
    
    BOOL isCheck;
}

bool focusing = false;
bool finishedFocus = false;
CGPoint focusPoint;
bool focusOnPoint;
bool touchScreen = false;

#pragma mark View initialization


- (void)viewDidLoad {
    [super viewDidLoad];
    txtFieldCaption.autocorrectionType=UITextAutocorrectionTypeDefault;
    takeSnapModel= [[TakeSnapModel alloc]init];
    takeSnapModel.delegate=self;
   constraintCropCameraHeight.constant=self.view.frame.size.width;
   constraintCroppedImageHeight.constant=self.view.frame.size.width;

    [imgViewCroppedImage setHidden:YES];
    txtFieldCaption.delegate=self;
    self.navigationController.navigationBarHidden = YES;
    [viewProgressView.layer setBorderWidth:0.5f];
    [viewProgressView.layer setBorderColor:
     [[UIColor darkGrayColor]CGColor]];
    [viewProgressView.layer setCornerRadius:5.0f];
    [viewProgressView setClipsToBounds:YES];
    
    
    [viewFooter setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
    [viewHeader setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
    
    [[viewFooter layer] setBorderColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor]];
    [[viewFooter layer] setShadowOffset:CGSizeMake(0, 0)];
    [[viewFooter layer] setShadowOpacity:1];
    
    [[viewHeader layer] setBorderColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor]];
    [[viewHeader layer] setShadowOffset:CGSizeMake(0, 0)];
    [[viewHeader layer] setShadowOpacity:1];
    
    
    [[viewDivider layer] setShadowColor:[[UIColor grayColor] CGColor]];
    [[viewDivider layer] setShadowOffset:CGSizeMake(0, 0)];
    [[viewDivider layer] setShadowOpacity:1];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    progressViewImageUploader.transform = transform;
    
    [viewAddCaption setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
    
    [[viewAddCaption layer] setBorderColor:[[UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:0.7] CGColor]];
    [[viewAddCaption layer] setShadowOffset:CGSizeMake(0, 0)];
    [[viewAddCaption layer] setShadowOpacity:1];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(showAddCaptionBox:)];
    doubleTap.numberOfTapsRequired = 2;
    [imgViewCapturedImage addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *doubleTapCropImage = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(showAddCaptionBox:)];
    doubleTapCropImage.numberOfTapsRequired = 2;
    [imgViewCroppedImage addGestureRecognizer:doubleTapCropImage];
    
    [imgViewCroppedImage setUserInteractionEnabled:YES];
    if ([txtFieldCaption respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        UIColor *color = [UIColor whiteColor];
        txtFieldCaption.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Add Caption" attributes:@{NSForegroundColorAttributeName: color}];
    }
    [self hideAddCaptionView];
    
    UISwipeGestureRecognizer *swipeRight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(NavigateToHomeOnSwipe:)];
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(NavigateToMyCaveOnSwipe:)];
    
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [viewSwipeHandler setUserInteractionEnabled:YES];
    [swipeRight setDelegate:self];
    [swipeLeft setDelegate:self];
    [viewSwipeHandler addGestureRecognizer:swipeLeft];
    [viewSwipeHandler addGestureRecognizer:swipeRight];
    
    UITapGestureRecognizer *exposureTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusAndExposeTap:)];
    exposureTap.numberOfTapsRequired=1;
    [self.view addGestureRecognizer:exposureTap];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    isCheck=false;
    [self registerForKeyboardNotifications];
  //  [txtFieldCaption setAutocorrectionType:UITextAutocorrectionTypeNo];
    //changes
    //[txtFieldCaption setAutocorrectionType:UITextAutocorrectionTypeYes];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    int flags = NSKeyValueObservingOptionNew;
    [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self unregisterForKeyboardNotifications];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
    [super viewWillDisappear:animated];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    focusing = false;
    finishedFocus = false;
    focusOnPoint = true;
    if (inPostImageMode) {
        return;
    }
    if (session!=nil) {
//        [self deallocSession];
    }
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetHigh;
    CALayer *viewLayer = viewCameraLayer.layer;
    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResize];
    CGRect bounds=viewLayer.bounds;
    captureVideoPreviewLayer.bounds=bounds;
    captureVideoPreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    captureVideoPreviewLayer.frame = viewCameraLayer.bounds;
    [viewCameraLayer.layer addSublayer:captureVideoPreviewLayer];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasFlash]){
        BytezSessionHandler *bytezSessionHandler = [[BytezSessionHandler alloc] init];
        if ([[bytezSessionHandler getFlashOnOffCamera] isEqualToString:@"OFF"])//device.flashMode == AVCaptureFlashModeOff ||
        {
            //[btnFlash setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
        }
        else
        {
            //[btnFlash setImage:[UIImage imageNamed:@"icon-flash.png"] forState:UIControlStateNormal];
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
        return;
    }
    [session addInput:input];
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [session addOutput:_stillImageOutput];
    //[self disableAutoFocus];
    
    [session startRunning];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    //[self toggleFlashlight];
}

#pragma mark Button Action methods

- (IBAction)btnNavigateHomeAction:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController.delegate tabBarController:appDelegate.viewController shouldSelectViewController:[appDelegate.viewController.viewControllers objectAtIndex:0]];
    [appDelegate.viewController setTabBarHidden:NO animated:YES];
    [self deallocSession];
}

- (IBAction)btnNavigateToMyCaveAction:(id)sender {
    [self deallocSession];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.viewController.delegate tabBarController:appDelegate.viewController shouldSelectViewController:[appDelegate.viewController.viewControllers objectAtIndex:1]];
    [appDelegate.viewController setTabBarHidden:NO animated:YES];
}
- (IBAction)btnTakePictureAction:(id)sender {

    if (!isCheck) {
        btnCapture.userInteractionEnabled=YES;
        isCheck=true;
    }else{
        isCheck=false;
        return;
    }
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection)
        {
            break;
        }
    }
    NSLog(@"about to request a capture from: %@", _stillImageOutput);
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         if (imageSampleBuffer) {
             
             CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
             if (exifAttachments)
             {
                 // Do something with the attachments.
                 NSLog(@"attachements: %@", exifAttachments);
             } else {
                 NSLog(@"no attachments");
             }
             
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *image = [[UIImage alloc] initWithData:imageData];
            // image=[UIImage imageNamed:@"placeholder@2x.png"];
             [self showCapturedImage:image];
             
             [self changePostMode:NO];
             
             //             UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
             [session stopRunning];
         }}];
}

- (IBAction)buttonCancelAction:(id)sender {
    isCheck=false;
    [viewSwipeHandler setHidden:NO];
    [txtFieldCaption endEditing:YES];
    [lblLocationName setText:@""];
    [txtFieldCaption setText:@""];
    [self hideAddCaptionView];

    [imgViewCapturedImage setContentMode:UIViewContentModeScaleAspectFill];
    [imgViewCapturedImage setHidden:YES];
    [imgViewCapturedImage setImage:nil];
    [imgViewCroppedImage setHidden:YES];
    [session startRunning];
    
    [self showProgressView:NO];
    [self changePostMode:YES];
    
}
- (IBAction)btnLocationAction:(id)sender {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NearByPlacesViewController *thirdViewController = [sb instantiateViewControllerWithIdentifier:@"NearByPlacesViewControllerID"];
    thirdViewController.delegate=self;
    [self.navigationController presentViewController:thirdViewController animated:YES completion:^{
    }];
}

- (IBAction)btnFlashOnOff:(id)sender {
    [self toggleFlashlight];
}

- (IBAction)btnFrontRearCameraAction:(UIButton*)sender {
    
    [UIView transitionWithView:btnFront
                      duration:0.25
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                    } completion:^(BOOL finished) {
                    }];
    [self showFrontCamera:hasShowFront];
    
}

- (IBAction)btnPostImageAction:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showProgressWithoutAnimation];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
    
}

- (void) focusAndExposeTap: (UITapGestureRecognizer *)recognizer
{
    [txtFieldCaption resignFirstResponder];
    if (inPostImageMode) {
        return;
    }
    focusOnPoint = false;
    if(recognizer.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint touchPoint = [recognizer locationInView:imgViewCroppedImage];
        CGPoint focusPoint1=[imgViewCroppedImage convertPoint:touchPoint toView:self.view];
        
        UIView* view = recognizer.view;
        CGPoint loc = [recognizer locationInView:view];
        UIView* viewYouWishToObtain = [view hitTest:loc withEvent:nil];
        
        if(viewYouWishToObtain.tag != 100 && viewYouWishToObtain.tag != 101) {
            
        [self focus:touchPoint];
        
        if (camFocus)
        {
            [camFocus removeFromSuperview];
        }
        if ([imgViewCroppedImage isKindOfClass:[UIView class]])
        {
            camFocus = [[CameraFocusView alloc]initWithFrame:CGRectMake(focusPoint1.x, focusPoint1.y, 80, 80)];
            [camFocus setBackgroundColor:[UIColor clearColor]];
            [self.view addSubview:camFocus];
            [camFocus setNeedsDisplay];
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:1.5];
            [camFocus setAlpha:0.0];
            [UIView commitAnimations];
        }
        }
    }
}


#pragma mark Auto Focus

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
#if 0
    focusAutoView.hidden = NO;
    if( [keyPath isEqualToString:@"adjustingFocus"]) {
        
        [self isFocusing:change];
    }
#endif
}

- (void) isFocusing:(NSDictionary *)change {
    
    BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
    if (adjustingFocus) {
        focusing=true;
        //NSLog(@"FOCUSING");
        [self showFocusOverlay];
    }
    else {
        if (focusing) {
            
            focusing = false;
            finishedFocus = true;
            //NSLog(@"DONE FOCUSING");
            [self hideFocusOverlay];
        }
    }
}
- (void) showFocusOverlay {
    
    if(focusOnPoint == true) {
        
        focusOnPoint = false;
        focusImgView.center = self.view.center;
            if (camFocus) {
                
                [camFocus removeFromSuperview];
            }
          [time invalidate];
           time = [NSTimer scheduledTimerWithTimeInterval:2.0
                                             target:self
                                           selector:@selector(endFocusOnPoint)
                                           userInfo:nil
                                            repeats:NO];
            if ([imgViewCroppedImage isKindOfClass:[UIView class]]) {
                
                camFocus = [[CameraFocusView alloc]initWithFrame:CGRectMake(imgViewCroppedImage.center.x -40, imgViewCroppedImage.center.y -40,81, 80)];
                NSLog(@"Front camFocus %@",camFocus);
                NSLog(@"Back camFocus %@",camFocus);
                [camFocus setBackgroundColor:[UIColor clearColor]];
                [self.view addSubview:camFocus];
                [camFocus setNeedsDisplay];
                
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:1.5];
                [camFocus setAlpha:0.0];
                [UIView commitAnimations];
            }
        
        focusImgView.alpha = 0.0f;
    } else focusOnPoint = true;
}


- (void) hideFocusOverlay {

        //NSLog(@"removing focusing overlay");
        [UIView animateWithDuration:0.25 animations:^() {
            focusImgView.alpha = 0.0f;
        } completion:^(BOOL finished) {
           // [focusImgView removeFromSuperview];
        }];
}


- (void) endFocusOnPoint {
    
    focusOnPoint = true;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.animation = @"NO";
}


- (void) focus:(CGPoint) aPoint;
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        //AVCaptureDevice *device = [captureDeviceClass defaultDeviceWithMediaType:AVMediaTypeVideo];
        focusPoint = aPoint;
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
      
        for (AVCaptureDevice *device in devices) {
        
            if([device position] == AVCaptureDevicePositionBack) {
                if(hasShowFront == YES)
                    continue;
                
            } else if([device position] == AVCaptureDevicePositionFront) {
                
                NSLog(@"Front");
                
                if(hasShowFront == NO)
                    break;
                
                NSError* error = nil;
                if ([device lockForConfiguration:&error]) {
                    
                    CGRect screenRect = [[UIScreen mainScreen] bounds];
                    double screenWidth = screenRect.size.width;
                    double screenHeight = screenRect.size.height;
                    double focus_x = aPoint.x/screenWidth;
                    double focus_y = aPoint.y/screenHeight;
                    CGPoint pointOfInterest = CGPointMake(focus_x, focus_y);
                    
                    if ([device isExposurePointOfInterestSupported] &&
                        [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
                        device.exposurePointOfInterest = pointOfInterest;
                       device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                    }
                    if (device.isLowLightBoostSupported)
                        device.automaticallyEnablesLowLightBoostWhenAvailable = YES;
                    
                    [device unlockForConfiguration];
                }
            }
        if([device isFocusPointOfInterestSupported] &&
           [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            double screenWidth = screenRect.size.width;
            double screenHeight = screenRect.size.height;
            double focus_x = aPoint.x/screenWidth;
            double focus_y = aPoint.y/screenHeight;
            if([device  lockForConfiguration:nil]) {
                
                [device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
                [device setExposurePointOfInterest:CGPointMake(focus_x, focus_y)];
                [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];// AVCaptureFocusModeAutoFocus
                if ([device isExposureModeSupported:AVCaptureExposureModeAutoExpose]){
                    [device setExposureMode:AVCaptureExposureModeAutoExpose ];//AVCaptureExposureModeAutoExpose
                    //                    device set
                }
                [device unlockForConfiguration];
            }
        }

            
        }
    }

}
-(void)disableAutoFocus
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    [device setTorchMode:AVCaptureTorchModeOff];
    [device setFlashMode:AVCaptureFlashModeOff];
    
    NSArray *devices = [AVCaptureDevice devices];
    NSError *error;
    for (AVCaptureDevice *device in devices) {
        if (([device hasMediaType:AVMediaTypeVideo]) &&
            ([device position] == AVCaptureDevicePositionBack) ) {
            [device lockForConfiguration:&error];
            if ([device isFocusModeSupported:AVCaptureFocusModeLocked]) {
                device.focusMode = AVCaptureFocusModeLocked;
                NSLog(@"Focus locked");
            }
            
            [device unlockForConfiguration];
        }
    }
}

#pragma mark Image Crop and show in preview

-(UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGRect bounds;
    CGSize imageSize = imageToCrop.size;
    CGSize phonesize = [UIScreen mainScreen].bounds.size;
    float screenheightratio = imageSize.height/phonesize.height;
    float cropwidth = phonesize.width * screenheightratio;
    float cropheight = (imageSize.height/phonesize.height)*self.view.frame.size.width;
    bounds.origin.x=(imageSize.width- cropwidth)/2;
    bounds.size.width=cropwidth;
    bounds.size.height=cropheight;
    bounds.origin.y=(imageSize.height/phonesize.height)*viewHeader.frame.size.height;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(cropwidth, cropheight),YES,[UIScreen mainScreen].scale);//---Changes for better quality
   // UIGraphicsBeginImageContext(CGSizeMake(cropwidth, cropheight));
    CGRect imageRect = CGRectMake(-bounds.origin.x, -bounds.origin.y, imageSize.width, imageSize.height);
    [imageToCrop drawInRect:imageRect];
//    NSLog(@"bounds X: %f, Y: %f, Width: %f,Height: %f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    
    double ratio;
    double delta;
    CGPoint offset;
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)showCapturedImage:(UIImage*) CapturedImage
{
    [viewSwipeHandler setHidden:YES];
    [viewProgressView setHidden:YES];
    [imgViewProgressBarBat setHidden:YES];
    [imgViewCroppedImage setHidden:NO];
    [imgViewCapturedImage setImage:CapturedImage];
    [imgViewCapturedImage setHidden:NO];
    //[imgViewCapturedImage setContentMode:UIViewContentModeScaleToFill];
    
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
   // NSLog(@"%ld",(long)currentOrientation);
    
    switch (currentOrientation) {
            
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
        {
            if (self.view.frame.size.height==480) {
                CGRect rect=CGRectMake(0, viewHeader.frame.size.height, self.view.frame.size.width, self.view.frame.size.width);
                UIImage *image=[self imageByCropping:imgViewCapturedImage.image toRect:rect];
                if(hasShowFront)
                    image=[[UIImage alloc]initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
                else
                    image=[[UIImage alloc]initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
                [imgViewCapturedImage setHidden:YES];
                [imgViewCapturedImage setImage:nil];
                [imgViewCapturedImage setHidden:NO];
                [imgViewCroppedImage setImage:image];
                imageOrientationEnum=ImageOrientationUp;
            }else{
                NSLog(@"iPhone 5 ");
            }
        }
        case UIDeviceOrientationPortraitUpsideDown:
            [imgViewCroppedImage setHidden:YES];
             imageOrientationEnum=ImageOrientationUp;
            break;
        
        case UIDeviceOrientationLandscapeLeft:
        {
            CGRect rect=CGRectMake(0, viewHeader.frame.size.height, self.view.frame.size.width, self.view.frame.size.width);
            UIImage *image=[self imageByCropping:imgViewCapturedImage.image toRect:rect];
            if(hasShowFront)
            image=[[UIImage alloc]initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
            else
            image=[[UIImage alloc]initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
            [imgViewCapturedImage setHidden:YES];
            [imgViewCapturedImage setImage:nil];
            [imgViewCapturedImage setHidden:NO];
            [imgViewCroppedImage setImage:image];
            imageOrientationEnum=ImageOrientationLeft;
        }
            break;
        
        case UIDeviceOrientationLandscapeRight:
        {
            CGRect rect=CGRectMake(0, viewHeader.frame.size.height, self.view.frame.size.width, self.view.frame.size.width);
            UIImage *image=[self imageByCropping:imgViewCapturedImage.image toRect:rect];
            if(hasShowFront)
            image=[[UIImage alloc]initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeft];
            else
                image=[[UIImage alloc]initWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationRight];
                
            [imgViewCapturedImage setHidden:YES];
            [imgViewCapturedImage setImage:nil];
            [imgViewCapturedImage setHidden:NO];
            [imgViewCroppedImage setImage:image];
            imageOrientationEnum=ImageOrientationRight;
        }
            break;
    }
}
- (UIImage *)fixrotation:(UIImage *)image{
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
           // transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            //transform = CGAffineTransformRotate(transform, 0);
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

-(void)changePostMode : (BOOL) isCancelled
{
    double screenWidth=0.0;
    if (isCancelled) {
        [viewCameraLayer setHidden:NO];
        inPostImageMode=NO;
        constraintHomeViewLeading.constant=screenWidth;
        constraintPostViewLeading.constant=screenWidth;
        constraintFlashLeading.constant=screenWidth;
        constraintLocationLeading.constant=screenWidth;
        constraintHomeViewTrailing.constant=screenWidth;
        constraintFlashViewTrailing.constant=screenWidth;
    }
    else
    {
        [viewCameraLayer setHidden:YES];
        inPostImageMode=YES;
        screenWidth=viewHome.frame.size.width;
        constraintHomeViewLeading.constant-=screenWidth;
        //        constraintPostViewLeading.constant-=screenWidth;
        constraintFlashLeading.constant-=screenWidth;
        //        constraintLocationLeading.constant-=screenWidth;
        constraintHomeViewTrailing.constant+=screenWidth;
        constraintFlashViewTrailing.constant+=screenWidth;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [viewHome setNeedsUpdateConstraints];
        [viewLocation setNeedsUpdateConstraints];
        [viewFlash setNeedsUpdateConstraints];
        [viewPost setNeedsUpdateConstraints];
        [viewHome layoutIfNeeded];
        [viewPost layoutIfNeeded];
        [viewFlash layoutIfNeeded];
        [viewLocation layoutIfNeeded];
        [self.view layoutIfNeeded];
    }];
}
-(void)showFrontCamera:(BOOL)isFront {
    
    dispatch_async([self sessionQueue], ^{
    NSLog(@"inside showFrontCamera");
    AVCaptureDeviceInput *videoInput=[session.inputs objectAtIndex:0];
    [session removeInput:[session.inputs objectAtIndex:0]];
    // Grab the front-facing camera
    AVCaptureDevice *backFacingCamera = nil;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (hasShowFront && [device position] == AVCaptureDevicePositionBack) {
            hasShowFront=false;
            backFacingCamera = device;
            break;
        }else if ([device position] == AVCaptureDevicePositionFront) {
            hasShowFront=true;
            backFacingCamera = device;
        }
    }
    // Add the video input
    NSError *error = nil;
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    });
}

- (void) toggleFlashlight {
    BytezSessionHandler *bytezSessionHandler = [[BytezSessionHandler alloc] init];
    NSLog(@"%@",[bytezSessionHandler getFlashOnOffCamera]);
    if([[bytezSessionHandler getFlashOnOffCamera] isEqualToString:@"OFF"])
        [btnFlash setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
    else
        [btnFlash setImage:[UIImage imageNamed:@"icon-flash.png"] forState:UIControlStateNormal];

    dispatch_async([self sessionQueue], ^{
        
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasFlash]) {
            
            if ([[bytezSessionHandler getFlashOnOffCamera] isEqualToString:@"OFF"])//device.flashMode == AVCaptureFlashModeOff ||
            {
                //                [device setTorchMode:AVCaptureTorchModeOn];
                [device lockForConfiguration:nil];
                [device setFlashMode:AVCaptureFlashModeOn];
                [device unlockForConfiguration];
                [btnFlash setImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
                
                [bytezSessionHandler setFlashOnOffCamera:@"ON"];
            }
            else
            {
                //                [device setTorchMode:AVCaptureTorchModeOff];
                [device lockForConfiguration:nil];
                [device setFlashMode:AVCaptureFlashModeOff];
                [device unlockForConfiguration];
                [btnFlash setImage:[UIImage imageNamed:@"icon-flash.png"] forState:UIControlStateNormal];
                
                [bytezSessionHandler setFlashOnOffCamera:@"OFF"];
            }
        }
    }
         NSLog(@"%@",[bytezSessionHandler getFlashOnOffCamera]);
    });
    
   

}

#pragma mark Progress view on uploading

-(void)showProgressView:(BOOL)show
{
    if (show) {
        [viewProgressView setHidden:NO];
        [imgViewProgressBarBat setHidden:NO];
        [progressViewImageUploader setProgress:0.0f];
        [btnPost setHidden:YES];
        [lblPost setHidden:YES];
    }
    else
    {
        [viewProgressView setHidden:YES];
        [imgViewProgressBarBat setHidden:YES];
        [progressViewImageUploader setProgress:0.0f];
        [btnPost setHidden:NO];
        [lblPost setHidden:NO];
    }
}

-(void)NavigateToHomeOnSwipe:(id)sender
{
    [self btnNavigateHomeAction:nil];
}

-(void)NavigateToMyCaveOnSwipe:(id)sender
{
    [self btnNavigateToMyCaveAction:nil];
}

#pragma mark Takesnap delegate

-(void)navigateTohome
{
    [viewSwipeHandler setHidden:NO];
    [txtFieldCaption endEditing:YES];
    [lblLocationName setText:@""];
    [txtFieldCaption setText:@""];
    [self hideAddCaptionView];
    
    [imgViewCapturedImage setContentMode:UIViewContentModeScaleAspectFill];
    [imgViewCapturedImage setHidden:YES];
    [imgViewCroppedImage setHidden:YES];
    
    [self showProgressView:NO];
    [self changePostMode:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isImagePosted=YES;
    
    [self btnNavigateHomeAction:nil];
}

-(void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    alert.tag=21;
    [alert show];
}

-(void)showFailureAlertWithMessage:(NSString *)message
{
    [self showProgressView:NO];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

#pragma mark UITextField delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    if((string.length == 0 || [string isEqualToString:@"\n"]) && txtFieldCaption.text.length == 0)
          [txtFieldCaption setReturnKeyType:UIReturnKeyDefault];
        else
          [txtFieldCaption setReturnKeyType:UIReturnKeyDone];
    
    [txtFieldCaption reloadInputViews];
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 150) ? NO : YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(txtFieldCaption.text.length == 0)
        txtFieldCaption.returnKeyType = UIReturnKeyDefault;
    else
        txtFieldCaption.returnKeyType = UIReturnKeyDone;

    viewFooter.layer.backgroundColor = [[UIColor clearColor]CGColor];
    viewDivider.layer.backgroundColor = [[UIColor clearColor]CGColor];
    [txtFieldCaption reloadInputViews];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self setFooterReColored];
    constraintAddCaptionHeight.constant=24;
    constraintAddCaptionBottom.constant=viewFooter.frame.size.height;
}

#pragma mark Add Caption

-(void)showAddCaptionBox:(id)sender
{
    constraintAddCaptionHeight.constant=24;
    constraintAddCaptionBottom.constant=viewFooter.frame.size.height;
    [UIView animateWithDuration:0.2 animations:^{
        [viewAddCaption layoutIfNeeded];
        [viewAddCaption setHidden:NO];
    }];
    [txtFieldCaption becomeFirstResponder];
}
-(void)hideAddCaptionView
{
    constraintAddCaptionHeight.constant=0;
    [viewAddCaption setNeedsUpdateConstraints];
    [viewAddCaption layoutIfNeeded];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];

}
- (void) keyboardWillChangeFrame:(NSNotification*)notification {
    
    NSDictionary* notificationInfo = [notification userInfo];
    
    CGRect keyboardFrame = [[notificationInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyBoardQwertySize=keyboardFrame.size.height;
    [UIView animateWithDuration:[[notificationInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]
                          delay:0
                        options:[[notificationInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]
                     animations:^{
                         
                         
                     } completion:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"Keyboard is active.");
  //  NSDictionary* info = [aNotification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    keyBoardQwertySize=kbSize.height;
    
    if (IS_IPHONE_5) {
        constraintAddCaptionBottom.constant=keyBoardQwertySize;
    }else{
        constraintAddCaptionBottom.constant=keyBoardQwertySize;
      }
    
    [viewAddCaption setNeedsUpdateConstraints];
    [viewAddCaption layoutIfNeeded];
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"Keyboard is hidden");
    [self hideAddCaptionView];
    [viewAddCaption setNeedsUpdateConstraints];
    [viewAddCaption layoutIfNeeded];
    [self setFooterReColored];
}

- (void)setFooterReColored{
    [viewFooter setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
    [[viewFooter layer] setBorderColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor]];
    [[viewFooter layer] setShadowOffset:CGSizeMake(0, 0)];
    [[viewFooter layer] setShadowOpacity:1];
    
    [viewDivider setBackgroundColor:[UIColor blackColor]];
    [[viewDivider layer] setShadowColor:[[UIColor grayColor] CGColor]];
    [[viewDivider layer] setShadowOffset:CGSizeMake(0, 0)];
    [[viewDivider layer] setShadowOpacity:1];
}

#pragma mark Location Manager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    [locationManager stopUpdatingLocation];
    locationManager=nil;
    CLLocation *currentLocation = [locations objectAtIndex:0];
    if (currentLocation!=nil) {
        
        [txtFieldCaption endEditing:YES];
        NSString *textDescription=txtFieldCaption.text;
         [textDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //Convert Emoji to unicode
        NSData *data = [textDescription dataUsingEncoding:NSNonLossyASCIIStringEncoding];
        NSString *description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (description==nil) {
            description=@"";
        }
        NSString *lat=[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
        NSString *longi=[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        CGRect rect=CGRectMake(0, viewHeader.frame.size.height, self.view.frame.size.width, self.view.frame.size.width);
        UIImage *image;
        if (imgViewCapturedImage.image!=nil) {
            image=[self imageByCropping:imgViewCapturedImage.image toRect:rect];
        }else{
            image=imgViewCroppedImage.image;
        }
        image=[self squareImageWithImage:image scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width)];
//        if(imgViewCapturedImage.image!=nil)
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//        [self showProgressView:YES];
//         [takeSnapModel postImageWithData:UIImageJPEGRepresentation([self fixrotation:image],1.0)  alongWithDescription:description AndLocation:lblLocationName.text latitude:lat longtitude:longi progress:^(double progress) {
//            [progressViewImageUploader setProgress:progress];
//        }];
        //Changes
        UIImage *currentImage = [image resizedImage:CGSizeMake(600,600) interpolationQuality:kCGInterpolationHigh image:image];
        if(imgViewCapturedImage.image!=nil)
            UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil);
        [self showProgressView:YES];
        [takeSnapModel postImageWithData:UIImageJPEGRepresentation([self fixrotation:currentImage],1.0)  alongWithDescription:description AndLocation:lblLocationName.text latitude:lat longtitude:longi progress:^(double progress) {
            [progressViewImageUploader setProgress:progress];
        }];

    }else
    {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate removeProgress];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:ALERT_NO_CURRENT_LOCATION message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeProgress];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark NearbyPlaces Delegate

-(void)selectedLocation:(NearByPlacesResponseDTO *)location
{
    [lblLocationName setText:location.placeName];
}

#pragma mark Rotation change

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)deviceDidRotate:(NSNotification *)notification
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    double rotation = 0;
    UIInterfaceOrientation statusBarOrientation;
    switch (currentOrientation) {
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationUnknown:
            return;
        case UIDeviceOrientationPortrait:
            rotation = 0;
            statusBarOrientation = UIInterfaceOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            //            rotation = -M_PI;
            rotation = 0;
            statusBarOrientation = UIInterfaceOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            rotation = M_PI_2;
            statusBarOrientation = UIInterfaceOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            rotation = -M_PI_2;
            statusBarOrientation = UIInterfaceOrientationLandscapeLeft;
            break;
    }
    CGAffineTransform transform = CGAffineTransformMakeRotation(rotation);
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [btnCapture setTransform:transform];
        [btnFlash setTransform:transform];
        [btnFront setTransform:transform];
        [btnHome setTransform:transform];
        [btnMyCave setTransform:transform];
        [[UIApplication sharedApplication] setStatusBarOrientation:statusBarOrientation];
    } completion:nil];
}

#pragma mark AlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==21) {
        [self buttonCancelAction:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.isImagePosted=YES;
        [self btnNavigateHomeAction:nil];
    }
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)deallocSession
{
    dispatch_async([self sessionQueue], ^{
        
        [session stopRunning];
        
        for(AVCaptureInput *input1 in session.inputs) {
            [session removeInput:input1];
        }
        for(AVCaptureOutput *output1 in session.outputs) {
            [session removeOutput:output1];
        }
        //[session stopRunning];
        [captureVideoPreviewLayer removeFromSuperlayer];
        
        captureVideoPreviewLayer=nil;
        session=nil;
        _stillImageOutput=nil;
    });
    
}

@end
