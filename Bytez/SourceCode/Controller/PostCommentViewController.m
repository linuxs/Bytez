//
//  PostCommentViewController.m
//  Bytez
//
//  Created by HMSPL on 05/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "PostCommentViewController.h"
#import "PostCommentModel.h"
#import "CommentsDTO.h"
#import "URLConstants.h"
#import "StringConstants.h"
#import "APIKeyConstants.h"
#import "RegisterDeviceHandler.h"
#import "ReportImagePopover.h"
#import "AppDelegate.h"
#import "BytezSessionHandler.h"
#import "UIImageView+AFNetworking.h"
#import "CommentsTableViewCell.h"
#import "NSString+RemoveEmoji.h"
typedef void (^CommentPostedHandler)(NSUInteger,NSUInteger,bool);

@interface PostCommentViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,PostCommentModelDelegate,UITextViewDelegate,UIGestureRecognizerDelegate>
{
    BOOL isEmoji;
    NSString *descriptionVal;
    NSInteger desInt;
}
@end

@implementation PostCommentViewController
{
    __weak IBOutlet UITextView *txtViewComment;
    __weak IBOutlet UITableView *tblViewComments;
    
    __weak IBOutlet UILabel *lblLocationOrTime;
    __weak IBOutlet UILabel *lblLikeCount;
    __weak IBOutlet UILabel *lblImageCaption;
    __weak IBOutlet UILabel *lblToastMessage;
    
    __weak IBOutlet UIButton *iconCommentButton;
    __weak IBOutlet UIImageView *imgViewLocationOrTimeIcon;
    __weak IBOutlet UIImageView *imgViewLikeImage;
    __weak IBOutlet UIImageView *imgViewPostedImage;
    __weak IBOutlet UIImageView *imgViewCommentIcon;
    __weak IBOutlet UIImageView *imgViewBytezIcon;
    
    __weak IBOutlet UIView *viewToastMessage;
    __weak IBOutlet UIView *viewTextViewHolder;
    __weak IBOutlet UIView *viewAddCaption;
    
    __weak IBOutlet NSLayoutConstraint *constraintTextViewTop;
    __weak IBOutlet NSLayoutConstraint *constraintToastMsgHeight;
    __weak IBOutlet NSLayoutConstraint *constraintContentViewHeight;
    __weak IBOutlet NSLayoutConstraint *constraintOriginalImageHeight;
    
    __weak IBOutlet UIImageView *iconComment;
    __weak IBOutlet NSLayoutConstraint *iconByteValueLblConstrain;
    
    __weak IBOutlet UIButton *btnReportImage;
    __weak IBOutlet UIScrollView *scrollView;
    
    __weak IBOutlet NSLayoutConstraint *ConstraintCommentIcon;

    
    CommentPostedHandler _handler;
    PostCommentModel *postCommentModel;
    ReportImagePopover *reportPopover;
    
    NSUInteger tableViewHeight;
    
    UITableView *reportTableView;
    NSArray *reportReasonArray;
    NSArray *commentsList;
    int indexPathToDel;
    
    BOOL isImageReported, pop, isLiked;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    viewToastMessage.layer.cornerRadius=5.0f;
    postCommentModel=[[PostCommentModel alloc]init];
    [postCommentModel setReportCount:self.imageDetails.spamReport];
    [postCommentModel setDelegate:self];
    
    [BytezSessionHandler Instance].LikedImageId=-1;
    
    constraintOriginalImageHeight.constant=self.view.frame.size.width;
    
    commentsList=[[NSArray alloc]init];
    
    if (self.commentsResponse==nil) {
        self.commentsResponse=[[NSMutableArray alloc]init];
        [postCommentModel getImageCommentsForImage:[NSString stringWithFormat:@"%ld",(long)self.imageDetails.imageId]];
    }
    
    [tblViewComments setDelegate:self];
    [tblViewComments setDataSource:self];
    tblViewComments.allowsMultipleSelectionDuringEditing=NO;
    
    [txtViewComment setDelegate:self];
    [txtViewComment setText:CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER];
    //[txtViewComment setKeyboardType:UIKeyboardTypeASCIICapable];
    [txtViewComment setKeyboardType:UIKeyboardTypeDefault];
    NSString *imageUrl=[NSString stringWithFormat:@"%@/%@",URL_IMAGEPATH,self.imageDetails.imageName];
    NSLog(@"Image Url=%@",imageUrl);
    imageUrl=[imageUrl stringByReplacingOccurrencesOfString:@"small" withString:@"original"];//medium
    [imgViewPostedImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    
    [btnReportImage setTag:self.imageDetails.imageId];
    [imgViewLocationOrTimeIcon setImage:[UIImage imageNamed:self.imageDetails.displayImage]];
    [lblLocationOrTime setText:self.imageDetails.displayText];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(likeImage:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate=self;
    [imgViewPostedImage setUserInteractionEnabled:YES];
    [imgViewPostedImage addGestureRecognizer:doubleTap];
    
    
    UITapGestureRecognizer *singleTapLike = [[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(likeImage:)];
    singleTapLike.numberOfTapsRequired = 1;
    singleTapLike.delegate=self;
    [imgViewBytezIcon setUserInteractionEnabled:YES];
    [imgViewBytezIcon addGestureRecognizer:singleTapLike];
    
    
    if ([self.imageDetails.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_FALSE]) {
        isLiked = false;
        [imgViewLikeImage setImage:[UIImage imageNamed:@"icon-byte-like.png"]];
        
    }
    else{
        isLiked=true;
        [imgViewLikeImage setImage:[UIImage imageNamed:@"icon-byte-unlike.png"]];
    }
    
    if (self.imageDetails.isReportedByMe) {
        [btnReportImage setImage:[UIImage imageNamed:@"icon-report.png"] forState:UIControlStateNormal];
        [btnReportImage setUserInteractionEnabled:NO];
    }else
    {
        [btnReportImage setImage:[UIImage imageNamed:@"report_grey.png"] forState:UIControlStateNormal];
        [btnReportImage setUserInteractionEnabled:YES];
    }
    
    [lblLikeCount setText:[NSString stringWithFormat:@"%ld",self.imageDetails.numberOfLikes]];
    
    if (self.isFromHomeFeed) {
        UISwipeGestureRecognizer *leftRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popViewController:)];
        [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [self.view addGestureRecognizer:leftRecognizer];
        
    }else
    {
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            
            UISwipeGestureRecognizer *leftRecognizer= [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popViewController:)];
            [leftRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
            [self.view addGestureRecognizer:leftRecognizer];
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.popView = @"YES";

#if 0
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            self.navigationController.interactivePopGestureRecognizer.delegate=self;
#endif
        }
    }
    
    reportTableView = [[UITableView alloc] init];
    reportTableView.frame = CGRectMake(0, 0, 160, 120);
    reportTableView.rowHeight=30.0f;
    reportTableView.dataSource = self;
    reportTableView.delegate = self;
    
    reportReasonArray = @[@"Spam/Advertisement", @"Violent/Threatening", @"Nudity/Inappropriate", @"Just not feeling it"];
    [viewAddCaption setHidden:YES];
       if (![self.imageDetails.imageDescription isKindOfClass:[NSNull class]]) {
        if ([self.imageDetails.imageDescription isEqualToString:@""]) {
            [viewAddCaption setHidden:YES];
        }
        else
        {
            [viewAddCaption setHidden:NO];
            [viewAddCaption setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
            viewAddCaption.layer.shadowOpacity=1.2f;
   
            //Post Comments changes in emoji
            descriptionVal=self.imageDetails.imageDescription;
            NSData *data = [descriptionVal dataUsingEncoding:NSUTF8StringEncoding];
            descriptionVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            [lblImageCaption setText:descriptionVal];
        }
    }
    
    UITapGestureRecognizer *tabGest = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(tapgesture)];
    tabGest.delegate=self;
    tabGest.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:tabGest];
   // txtViewComment.autocorrectionType = UITextAutocorrectionTypeDefault;
      txtViewComment.autocorrectionType = UITextAutocorrectionTypeYes;
}
- (void)tapgesture {
    
    [txtViewComment resignFirstResponder];
    if (reportPopover!=nil) {
        [reportPopover dismiss];
        reportPopover = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSLog(@"%@",appDelegate.popView);
    if([appDelegate.popView isEqualToString:@"NO"])
        [self navigateToHome];
    
    [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(pop == NO)
       appDelegate.popView = @"NO";
        
    [self unregisterForKeyboardNotifications];
}

-(void)popViewController:(id)sender
{
    if (_handler!=nil) {
        _handler(self.imageDetails.imageId,self.commentsResponse.count,isImageReported);
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.popView = @"YES";
    pop = YES;
    
    self.imageDetails.spamReport=postCommentModel.reportCount;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)likeImage:(id)sender
{
    [txtViewComment resignFirstResponder];
    [postCommentModel likeImageWithImageID:self.imageDetails.imageId];
}

-(void)commentPostedHandler:(void (^)(NSUInteger,NSUInteger,bool))handler
{
    _handler=handler;
}

#pragma mark Post commentDelegate

-(void)showSuccessAlertWithMessage:(NSString *)message
{
    self.imageDetails.spamReport++;
    
    [btnReportImage setUserInteractionEnabled:NO];
    [btnReportImage setImage:[UIImage imageNamed:@"icon-report.png"] forState:UIControlStateNormal];
    
    isImageReported=YES;
    
    [self showToastMessage:message];
}
-(void)showToastMessage :(NSString*)message
{
    [lblToastMessage setText:message];
    [UIView animateWithDuration:0.5f animations:^{
        constraintToastMsgHeight.constant=40;
        [self.view layoutIfNeeded];
    }];
    [self performSelector:@selector(hideToastMessage) withObject:self afterDelay:1.5f];
}

-(void)hideToastMessage
{
    constraintToastMsgHeight.constant=0;
    [UIView animateWithDuration:1 animations:^{
        [viewToastMessage layoutIfNeeded];
    }];
}

-(void)showFailureAlertWithMessage:(NSString *)message
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeProgress];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:message message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

-(void)updateLikeImage
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setDuration:2.0f];
    [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
    [animation setType:@"rippleEffect" ];
    [imgViewPostedImage.layer addAnimation:animation forKey:NULL];
    
    if (isLiked) {
                self.imageDetails.Liked = API_RESPONSE_VALUE_LIKE_FALSE;
        isLiked = false;
        
//        if ([self.imageDetails.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_FALSE]) {
//            [BytezSessionHandler Instance].newLikeCountInComments=0;
//        }else
//        {
        
//        }
        
        self.imageDetails.numberOfLikes--;
        [imgViewLikeImage setImage:[UIImage imageNamed:@"icon-byte-like.png"]];
        [lblLikeCount setText:[NSString stringWithFormat:@"%ld",self.imageDetails.numberOfLikes]];
    }
    else
    {
        isLiked = true;
        self.imageDetails.Liked = API_RESPONSE_VALUE_LIKE_TRUE ;
        self.imageDetails.numberOfLikes++;
        [imgViewLikeImage setImage:[UIImage imageNamed:@"icon-byte-unlike.png"]];
        [lblLikeCount setText:[NSString stringWithFormat:@"%ld",self.imageDetails.numberOfLikes]];
//        if ([self.imageDetails.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_TRUE]) {
//            [BytezSessionHandler Instance].newLikeCountInComments=0;
//        }else
//        {
//            [BytezSessionHandler Instance].newLikeCountInComments=1;
//        }
    }
    
    
    [BytezSessionHandler Instance].likedCountInComments = self.imageDetails;
    [BytezSessionHandler Instance].LikedImageId=self.imageDetails.imageId;
}

-(void)navigateToHome
{
    if (_handler!=nil) {
        _handler(self.imageDetails.imageId,self.commentsResponse.count,isImageReported);
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeProgress];
    self.imageDetails.spamReport=postCommentModel.reportCount;
    
    appDelegate.popView = @"YES";
    pop = YES;
    [self.navigationController popViewControllerAnimated:YES];
    

}

-(void)refreshCommentList
{
    if (![txtViewComment.text isEqualToString:CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER]) {
        [txtViewComment setText:@""];
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate removeProgress];
    if ([postCommentModel.listOfComments count]>0) {
        self.commentsResponse=postCommentModel.listOfComments;
        //        constraintContentViewHeight.constant=320;
        tableViewHeight=0;
    }
    [tblViewComments reloadData];
}


#pragma mark Button Action

- (IBAction)btnReportImageAction:(id)sender {
    
    [txtViewComment resignFirstResponder];
    UIButton *reportButton=(UIButton*)sender;
    CGPoint startPoint = [self.view convertPoint:CGPointZero fromView:reportButton];
    startPoint.x+=10;
    reportTableView.tag=reportButton.tag;
    
    if (reportPopover==nil) {
        reportPopover=[ReportImagePopover new];
    }
    float possiblepopoverHeight=self.view.frame.size.height-startPoint.y;
    if (possiblepopoverHeight<150) {
        [reportPopover showAtPoint:startPoint popoverPostion:ReportImagePopoverPositionUp withContentView:reportTableView inView:self.view];
    }else{
        startPoint.y+=25;
        [reportPopover showAtPoint:startPoint popoverPostion:ReportImagePopoverPositionDown withContentView:reportTableView inView:self.view];
    }
}


#pragma mark TableView delegate and Data source methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:reportTableView]) {
        NSString *cellId = @"cellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.textLabel.text = reportReasonArray[indexPath.row];
        [cell.textLabel setFont:[UIFont systemFontOfSize:11.0f]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        return cell;
    }
    static NSString *simpleTableIdentifier = @"CommentsTableViewCell";
    CommentsTableViewCell *cell;
    cell= (CommentsTableViewCell *)[tblViewComments dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentsTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        //cell.lblCommentTxt.textColor = [UIColor whiteColor];
        //cell.lblComment.numberOfLines =0;
        //cell.lblComment.lineBreakMode = NSLineBreakByWordWrapping;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    CommentsDTO *commentResponse= [self.commentsResponse objectAtIndex:indexPath.row];
    [cell setTag:commentResponse.commentId];
       //Post Comments changes in emoji
    descriptionVal=commentResponse.comment;
    NSData *data =[descriptionVal dataUsingEncoding:NSUTF8StringEncoding];
   descriptionVal = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];//NSNonLossyASCIIStringEncoding
    //NSData *data =[descriptionVal dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    //descriptionVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [cell.lblCommentTxt setText:descriptionVal];
    NSLog(@"----E%@",descriptionVal);
    NSLog(@"---%@",commentResponse.comment);

    NSString *userId=[NSString stringWithFormat:@"%ld",commentResponse.userId];
    
    if ([userId isEqualToString:[RegisterDeviceHandler getRegisteredUserId]]) {
        [cell.imgViewCommentIcon setImage:[UIImage imageNamed:@"myCommentIcon.png"]];
        cell.tag=21;
    }
    else
    {
        [cell.imgViewCommentIcon setImage:[UIImage imageNamed:@"commentsmallicon.png"]];
        cell.tag=1;
    }
    [cell updateConstraintsIfNeeded];
    [cell layoutIfNeeded];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:reportTableView]) {
        return 50;
    }
    if (indexPath.row==0){
        tableViewHeight=0;
    }

    CommentsDTO *commentResponse= [self.commentsResponse objectAtIndex:indexPath.row];
    UIFont *labelFont = [UIFont fontWithName:@"GillSans" size:13];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:labelFont,
                              NSFontAttributeName,
                              paragraphStyle,
                              NSParagraphStyleAttributeName,
                              nil];
    CGRect lblRect = [commentResponse.comment boundingRectWithSize:(CGSize) {225, MAXFLOAT}//225
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:attrDict
                                                           context:nil];
    CGRect singleRowRect = [@"hello" boundingRectWithSize:(CGSize){225, MAXFLOAT}//225
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attrDict
                                                  context:nil];
//     desInt=[temp integerValue];
   
    NSData *newdata=[commentResponse.comment dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *mystring=[[NSString alloc] initWithData:newdata encoding:NSNonLossyASCIIStringEncoding];
    
    double lines=lblRect.size.height/singleRowRect.size.height;
    NSLog(@"lines %f",lines);
    BOOL isEmo=[self stringContainsEmoji:mystring];
    if (isEmo) {
        NSLog(@"yes");
        commentResponse.commentHeight=0;
        switch ((int)lines) {
            case 1:
                commentResponse.commentHeight= 50;
                break;
            case 2:
                commentResponse.commentHeight= 50;
                break;
            case 3:
                commentResponse.commentHeight= 70;
                break;
            case 4:
                commentResponse.commentHeight= 70;
                break;
            case 5:
                commentResponse.commentHeight= 70;
                break;
            case 6:
                commentResponse.commentHeight= 70;
                break;
            case 7:
                commentResponse.commentHeight= 70;
                break;
            default:
                commentResponse.commentHeight= 200;
                break;
        }

    }else{
        NSLog(@"no");
        commentResponse.commentHeight=0;
        commentResponse.commentHeight=32+lines*12;

    }
    tableViewHeight+=commentResponse.commentHeight;
    if (indexPath.row==[self.commentsResponse count]-1) {
        constraintContentViewHeight.constant=300 +tableViewHeight+imgViewPostedImage.frame.size.height;
    }
    return commentResponse.commentHeight;

//    if ([commentResponse.comment  length]) {
//        commentResponse.commentHeight=32+lines*12;
//        tableViewHeight+=commentResponse.commentHeight;
//
//    }else{
//        desInt=0;
//       tableViewHeight+=desInt;
//    }
//    if (indexPath.row==[self.commentsResponse count]-1) {
//        constraintContentViewHeight.constant=90 +tableViewHeight+imgViewPostedImage.frame.size.height;
//    }
//    if ([commentResponse.comment length]) {
//        return commentResponse.commentHeight;
//    }else{
//        return desInt;
//    }
    
}
-(void)string:(NSString *)strs{
    NSString *c = strs;
    
    unsigned intVal;
    NSScanner *scanner = [NSScanner scannerWithString:c];
    [scanner scanHexInt:&intVal];
    
    NSString *str = nil;
    if (intVal > 0xFFFF) {
        unsigned remainder = intVal - 0x10000;
        unsigned topTenBits = (remainder >> 10) & 0x3FF;
        unsigned botTenBits = (remainder >>  0) & 0x3FF;
        
        unichar hi = topTenBits + 0xD800;
        unichar lo = botTenBits + 0xDC00;
        unichar unicodeChars[2] = {hi, lo};
        str = [NSString stringWithCharacters:unicodeChars length:2];
    } else {
        unichar lo = (unichar)(intVal & 0xFFFF);
        str = [NSString stringWithCharacters:&lo length:1];
    }
    
    NSLog(@"str = %@", str);
}
- (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([tableView isEqual:reportTableView]) {
//        return 30;
//    }
//    CommentsDTO *commentResponse= [self.commentsResponse objectAtIndex:indexPath.row];
//    if ([commentResponse.comment length]) {
//        return commentResponse.commentHeight;
//    }else{
//        return desInt;
//    }
    if ([tableView isEqual:reportTableView]) {
        return 30;
    }
    id cells = [self tableView:tblViewComments cellForRowAtIndexPath:indexPath];
    CommentsTableViewCell *commentCell = (CommentsTableViewCell *)cells;
    NSLog(@"cell heighttttt --- %f",commentCell.contentView.frame.size.height);
    NSLog(@"cell heighttttt --- %f",commentCell.lblCommentTxt.frame.size.height);
    CommentsDTO *commentResponse= [self.commentsResponse objectAtIndex:indexPath.row];
    commentResponse.commentHeight=commentCell.contentView.frame.size.height+commentCell.lblCommentTxt.frame.size.height-27;
    
//    CommentsTableViewCell *cell = (CommentsTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    UITableViewCell * rcell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//    
//    if([rcell isKindOfClass:[CommentsTableViewCell class]]){
//        cell = (CommentsTableViewCell *)rcell;
//        NSLog(@"cell heighttttt --- %f",cell.lblCommentTxt.frame.size.height);
//    }
//    
//    commentResponse.commentHeight=cell.lblCommentTxt.frame.size.height;
    return commentResponse.commentHeight;


}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:reportTableView]) {
        return [reportReasonArray count];
    }
    if([self.commentsResponse count] == 0) {
        iconComment.hidden = YES;
        iconCommentButton.hidden=YES;
        ConstraintCommentIcon.constant=0;
        iconByteValueLblConstrain.constant = 28;
    }
    else { iconComment.hidden = NO;
        iconCommentButton.hidden=NO;
        ConstraintCommentIcon.constant=37;
        iconByteValueLblConstrain.constant = 58;
    }
    return [self.commentsResponse count];
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:reportTableView]) {
        return NO;
    }
    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    if (cell.tag==21) {
        return YES;
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        indexPathToDel = (int)indexPath.row;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure want to delete this Comment?"
                                                 message:@""
                                                 delegate:self
                                                 cancelButtonTitle:@"No"
                                         otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([reportTableView isEqual:tableView]) {
        NSUInteger imageId=[tableView tag];
        
        [reportPopover dismiss];
        reportPopover = nil;
        [postCommentModel reportImageWithImageId:imageId forReason:[reportReasonArray objectAtIndex:indexPath.row]];
    }
}

#pragma mark Alert Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
 
        if (indexPathToDel < [postCommentModel.listOfComments count]) {
            
            CommentsDTO *response=[postCommentModel.listOfComments objectAtIndex:indexPathToDel];
            [postCommentModel deleteComment:[NSString stringWithFormat:@"%ld",response.commentId]];
        }
    } else if(buttonIndex == 0) {
        
        [tblViewComments reloadData];
    }
    
}

#pragma mark TextView delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if(text.length == 0 || [textView.text isEqualToString:CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER] || [text isEqualToString:@"\n"])
    txtViewComment.returnKeyType = UIReturnKeyDefault;
    else
        txtViewComment.returnKeyType = UIReturnKeySend;
        [txtViewComment reloadInputViews];
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        if (textView.text.length>0) {
            if(![textView.text isEqualToString:CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER])
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate showProgress];
                [postCommentModel submitComment:textView.text forImage:self.imageDetails.imageId];
            }
        }else
        {
            [textView setText:CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER];
        }
        return NO;
    }
    return YES;
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [reportPopover dismiss];
    reportPopover = nil;
    if ([textView.text isEqualToString:CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER]) {
        textView.text = @"";
        textView.textColor = [UIColor darkTextColor];
    }
    
    if(txtViewComment.text.length == 0)
        txtViewComment.returnKeyType = UIReturnKeyDefault;
    else
        txtViewComment.returnKeyType = UIReturnKeySend;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] ) {
        textView.text = CONSTANT_COMMENT_TEXTVIEW_PLACE_HOLDER;
        textView.textColor = [UIColor lightGrayColor];
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    txtViewComment.enablesReturnKeyAutomatically = YES;
     CGPoint scrollPoint = CGPointMake(0, textView.frame.origin.y+80);
    
    [scrollView setContentOffset:scrollPoint animated:YES];
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
   
    [scrollView setContentOffset:CGPointZero animated:YES];
    return YES;
}

#pragma mark keyboard notification

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)unregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSLog(@"Keyboard is active.");
    //NSDictionary* info = [aNotification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (self.view.frame.size.height==420) {
        constraintTextViewTop.constant-=60;
        [UIView animateWithDuration:0.6 animations:^{
            [viewTextViewHolder layoutIfNeeded];
        }];
    }
}
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    NSLog(@"Keyboard is hidden");
    if (self.view.frame.size.height==420) {
        constraintTextViewTop.constant=0;
        [viewTextViewHolder layoutIfNeeded];
    }
}

#pragma mark Gesture delegate (swipe left to pop view controller)
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (reportPopover!=nil){
        return NO;
    }    return YES;
}
- (NSString *) stringToHex:(NSString *)str
{
    NSUInteger len = [str length];
    unichar *chars = malloc(len * sizeof(unichar));
    [str getCharacters:chars];
    
    NSMutableString *hexString = [[NSMutableString alloc] init];
    
    for(NSUInteger i = 0; i < len; i++ )
    {
        [hexString appendFormat:@"%02x", chars[i]]; /*EDITED PER COMMENT BELOW*/
    }
    free(chars);
    
    return hexString;
}

typedef void (^emojiBlock)(BOOL containsEmoji, int totalLength);

- (void)searchStringForEmoji:(NSString *)string withBlock:(emojiBlock)block
{
    __block BOOL res = false;
    
    __block int totalLenSearched = 0;
    
    __block int totalLen = (int)string.length;
    
    __block  int numberOfCharacters = 0;
    
    NSRange fullRange = NSMakeRange(0, [string length]);
    [string enumerateSubstringsInRange:fullRange
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange,
                                         NSRange enclosingRange, BOOL *stop)
     {
         totalLenSearched += enclosingRange.length;
         numberOfCharacters++;
         
         NSString *hex = [self stringToHex:substring];
         
         if (hex.length > 2) {
             //The hexadecimal representation of emoji are always >2 characters in length. So if the length is > 2, we've found an emoji.
             res = true;
         }
         
         if (totalLenSearched == totalLen) {
             //we've reached the end of the string, calling the completion block with our result.
             block(res, numberOfCharacters);
         }
     }];
}
@end
