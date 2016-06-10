//
//  BZTabbarItem.h
//  Bytez
//
//  Created by HMSPL on 26/12/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BZTabBarItem : UIControl

@property CGFloat itemHeight;

#pragma mark - Title configuration

@property (nonatomic, copy) NSString *title;

@property (nonatomic) UIOffset titlePositionAdjustment;

@property (copy) NSDictionary *unselectedTitleAttributes;

@property (copy) NSDictionary *selectedTitleAttributes;

#pragma mark - Image configuration

@property (nonatomic) UIOffset imagePositionAdjustment;

- (UIImage *)finishedSelectedImage;

- (UIImage *)finishedUnselectedImage;

- (void)setFinishedSelectedImage:(UIImage *)selectedImage withFinishedUnselectedImage:(UIImage *)unselectedImage;

#pragma mark - Background configuration

- (UIImage *)backgroundSelectedImage;

- (UIImage *)backgroundUnselectedImage;

- (void)setBackgroundSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage;

@property (nonatomic, copy) NSString *badgeValue;

@property (strong) UIImage *badgeBackgroundImage;

@property (strong) UIColor *badgeBackgroundColor;

@property (strong) UIColor *badgeTextColor;

@property (nonatomic) UIOffset badgePositionAdjustment;

@property (nonatomic) UIFont *badgeTextFont;


@end
