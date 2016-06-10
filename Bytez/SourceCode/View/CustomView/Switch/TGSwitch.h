//
//  TGSwitch.h
//  TGSwitch
//
//  Created by hakuna on 22/08/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TGSwitch : UIControl

@property (nonatomic) BOOL on;
@property (nonatomic) UIColor *bgColor;
@property (nonatomic) UIColor *knobColor;
@property (nonatomic) NSString *onText;
@property (nonatomic) NSString *offText;

@end
