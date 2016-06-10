//
//  TGKnobLayer.m
//  TGSwitch
//
//  Created by hakuna on 22/08/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//

#import "TGKnobLayer.h"
#import "TGSwitch.h"

@implementation TGKnobLayer

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSetFillColorWithColor(ctx, self.tgSwitch.knobColor.CGColor);
    
    if (self.highlighted)
    {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.0 alpha:0.1].CGColor);
    }
}

@end
