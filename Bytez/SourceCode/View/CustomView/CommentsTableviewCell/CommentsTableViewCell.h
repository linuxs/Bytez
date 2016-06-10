//
//  CommentsTableViewCell.h
//  Bytez
//
//  Created by HMSPL on 16/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsTableViewCell : UITableViewCell<UITextViewDelegate>
//@property (weak, nonatomic) IBOutlet UILabel *lblComment;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCommentIcon;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (strong, nonatomic) IBOutlet UITextView *lblCommentTxt;
@end
