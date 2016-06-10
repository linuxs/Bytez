//
//  RecentImageTableViewCell.h
//  Bytez
//
//  Created by HMSPL on 02/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResponseImageDTO.h"
#import "AspectFillImageView.h"

@interface RecentImageTableViewCell : UITableViewCell{
    //__weak IBOutlet NSLayoutConstraint *constaraintCommentWidth;

}
@property(weak,nonatomic)IBOutlet NSLayoutConstraint *constaraintCommentWidth;
@property (weak, nonatomic) IBOutlet AspectFillImageView *imgViewRecentPostedImage;
//@property (weak, nonatomic) IBOutlet UIImageView *imgViewRecentPostedImage;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeCount;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewLikeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewMyImage;
@property (strong,nonatomic) ResponseImageDTO *cellData;

@property (weak, nonatomic) IBOutlet UIButton *btnReportImage;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;

@end
