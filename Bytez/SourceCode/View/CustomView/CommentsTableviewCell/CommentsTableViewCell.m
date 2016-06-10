//
//  CommentsTableViewCell.m
//  Bytez
//
//  Created by HMSPL on 16/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "CommentsTableViewCell.h"
#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@implementation CommentsTableViewCell
{
    UIButton *customEditBtn;
}
- (void)awakeFromNib {
    // Initialization code
}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [self.lblCommentTxt setTextColor:[UIColor blackColor]];
    } else {
        [self.lblCommentTxt setTextColor:[UIColor whiteColor]];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
   
    // Configure the view for the selected state
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return;
    }
    
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) {
            
            UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
            for (UIView *innerView in [deleteButtonView subviews]) {
                if (innerView.tag==25) {
                    return;
                }
            }
            UIImageView *subView2=[[UIImageView alloc]initWithFrame:deleteButtonView.frame];
            subView2.backgroundColor=[UIColor blackColor];
            
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_swipe_delete.png"]];
            image.frame=CGRectMake(5, self.frame.size.height/2-14, 80, 35);
            image.tag=25;
            [deleteButtonView addSubview:subView2];
            [deleteButtonView addSubview:image];
            return;
        }
    }
}
-(void)willTransitionToState:(UITableViewCellStateMask)state{
    NSLog(@"EventTableCell willTransitionToState");
    [super willTransitionToState:state];
    if((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask && SYSTEM_VERSION_LESS_THAN(@"8.0")){
        [self recurseAndReplaceSubViewIfDeleteConfirmationControl:self.subviews];
        [self performSelector:@selector(recurseAndReplaceSubViewIfDeleteConfirmationControl:) withObject:self.subviews afterDelay:0];
    }
}
-(void)recurseAndReplaceSubViewIfDeleteConfirmationControl:(NSArray*)subviews{
    for (UIView *subview in subviews)
    {
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationButton"])
        {
            UIView *deleteButtonView = (UIView *)[subview.subviews objectAtIndex:0];
            [deleteButtonView setBackgroundColor:[UIColor clearColor]];
            if ([deleteButtonView isKindOfClass:[UILabel class]]) {
                UILabel *lbl=(UILabel*)deleteButtonView;
                [lbl setText:@""];
            }
            for (UIView *innerView in [deleteButtonView subviews]) {
                if (innerView.tag==25) {
                    return;
                }
            }
            UIImageView *subView2=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, deleteButtonView.superview.frame.size.width, deleteButtonView.superview.frame.size.height)];
            subView2.backgroundColor=[UIColor blackColor];
            //UIImageView *image1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Donald-duck.png"]];
            
            UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_swipe_delete.png"]];
            image.frame=CGRectMake(0, self.frame.size.height/2-14, 80, 35);
            image.tag=25;
            //[deleteButtonView addSubview:image1];
            [deleteButtonView.superview addSubview:subView2];
            [deleteButtonView.superview addSubview:image];
            return;
        }
        if([subview.subviews count]>0){
            [self recurseAndReplaceSubViewIfDeleteConfirmationControl:subview.subviews];
        }
        
    }
}
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
}
@end
