//
//  CameraOverLayView.m
//  Bytez
//
//  Created by HMSPL on 07/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "CameraOverLayView.h"

@implementation CameraOverLayView
{
    __weak IBOutlet NSLayoutConstraint *constraintTopViewVertica;
    __weak IBOutlet UIView *viewFooter;
    __weak IBOutlet UIView *viewHeader;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"CameraOverLayView" owner:self options:nil];
        self = [nibViews objectAtIndex:0];
    }
    return self;
}
-(instancetype)init
{
    self = [super init];
    if (self)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"CameraOverLayView" owner:self options:nil];
        self = [nibViews objectAtIndex:0];
    }
    return self;
    
}
-(void)startAnimating:(BOOL)isShown
{
    constraintTopViewVertica.constant-=viewHeader.frame.size.height;
    [viewHeader setNeedsUpdateConstraints];
    [viewHeader layoutIfNeeded];
    
    constraintTopViewVertica.constant=0;
    [UIView animateWithDuration:0.5 animations:^{
        [viewHeader layoutIfNeeded];
        [viewHeader layoutIfNeeded];
    }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
