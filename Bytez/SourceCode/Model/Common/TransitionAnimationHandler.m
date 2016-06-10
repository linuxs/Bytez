//
//  TransitionAnimationHandler.m
//  Bytez
//
//  Created by HMSPL on 05/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "TransitionAnimationHandler.h"
#import "AppDelegate.h"

@implementation TransitionAnimationHandler
{
    AppDelegate *appdelegate;
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.40;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect fromVCFrame = fromViewController.view.frame;
    CGRect toVCFrame = toViewController.view.frame;
    
    CGFloat widthMinus, widthPlus;
    CGFloat width = toViewController.view.frame.size.width;
    [[transitionContext containerView] addSubview:toViewController.view];
    
    if([appdelegate.push isEqualToString:@"YES"]) {
        
        widthMinus = -width;
        widthPlus  = width;
    } else {
        
        widthMinus = width;
        widthPlus  = 0;
    }
    toViewController.view.frame = CGRectOffset(fromVCFrame, widthMinus, 0);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.frame = CGRectOffset(fromVCFrame, widthPlus, 0);
        toViewController.view.frame = fromVCFrame;
    } completion:^(BOOL finished) {
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        fromViewController.view.frame = fromVCFrame;
        toViewController .view.frame  = toVCFrame;
    }];
}


@end
