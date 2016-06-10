//
//  TGTrackLayer.m
//  TGSwitch
//
//  Created by hakuna on 22/08/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//

#import "TGTrackLayer.h"
#import "TGSwitch.h"

@implementation TGTrackLayer

- (void)drawInContext:(CGContextRef)ctx
{
    float cornerRadius = 0;
    UIBezierPath *switchOutline = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                             cornerRadius:cornerRadius];
	CGContextAddPath(ctx, switchOutline.CGPath);
    CGContextClip(ctx);
    
    CGContextSetFillColorWithColor(ctx, self.tgSwitch.bgColor.CGColor);
}


@end
