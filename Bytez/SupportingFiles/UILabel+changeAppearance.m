//
//  UILabel+changeAppearance.m
//  AlertViewController
//
//  Created by OBS_Macmini on 8/20/15.
//  Copyright (c) 2015 OptisolBusinessSolutions. All rights reserved.
//

#import "UILabel+changeAppearance.h"

@implementation UILabel (changeAppearance)
-(void)setAppearanceFont:(UIFont *)font {
    if (font)
        [self setFont:font];
}

-(UIFont *)appearanceFont {
    
    return self.font;
}

@end
