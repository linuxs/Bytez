//
//  BZTabbar.h
//  Bytez
//
//  Created by HMSPL on 26/12/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BZTabBar, BZTabBarItem;

@protocol BZTabBarDelegate <NSObject>

- (BOOL)tabBar:(BZTabBar *)tabBar shouldSelectItemAtIndex:(NSInteger)index;

- (void)tabBar:(BZTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index;

@end

@interface BZTabBar : UIView

@property (nonatomic, weak) id <BZTabBarDelegate> delegate;

@property (nonatomic, copy) NSArray *items;

@property (nonatomic, weak) BZTabBarItem *selectedItem;

@property (nonatomic, readonly) UIView *backgroundView;

@property UIEdgeInsets contentEdgeInsets;

- (void)setHeight:(CGFloat)height;

- (CGFloat)minimumContentHeight;

@property (nonatomic, getter=isTranslucent) BOOL translucent;

@end
