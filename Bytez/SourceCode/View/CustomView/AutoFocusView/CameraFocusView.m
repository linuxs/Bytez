//
//  CameraFocusView.m
//  Bytez
//
//  Created by Jeyaraj on 16/03/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "CameraFocusView.h"
#import "AppDelegate.h"

@implementation CameraFocusView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
     
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        // Initialization code
        NSLog(@"%@",appDelegate.animation);
#if 0
        if(frame.size.width == 81 && [appDelegate.animation isEqualToString:@"NO"]) {
            
        [self setBackgroundColor:[UIColor clearColor]];
        [self.layer setBorderWidth:2.0];
        [self.layer setCornerRadius:4.0];
        [self.layer setBorderColor:[UIColor clearColor].CGColor];
        UIImageView *viewImg = [[UIImageView alloc] initWithFrame:CGRectMake(-40,-40, 120, 120)];
            viewImg.image = [UIImage imageNamed:@"focus.png"];
            [self addSubview:viewImg];
        
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            // Set the initial and the final values
            [pathAnimation setFromValue:[NSNumber numberWithFloat:2.0f]];
            [pathAnimation setToValue:[NSNumber numberWithFloat:0.9f]];
            pathAnimation.delegate = self;
            [pathAnimation setDuration:0.5f];
            //pathAnimation.autoreverses = YES;
            [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [viewImg.layer addAnimation:pathAnimation
                          forKey:@"changePathAnimation"];
            appDelegate.animation = @"YES";
        
        } else
#endif
        {
        
        int radius = 17;
        CGPoint drawPoint =  CGPointMake(self.frame.size.width/2 - 40,self.frame.size.height/2 -40);
        CAShapeLayer *circle = [CAShapeLayer layer];
        // Make a circular shape
        circle.path = [UIBezierPath bezierPathWithArcCenter:drawPoint radius:radius startAngle:0 endAngle:M_PI*2 clockwise:NO].CGPath;
        // Configure the apperence of the circle
        UIColor *pointColor =[UIColor alloc];
        pointColor = [UIColor clearColor];
        circle.fillColor = pointColor.CGColor;
        circle.strokeColor = [UIColor whiteColor].CGColor;
        circle.lineWidth = 4;
        circle.path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radius startAngle:0 endAngle:M_PI*2 clockwise:NO].CGPath;
        circle.position = drawPoint;
        [self.layer addSublayer:circle];
        
        // Add to parent layer
        
        int radius2 = 30;
       CGPoint drawPoint2 = CGPointMake(self.frame.size.width/2 - 40,self.frame.size.height/2 - 40);
        //CGPointMake(self.frame.origin.x,self.frame.origin.y);
        CAShapeLayer *circle2 = [CAShapeLayer layer];
        // Make a circular shape
        circle2.path = [UIBezierPath bezierPathWithArcCenter:drawPoint radius:radius2 startAngle:0 endAngle:M_PI*2 clockwise:NO].CGPath;
        // Configure the apperence of the circle
        UIColor *pointColor2 =[UIColor alloc];
        pointColor2 = [UIColor clearColor];
        circle2.fillColor = pointColor2.CGColor;
        circle2.strokeColor = [UIColor whiteColor].CGColor;
        circle2.lineWidth = 1;
        circle2.path = [UIBezierPath bezierPathWithArcCenter:CGPointZero radius:radius2 startAngle:0 endAngle:M_PI*2 clockwise:NO].CGPath;
        circle2.position = drawPoint2;
        // Add to parent layer
        [self.layer addSublayer:circle2];
        // Configure animation
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        // Set the initial and the final values
        [pathAnimation setFromValue:[NSNumber numberWithFloat:1.0f]];
        [pathAnimation setToValue:[NSNumber numberWithFloat:1.1f]];
        [pathAnimation setDuration:0.2f];
        [pathAnimation setRepeatCount:4.0f];
        pathAnimation.autoreverses = YES;
        [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [circle2 addAnimation:pathAnimation forKey:@"changePathAnimation"];
        
        }
    }
    return self;
}

@end
