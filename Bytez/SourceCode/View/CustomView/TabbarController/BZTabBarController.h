//
//  BZTabbarcontrollerViewController.h
//  Bytez
//
//  Created by HMSPL on 26/12/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BZTabBar.h"

@protocol BZTabBarControllerDelegate;

@interface BZTabBarController : UIViewController <BZTabBarDelegate>

@property (nonatomic, weak) id<BZTabBarControllerDelegate> delegate;

@property (nonatomic, copy) IBOutletCollection(UIViewController) NSArray *viewControllers;

@property (nonatomic, readonly) BZTabBar *tabBar;

@property (nonatomic, weak) UIViewController *selectedViewController;

@property (nonatomic) NSUInteger selectedIndex;

@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end

@protocol BZTabBarControllerDelegate <NSObject>
@optional

- (BOOL)tabBarController:(BZTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController;

- (void)tabBarController:(BZTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController;

@end

@interface UIViewController (BZTabBarControllerItem)

@property(nonatomic, setter = bz_setTabBarItem:) BZTabBarItem *bz_tabBarItem;

@property(nonatomic, readonly) BZTabBarController *bz_tabBarController;

@end