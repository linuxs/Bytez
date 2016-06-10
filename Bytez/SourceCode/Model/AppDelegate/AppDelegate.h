//
//  AppDelegate.h
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "BZTabBarController.h"
#import "UIActivityIndicatorView+AFNetworking.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *popView;
@property (strong, nonatomic) NSString *animation;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (assign,nonatomic) BOOL isImagePosted;
@property NSString* push;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

-(void)showProgress;
-(void)showProgressWithoutAnimation;
-(void)removeProgress;
-(void)setInitializeViewController;
-(void)updateMyCaveUnreadComment:(NSUInteger)string;
-(void)updateMyCaveUnreadCommentAfterDelete:(NSUInteger)deletedImageUnreadCount;

@property (strong, nonatomic) BZTabBarController *viewController;
@property (strong, nonatomic) BZTabBarItem *mycaveItem;



@end

