//
//  AppDelegate.m
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "AppDelegate.h"
#import "BytezSessionHandler.h"
#import "BZTabBarItem.h"
#import "BZTabBar.h"
#import "HomeViewController.h"
#import "RightToLeftNavigationControllerViewController.h"
#import "TakeSnapViewController.h"
#import "MyCaveViewController.h"
#import "YXSpritesLoadingView.h"
#import "WalkThroughViewController.h"
#import "ViewController.h"
#import "SettingsViewController.h"
#import "DataHandler.h"
#import "APIKeyConstants.h"

@interface AppDelegate ()<BZTabBarControllerDelegate>

@end
//Changes Code upto my changes
@implementation AppDelegate
{
    UIView *progressView;
}
//Bytez working final
@synthesize popView, animation;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [NSThread sleepForTimeInterval:0.7];
    animation = @"NO";
    [[BytezSessionHandler Instance] setTermsAndConditionsStatus:NO];
    [[BytezSessionHandler Instance] setAppTourStatus:NO];
    
    BytezSessionHandler *bytezSessionHandler = [[BytezSessionHandler alloc] init];
    [bytezSessionHandler setFlashOnOffCamera:@"OFF"];
    
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self setInitializeViewController];
    
    //    [self setupViewControllers];
    [self.window makeKeyAndVisible];
    
    [self customizeInterface];
    return YES;
}

-(void)setInitializeViewController
{
    if ([BytezSessionHandler Instance].termsAndConditionsAccepted && [BytezSessionHandler Instance].appTourCompleted) {
        [self setupViewControllers];
        [self.window setRootViewController:self.viewController];
    } else if ([BytezSessionHandler Instance].termsAndConditionsAccepted)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WalkThroughViewController *initalViewController=[sb instantiateViewControllerWithIdentifier:@"WalkThroughViewControllerID"];
        [self.window setRootViewController:initalViewController];
    }
    else
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ViewController *initalViewController=[sb instantiateViewControllerWithIdentifier:@"ViewControllerID"];
        UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                        initWithRootViewController:initalViewController];
        [self.window setRootViewController:secondNavigationController];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark Remote Notification

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);
    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"%@",deviceToken] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//    [alert show];
    
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    //    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [BytezSessionHandler Instance].deviceToken=token;//[[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];;
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:5];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:8];
    NSInteger badgeValue=[[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] integerValue];
    [self updateMyCaveUnreadComment:badgeValue];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "hm.Bytez" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Bytez" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Bytez.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Methods

- (void)setupViewControllers {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController *firstViewController = [sb instantiateViewControllerWithIdentifier:@"HomeViewControllerID"];
    //    [firstViewController setExtendedLayoutIncludesOpaqueBars:YES];
    [firstViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    UIViewController *firstNavigationController = [[RightToLeftNavigationControllerViewController alloc]
                                                   initWithRootViewController:firstViewController];
    firstNavigationController.navigationItem.title=@"sdfjsdlf";
    
    UIViewController *secondViewController = [sb instantiateViewControllerWithIdentifier:@"MyCaveViewControllerID"];
    //    [secondViewController setExtendedLayoutIncludesOpaqueBars:YES];
    [secondViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:secondViewController];
    
    TakeSnapViewController *thirdViewController = [sb instantiateViewControllerWithIdentifier:@"TakeSnapViewControllerID"];
    //    [thirdViewController setExtendedLayoutIncludesOpaqueBars:YES];
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:thirdViewController];
    
    [thirdViewController setHidesBottomBarWhenPushed:YES];
    UIViewController *fourthViewController = [sb instantiateViewControllerWithIdentifier:@"SettingsViewControllerID"];
    //    [fourthViewController setExtendedLayoutIncludesOpaqueBars:YES];
    [fourthViewController setEdgesForExtendedLayout:UIRectEdgeNone];
    UIViewController *fourthNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:fourthViewController];
    
    BZTabBarController *tabBarController = [[BZTabBarController alloc] init];
    tabBarController.delegate=self;
    [tabBarController setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController,fourthNavigationController]];
    self.viewController = tabBarController;
    
    //    [tabBarController setExtendedLayoutIncludesOpaqueBars:YES];
    [tabBarController setEdgesForExtendedLayout:UIRectEdgeNone];
    
    //    [self showProgress];
    [self customizeTabBarForController:tabBarController];
}

-(void)showProgress
{
    [self removeProgress];
    progressView=[[UIView alloc]initWithFrame:self.viewController.view.frame];
    [progressView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    UIActivityIndicatorView *activity=[[UIActivityIndicatorView alloc]init];
    [activity setCenter:CGPointMake(progressView.frame.size.width/2, progressView.frame.size.height/2)];
    
    [activity startAnimating];
    [progressView addSubview:activity];
    [self.viewController.view addSubview:progressView];
}
-(void)showProgressWithoutAnimation
{
    [self removeProgress];
    progressView=[[UIView alloc]initWithFrame:self.viewController.view.frame];
    [progressView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6]];
    [self.viewController.view addSubview:progressView];
}
-(void)removeProgress
{
    [progressView removeFromSuperview];
    progressView=nil;
}

- (void)customizeTabBarForController:(BZTabBarController *)tabBarController {
    
    UIImage *finishedImage = [UIImage imageNamed:@"btn-menu-takesnap-active"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    
    NSArray *tabBarItemImages = @[@"menu-bytez", @"menu-mycave", @"menu-takesnap",@"menu-setting"];
    NSArray *tabBarItemTitle = @[@"Home", @"My Cave", @"Take Snap",@"Settings"];
    
    [[tabBarController tabBar] setHeight:45];
    [[tabBarController tabBar] setBackgroundColor:[UIColor grayColor]];
    
    NSInteger index = 0;
    
    for (BZTabBarItem *item in [[tabBarController tabBar] items]) {
        if (index==1) {
            self.mycaveItem=item;
            NSInteger badgeCount= [UIApplication sharedApplication].applicationIconBadgeNumber;
            if (badgeCount!=0) {
                [self.mycaveItem setBadgeValue:[NSString stringWithFormat:@"%ld",(long)badgeCount]];
            }
        }
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        [item setTitle:[tabBarItemTitle objectAtIndex:index]];
        [item setBadgePositionAdjustment:UIOffsetMake(0.0f, 7.0f)];
        [item setSelectedTitleAttributes:@{
                                           NSFontAttributeName: [UIFont systemFontOfSize:10],
                                           NSForegroundColorAttributeName: [UIColor colorWithRed:234.0/255.0 green:86.0/255.0 blue:92.0/255.0 alpha:1],
                                           }];
        [item setUnselectedTitleAttributes:@{
                                             NSFontAttributeName: [UIFont systemFontOfSize:10],
                                             NSForegroundColorAttributeName: [UIColor blackColor],
                                             }];
        //        [item setBadgeValue:@"200"];
        [item setTitlePositionAdjustment:UIOffsetMake(0, 1)];
        [item setBackgroundColor:[UIColor clearColor]];
        
        index++;
    }
}

- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    UIImage *backgroundImage = nil;
    NSDictionary *textAttributes = nil;
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        backgroundImage = [UIImage imageNamed:@"navigationbar_background_tall"];
        
        textAttributes = @{
                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                           NSForegroundColorAttributeName: [UIColor blackColor],
                           };
    } else {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        backgroundImage = [UIImage imageNamed:@"navigationbar_background"];
        
        textAttributes = @{
                           UITextAttributeFont: [UIFont boldSystemFontOfSize:18],
                           UITextAttributeTextColor: [UIColor blackColor],
                           UITextAttributeTextShadowColor: [UIColor clearColor],
                           UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetZero],
                           };
#endif
    }
    
    [navigationBarAppearance setBackgroundImage:backgroundImage
                                  forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
}


- (BOOL)tabBarController:(BZTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSArray *tabViewControllers = tabBarController.viewControllers;
    UIView * fromView = tabBarController.selectedViewController.view;
    UIView * toView = viewController.view;
    if (fromView == toView)
        return NO;
    NSUInteger toIndex = [tabViewControllers indexOfObject:viewController];
   
        tabBarController.selectedIndex = toIndex;
    
   return true;
}

- (void)tabBarController:(BZTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

-(void)updateMyCaveUnreadComment:(NSUInteger)string{
    
    if (self.mycaveItem==nil) {
        return;
    }
    if (string<=0) {
        [self.mycaveItem setBadgeValue:@""];
    }else
    {
        [self.mycaveItem setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)string]];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:string];
}

-(void)updateMyCaveUnreadCommentAfterDelete:(NSUInteger)deletedImageUnreadCount
{
//    if (self.mycaveItem==nil) {
//        return;
//    }
//    NSUInteger badgeCount = [self.mycaveItem.badgeValue integerValue] - deletedImageUnreadCount;
//    if (badgeCount <= 0) {
//        badgeCount=0;
//    }
//    [self.mycaveItem setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)badgeCount]];
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeCount];
}

@end
