//
//  RecentImageTableViewCell.m
//  Bytez
//
//  Created by HMSPL on 02/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "RecentImageTableViewCell.h"
#import "APIKeyConstants.h"
#import "RegisterDeviceHandler.h"
#import "UIImageView+AFNetworking.h"

@implementation RecentImageTableViewCell
{
    __weak IBOutlet UIView *viewFooter;

    __weak IBOutlet UIImageView *imgViewSonarEffect;
    __weak IBOutlet UILabel *lblTimePeriod;
    __weak IBOutlet UIImageView *imgViewIconImage;
    __weak IBOutlet UILabel *lblCaption;
    __weak IBOutlet UIView *viewCaptionView;
    
    NSUInteger comment;
}
- (void)awakeFromNib {
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellData:(ResponseImageDTO *)cellData
{
    [viewFooter setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4]];
    [lblTimePeriod setText:cellData.postedTime];
    [imgViewIconImage setImage:[UIImage imageNamed:@"icon-timestamp.png"]];
    [self.lblLikeCount setText:[NSString stringWithFormat:@"%ld",cellData.numberOfLikes]];
    
    if ([cellData.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_FALSE]) {
        [self.imgViewLikeIcon setImage:[UIImage imageNamed:@"icon-byte-like.png"]];
    }
    else
    {
        [self.imgViewLikeIcon setImage:[UIImage imageNamed:@"icon-byte-unlike.png"]];
    }
    comment=cellData.numberOfComments;
    if (cellData.numberOfComments==0) {
        
    }
    [viewCaptionView setHidden:YES];
    if (![cellData.imageDescription isKindOfClass:[NSNull class]]) {
        if ([cellData.imageDescription isEqualToString:@""]) {
            [viewCaptionView setHidden:YES];
        }
        else
        {
            [viewCaptionView setHidden:NO];
            [viewCaptionView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
            viewCaptionView.layer.shadowOpacity=1.2f;
            NSString *descriptionVal=cellData.imageDescription;
            NSData *data = [descriptionVal dataUsingEncoding:NSUTF8StringEncoding];
            //NSLog(@"---->%@",data);
            descriptionVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            NSString *empty=@"";
            NSString *appendString=[descriptionVal stringByAppendingString:empty];
            [lblCaption setText:appendString];
        }
    }
    if (cellData.userId == [[RegisterDeviceHandler getRegisteredUserId] longLongValue]) {
        [self.imgViewMyImage setHidden:NO];
    }else
    {
        [self.imgViewMyImage setHidden:YES];
    }
    [self layoutIfNeeded];
    
    [self.imgViewRecentPostedImage setAlignTop:YES];
}
- (IBAction)btnCommentAction:(id)sender {
    [imgViewSonarEffect setHidden:NO];
    NSMutableArray *imagelist=[[NSMutableArray alloc]init];
    for (int i=1;i<6;i++) {
        UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"swipe_effect%d.png",i]];
        [imagelist addObject:image];
    }
    [imgViewSonarEffect setAnimationImages:imagelist];
    [imgViewSonarEffect setAnimationRepeatCount:3];
    [imgViewSonarEffect setAnimationDuration:0.5];
    [imgViewSonarEffect startAnimating];
//    [imgViewSonarEffect startAnimating];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self didTransitionToState:UITableViewCellStateDefaultMask];
}
@end
