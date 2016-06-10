//
//  NoFeedView.m
//  Bytez
//
//  Created by HMSPL on 02/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "NoFeedView.h"

@implementation NoFeedView
{
    __weak IBOutlet UILabel *lblPostCool;
    __weak IBOutlet UILabel *lblPicInYourArea;
    __weak IBOutlet UIImageView *imgViewLogo;
    __weak IBOutlet UILabel *lblShare;
    __weak IBOutlet UIImageView *imgViewArrow;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"NoFeedView" owner:self options:nil];
        self = [nibViews objectAtIndex:0];
    }
    return self;
}
-(void)startAnimating
{
    
}

@end
