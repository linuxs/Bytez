//
//  HomeViewController.m
//  Bytez
//
//  Created by Jeyaraj on 12/22/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIRefreshControl+AFNetworking.h"
#import "AlertConstants.h"
#import "HomeViewController.h"
#import "BZTabBarController.h"
#import "BytezSessionHandler.h"
#import "BZTabBarItem.h"
#import "TransitionAnimationHandler.h"
#import "NoFeedView.h"
#import "BZTabBar.h"
#import "APIKeyConstants.h"
#import "RecentImageModel.h"
#import "APIHandler.h"
#import "ReportImagePopover.h"
#import "ResponseImageDTO.h"
#import "RegisterDeviceHandler.h"
#import "URLConstants.h"
#import "DataHandler.h"
#import "RecentImageTableViewCell.h"
#import "PostCommentViewController.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+UpdateAutoLayoutConstraints.h"
#import "UILabel+changeAppearance.h"
#import "NoFeedView.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define IS_IPHONE_4 ([[UIScreen mainScreen]bounds].size.height == 480)
#define isiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)
#define IS_IPHONE_5 ([[UIScreen mainScreen]bounds].size.height == 568)
#define IS_IPHONE_6 ([[UIScreen mainScreen]bounds].size.height == 667)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen]bounds].size.height == 736)
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,RecentImageModelDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>{
    BOOL isCheck;
}

@end

@implementation HomeViewController

{
    RecentImageModel *recentImageModel;
    NSTimer *restartRefreshTimer;
    UITableView *reportTableView;
    NSArray *reportReasonArray;
    ReportImagePopover *reportPopover;
    NSInteger selectedRecentImageId;
    NSInteger selectedPopularImageId;
    NSInteger deleteImageId;
    NSInteger likedImageId;
    BOOL isRecentPaginationAPICallStarted;
    BOOL isPopularPaginationAPICallStarted;
    NSString *currentLatitude;
    NSString *currentLongitude;
    UIRefreshControl *recentRefreshControl;
    
    __weak IBOutlet UIView *uiSegmentControllerBGView;
    __weak IBOutlet NSLayoutConstraint *constraintPicsInLeft;
    __weak IBOutlet NSLayoutConstraint *constraintShareWithLeft;
    __weak IBOutlet UISegmentedControl *segmentControlRecentPopular;
    __weak IBOutlet NSLayoutConstraint *layoutConstraintRecentTrailing;
    __weak IBOutlet NSLayoutConstraint *recentTableViewLeftConstraint;
    __weak IBOutlet UIView *viewNoFeeds;
    __weak IBOutlet NSLayoutConstraint *popularTableViewLeftConstraint;
    __weak IBOutlet UITableView *tableViewRecentImageList;
    __weak IBOutlet NSLayoutConstraint *layoutConstraintEqualWidth;
    __weak IBOutlet UITableView *tableViewPopularImageList;
    __weak IBOutlet NSLayoutConstraint *constraintToastHeight;
    __weak IBOutlet UILabel *lblToastMessage;
    __weak IBOutlet UIView *viewToast;
    
    NoFeedView *viewNoFeedScreen;
    
    __weak IBOutlet UILabel *milesLbl;
    __weak IBOutlet UIImageView *imgViewNoFeedArrow;
    __weak IBOutlet NSLayoutConstraint *constraintBeTheFirstLeft;
    __weak IBOutlet NSLayoutConstraint *constraintArealblRight;
    __weak IBOutlet NSLayoutConstraint *constraintLogoWidth;
    __weak IBOutlet NSLayoutConstraint *ConstraintLogoHeight;
    __weak IBOutlet NSLayoutConstraint *constraintShareLblBottom;
    
    
     __weak IBOutlet NSLayoutConstraint *blinkImageTrailing;
    __weak IBOutlet NSLayoutConstraint *blinkImageCenter;
    
    __weak IBOutlet UILabel *shareWithLbl;
    __weak IBOutlet UILabel *betheFirstLbl;
    __weak IBOutlet UILabel *picsLbl;
    __weak IBOutlet UIImageView *logoImgView;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self showProgress];
    [self initView];
    [self hideToastMessage];
    self.navigationController.delegate = self;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        recentTableViewLeftConstraint.constant = 0;
        [self.view updateConstraints];
    }
    if([[[BytezSessionHandler Instance] bytezRadius] isEqualToString:@"1"])
        milesLbl.text = [NSString stringWithFormat:@"%@ MILE", [[BytezSessionHandler Instance] bytezRadius]];
    else
        milesLbl.text = [NSString stringWithFormat:@"%@ MILES", [[BytezSessionHandler Instance] bytezRadius]];
        milesLbl.layer.cornerRadius = 2.0;
//    milesLbl.layer.borderWidth = 1.0f;
    
    __weak id weakSelf=self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSTimer * timer =
        [NSTimer timerWithTimeInterval:180
                                target:weakSelf
                              selector:@selector(refreshListWithTimer:)
                              userInfo:nil
                               repeats:YES];
        
        [[NSRunLoop mainRunLoop] addTimer:timer
                                  forMode:NSDefaultRunLoopMode];
    });
    
}
- (void)viewWillDisappear:(BOOL)animated {
    if([[[BytezSessionHandler Instance] bytezRadius] isEqualToString:@"1"])
     milesLbl.text = [NSString stringWithFormat:@"%@ MILE", [[BytezSessionHandler Instance] bytezRadius]];
    else
    milesLbl.text = [NSString stringWithFormat:@"%@ MILES", [[BytezSessionHandler Instance] bytezRadius]];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // recent image view empty
//    NSLog(@"---%lu---",(unsigned long)[recentImageModel.recentImageList count]);
//   if ([recentImageModel.recentImageList count]==0) {
//        [self shownoFeedView];
//   }else{
//        // recent image view has image
//        [viewNoFeeds setHidden:YES];
//    }
    uiSegmentControllerBGView.layer.borderWidth = 1.5f;
    uiSegmentControllerBGView.layer.borderColor = [UIColor colorWithRed:26/255.0f green:86/255.0f blue:77/255.0f alpha:1].CGColor;
    uiSegmentControllerBGView.layer.cornerRadius = 3;
    [self hideToastMessage];
    self.view.alpha=0.95f;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha=1;
    } completion:^(BOOL finished) {
    }];
//    
//    [viewToast hideByHeight:YES];
//    [viewToast setConstraintConstant:0 forAttribute:NSLayoutAttributeHeight];
    
    
        if([[[BytezSessionHandler Instance] bytezRadius] isEqualToString:@"1"])
        milesLbl.text = [NSString stringWithFormat:@"%@ MILE", [[BytezSessionHandler Instance] bytezRadius]];
    else
        milesLbl.text = [NSString stringWithFormat:@"%@ MILES", [[BytezSessionHandler Instance] bytezRadius]];
}
-(void)viewDidAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    if ([[BytezSessionHandler Instance] reloadRecentAndPopular]) {
        [self showProgress];
        [self startUpdatingLocation];
        return;
    }
    likedImageId=-1;
    if ([BytezSessionHandler Instance].LikedImageId!=-1) {
        [recentImageModel updateLikeForImageWithImageId:[BytezSessionHandler Instance].LikedImageId withLikeCount:0];
//        [BytezSessionHandler Instance].newLikeCountInComments=0;
    }
    if([self refreshRecentSearch])
    {
        [self imagePosted:NO];
        [self beginRefreshingRecentTableView];
    }else
    {
        [tableViewRecentImageList reloadData];
        [tableViewPopularImageList reloadData];
    }
}
-(void)initView
{
    tableViewRecentImageList.delegate=self;
    tableViewRecentImageList.dataSource=self;
    [tableViewRecentImageList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[tableViewRecentImageList setHidden:YES];
    
    tableViewPopularImageList.delegate=self;
    tableViewPopularImageList.dataSource=self;
    [tableViewPopularImageList setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    recentImageModel=[[RecentImageModel alloc]init];
    recentImageModel.delegate=self;
    [recentImageModel setCurrentlyReportedImage:-1];
    [recentImageModel setRecentImageList:[NSMutableArray array]];
    [recentImageModel setPopularImageList:[NSMutableArray array]];
    
    RegisterDeviceHandler *deviceHandler=[[RegisterDeviceHandler alloc]init];
    
    [deviceHandler registerDeviceWithSuccessHandler:^(id obj) {
        [self startUpdatingLocation];
    } failureHandler:^(NSError * error) {
        
    }];
    self.navigationController.navigationBarHidden = YES;
    NSArray *imagesArray=[[NSArray alloc]initWithObjects:[UIImage imageNamed:@"button_left_active1.png"],[UIImage imageNamed:@"button_right_normal1.png"], nil];
    
    for (int i = 0 ; i < imagesArray.count; i++) {
        UIImage *image = [imagesArray[i] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [segmentControlRecentPopular setImage:image forSegmentAtIndex:i];
    }
    [segmentControlRecentPopular addTarget:self
                                    action:@selector(action:forEvent:)
                          forControlEvents:UIControlEventValueChanged];
    recentRefreshControl=[[UIRefreshControl alloc]initWithFrame:CGRectMake(0,0,20,20)];
    [recentRefreshControl addTarget:self action:@selector(beginRefreshingRecentTableView) forControlEvents:UIControlEventValueChanged];
    //recentRefreshControl.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [tableViewRecentImageList addSubview:recentRefreshControl];
    reportTableView = [[UITableView alloc] init];
    reportTableView.frame = CGRectMake(0,0,160,120);
    reportTableView.rowHeight=30.0f;
    reportTableView.dataSource = self;
    reportTableView.delegate = self;
    reportReasonArray = @[@"Spam/Advertisement", @"Violent/Threatening", @"Nudity/Inappropriate", @"Just not feeling it"];
    viewToast.layer.cornerRadius=5.0f;
    }
-(void)refreshListWithTimer:(id)sender
{
    if (self.isViewLoaded && self.view.window) {
        [UIView animateWithDuration:0.5 animations:^{
            [tableViewRecentImageList setContentOffset:CGPointMake(0, 0)];
        }];
        [BytezSessionHandler Instance].shouldReloadRecent=YES;
        [BytezSessionHandler Instance].shouldReloadPopular=YES;
        [self showProgress];
        [self startUpdatingLocation];
    }
}
#pragma mark Pull down to refresh
- (void)beginRefreshingRecentTableView {
        [recentRefreshControl beginRefreshing];
    [self pullToRefreshRecentImages];
    if (tableViewRecentImageList.contentOffset.y == 0) {
       [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
       tableViewRecentImageList.contentOffset = CGPointMake(0, -recentRefreshControl.frame.size.height);
        } completion:^(BOOL finished){
            
        }];
    }
}
#pragma mark SegmentControl selected changed event

- (void)action:(id)sender forEvent:(UIEvent *)event
{
    if (segmentControlRecentPopular.selectedSegmentIndex==0) {
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            recentTableViewLeftConstraint.constant = 0;
        }else{
           // recentTableViewLeftConstraint.constant = -16;
        }
        popularTableViewLeftConstraint.constant=0;
         [tableViewRecentImageList setHidden:NO];
        [UIView animateWithDuration:0.5 animations:^{
            [tableViewRecentImageList layoutIfNeeded];
           // [tableViewPopularImageList layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            if ([BytezSessionHandler Instance].shouldReloadRecent) {
                if (currentLatitude!=NULL && currentLongitude!=NULL) {
                    [recentImageModel refreshRecentImages:currentLatitude andLongitude:currentLongitude];
                }else{
                    [self startUpdatingLocation];
                }
            }
            
        }];
        
        [segmentControlRecentPopular setImage:[[UIImage imageNamed:@"button_left_active1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forSegmentAtIndex:0];
        [segmentControlRecentPopular setImage:[[UIImage imageNamed:@"button_right_normal1.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forSegmentAtIndex:1];
        
    }else{
        
        [segmentControlRecentPopular setImage:[[UIImage imageNamed:@"button_left_normal1.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forSegmentAtIndex:0];
        [segmentControlRecentPopular setImage:[[UIImage imageNamed:@"button_right_active1.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        if ([recentImageModel.popularImageList count]==0) {
            [self showProgress];
            if (currentLatitude!=NULL && currentLongitude!=NULL) {
                [recentImageModel getPopularImageWithLat:currentLatitude andLongitude:currentLongitude forPullDownToRefresh:NO];
            }else{
                [self startUpdatingLocation];
            }
        }else if([[BytezSessionHandler Instance] reloadPopular]){
            [self showProgress];
            [self startUpdatingLocation];
        }
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")){
            recentTableViewLeftConstraint.constant = -tableViewRecentImageList.frame.size.width;
        }else{
            //recentTableViewLeftConstraint.constant = -tableViewRecentImageList.frame.size.width-16;
        }
        NSLog(@"-->%f",tableViewPopularImageList.frame.size.width);
        NSLog(@"-->%f", popularTableViewLeftConstraint.constant);
        [tableViewRecentImageList setHidden:YES];
        popularTableViewLeftConstraint.constant=-tableViewPopularImageList.frame.size.width;
}
}

-(void)btnReportImageClicked:(id)sender
{
    UIButton *reportButton=(UIButton*)sender;
    CGPoint startPoint = [self.view convertPoint:CGPointZero fromView:reportButton];
    startPoint.x+=15;
    reportTableView.tag=reportButton.tag;
    if (reportPopover==nil) {
        reportPopover=[ReportImagePopover new];
    }
    float possiblepopoverHeight=self.view.frame.size.height-startPoint.y;
    if (possiblepopoverHeight<150) {
        //        startPoint.y+=15;
        [reportPopover showAtPoint:startPoint popoverPostion:ReportImagePopoverPositionUp withContentView:reportTableView inView:self.view];
    }else{
        startPoint.y+=25;
        [reportPopover showAtPoint:startPoint popoverPostion:ReportImagePopoverPositionDown withContentView:reportTableView inView:self.view];
    }
}
#pragma mark RecentImage model Delegate
-(void)shownoFeedView
{
    popularTableViewLeftConstraint.constant= 0;
    [viewNoFeeds setHidden:NO];
    milesLbl.hidden=YES;
    betheFirstLbl.frame = CGRectMake(self.view.frame.size.width,betheFirstLbl.frame.origin.y, betheFirstLbl.frame.size.width,betheFirstLbl.frame.size.height);
    picsLbl.frame=CGRectMake(self.view.frame.size.width, picsLbl.frame.origin.y, picsLbl.frame.size.width, picsLbl.frame.size.height);
    shareWithLbl.frame=CGRectMake(self.view.frame.size.width, shareWithLbl.frame.origin.y, shareWithLbl.frame.size.width, shareWithLbl.frame.size.height);
    logoImgView.frame=CGRectMake(self.view.frame.size.width, logoImgView.frame.origin.y, logoImgView.frame.size.width, logoImgView.frame.size.height);

    //Be the first to Post Cool Lbl
    [UIView animateWithDuration:0.5 delay:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
       betheFirstLbl.center = CGPointMake(self.view.frame.size.width/2, betheFirstLbl.center.y);
    } completion:^(BOOL finished){
    }];
    //Pics in your Area Lbl
    [UIView animateWithDuration:1 delay:1.5 options:UIViewAnimationOptionCurveEaseIn  animations:^{
          picsLbl.center = CGPointMake(self.view.frame.size.width/2, picsLbl.center.y);
    } completion:^(BOOL finished){
    }];
    
    //Batz logo image Animations
        [UIView animateWithDuration:1.5 delay:2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            //[logoImgView layoutIfNeeded];
            logoImgView.center = CGPointMake(self.view.frame.size.width/2, logoImgView.center.y);
        } completion:nil];
    
    //Share with other Batz Lbl
    [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveEaseIn animations:^{
         shareWithLbl.center = CGPointMake(self.view.frame.size.width/2, shareWithLbl.center.y);
    } completion:^(BOOL finished){
        
    }];
    
       //To Point Take Snap arrow Animation
    [UIView animateWithDuration:1 delay:3 options:UIViewAnimationOptionCurveLinear animations:^{
        //constraintShareWithLeft.constant=0;
        //[viewNoFeeds layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (IS_IPHONE_5) {
            NSLog(@"No");
        }else{
            //imgViewNoFeedArrow.frame=CGRectMake(154, 416, imgViewNoFeedArrow.frame.size.width, imgViewNoFeedArrow.frame.size.height);
             imgViewNoFeedArrow.center = CGPointMake(260,self.view.frame.size.height-50);
        }
        imgViewNoFeedArrow.layer.opacity=0.0f;
        [imgViewNoFeedArrow setHidden:NO];
        [UIView transitionWithView: imgViewNoFeedArrow
                          duration:0.6f
                           options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                        animations:^{ imgViewNoFeedArrow.layer.opacity = 1.0f; }
                        completion:NULL];
    }];
}

-(void)removenoFeedView
{
    //[viewNoFeeds removeFromSuperview];
    [viewNoFeeds setHidden:YES];
    [shareWithLbl.layer removeAllAnimations];
    [betheFirstLbl.layer removeAllAnimations];
    [picsLbl .layer removeAllAnimations];
    [logoImgView.layer removeAllAnimations];
    [imgViewNoFeedArrow.layer removeAllAnimations];
    [imgViewNoFeedArrow setHidden:YES];
 }
-(void)showAlertWithMessage:(NSString *)message
{
    [self hideProgress];
    [recentRefreshControl endRefreshing];
    isPopularPaginationAPICallStarted=FALSE;
    isRecentPaginationAPICallStarted=FALSE;
    [self showToastMessage:message];
}
-(void)showFailureToastWithMessage:(NSString *)message
{
    [self hideProgress];
    [recentRefreshControl endRefreshing];
    isPopularPaginationAPICallStarted=FALSE;
    isRecentPaginationAPICallStarted=FALSE;
    [self showToastMessage:message];
}
-(void)refreshPopularImageList:(BOOL)refresh
{
    [self hideProgress];
    [BytezSessionHandler Instance].shouldReloadPopular=NO;
    isPopularPaginationAPICallStarted=false;
    if (refresh) {
        [self removenoFeedView];
        [tableViewPopularImageList reloadData];
    }
}
-(void)refreshRecentImageList:(BOOL)refresh
{
    [BytezSessionHandler Instance].shouldReloadRecent=NO;
    [self hideProgress];
    [recentRefreshControl endRefreshing];
    isRecentPaginationAPICallStarted=false;
   if (refresh) {
        [self removenoFeedView];
        [tableViewRecentImageList reloadData];
    }
}
-(void)refreshRowAtIndex:(NSUInteger)rowNumber
{
     // [viewNoFeeds setHidden:YES];
    [tableViewRecentImageList reloadData];
}
-(void)refreshPopularRowAtIndex:(NSUInteger)rowNumber
{
     // [viewNoFeeds setHidden:YES];
    [tableViewPopularImageList reloadData];
}
-(void)requestedImageComments:(NSArray *)commentsArray
{
    [self hideProgress];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostCommentViewController *postCommentsViewController = [sb instantiateViewControllerWithIdentifier:@"PostCommentViewControllerID"];
    postCommentsViewController.commentsResponse=commentsArray;
    postCommentsViewController.isFromHomeFeed=YES;
    postCommentsViewController.imageDetails=[recentImageModel getRecentResponseImageDto:selectedRecentImageId];
    
    [self.navigationController pushViewController:postCommentsViewController animated:YES ];
}
#pragma mark TableView Delegate and DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:reportTableView]) {
        NSString *cellId = @"cellIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        cell.textLabel.text = reportReasonArray[indexPath.row];
        [cell.textLabel setFont:[UIFont systemFontOfSize:9.0f]];
        [cell.textLabel setTextColor:[UIColor darkGrayColor]];
        return cell;
    }
    
    static NSString *simpleTableIdentifier = @"SimpleTableCell";
    
    ResponseImageDTO *recentResponse;
    RecentImageTableViewCell *cell;
    
 if ([tableViewPopularImageList isEqual:tableView]){
        recentResponse=[recentImageModel.popularImageList objectAtIndex:indexPath.row];
        cell= (RecentImageTableViewCell *)[tableViewPopularImageList dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
     else{
        recentResponse=[recentImageModel.recentImageList objectAtIndex:indexPath.row];
        cell= (RecentImageTableViewCell *)[tableViewRecentImageList dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    }
    if (cell == nil){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RecentImageTableViewCell" owner:self options:nil];
        [nib copy];
        cell = [nib objectAtIndex:0];
    }
    NSString *imageUrl=[NSString stringWithFormat:@"%@/%@",URL_IMAGEPATH,recentResponse.imageName];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.imgViewRecentPostedImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] placeholderImage:[UIImage imageNamed:@"placeholder"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        UIImage *scalledImage=image;
        cell.imgViewRecentPostedImage.image = scalledImage;
    } failure:NULL];
    cell.cellData=recentResponse;
    cell.tag=recentResponse.imageId;
    
    for (UIGestureRecognizer *recognizer in cell.gestureRecognizers) {
        [cell removeGestureRecognizer:recognizer];
    }
    // To navigate to commentViewController
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(navigateToCommentViewController:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionRight];
    [cell addGestureRecognizer:gestureR];
    
    if (recentResponse.userId == [[RegisterDeviceHandler getRegisteredUserId] longLongValue]) {
        
        UISwipeGestureRecognizer *gestureLeft = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(deleteImage:)];
        [gestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [cell addGestureRecognizer:gestureLeft];
    }
    
//    if ([recentResponse.Liked isEqualToString:API_RESPONSE_VALUE_LIKE_FALSE]) {
//        
    
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeImage:)];
        [tapGesture setNumberOfTapsRequired:2];
        [cell addGestureRecognizer:tapGesture];
        
        [cell.imgViewLikeIcon setUserInteractionEnabled:YES];
        
        
        UITapGestureRecognizer *singleTapToLike=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(likeImage:)];
        [singleTapToLike setNumberOfTapsRequired:1];
        [cell.imgViewLikeIcon addGestureRecognizer:singleTapToLike];
        cell.imgViewLikeIcon.tag=recentResponse.imageId;
        
        
//    }else{
//        
//        [cell.imgViewLikeIcon setUserInteractionEnabled:NO];
//        
//    }
    
    if (likedImageId==cell.tag) {
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setDuration:2.0f];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        [animation setType:@"rippleEffect" ];
        [cell.imgViewRecentPostedImage.layer addAnimation:animation forKey:NULL];
        likedImageId=-1;
    }
    
    if (recentResponse.isReportedByMe) {
        [cell.btnReportImage setImage:[UIImage imageNamed:@"icon-report.png"] forState:UIControlStateNormal];
        [cell.btnReportImage setUserInteractionEnabled:NO];
    }else
    {
        [cell.btnReportImage setImage:[UIImage imageNamed:@"report_grey.png"] forState:UIControlStateNormal];
        [cell.btnReportImage setUserInteractionEnabled:YES];
        [cell.btnReportImage setTag:recentResponse.imageId];
        [cell.btnReportImage addTarget:self action:@selector(btnReportImageClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:reportTableView]) {
        return [reportReasonArray count];
    }
    if ([tableView isEqual:tableViewRecentImageList] && recentImageModel.recentImageList!=nil) {
        return [recentImageModel.recentImageList count];
    }
    if ([tableView isEqual: tableViewPopularImageList]  && recentImageModel.popularImageList!=nil) {
        return [recentImageModel.popularImageList count];
    }
    return 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:reportTableView]) {
        return;
    }
    ResponseImageDTO *recentResponse;
    
    if ([tableViewPopularImageList isEqual:tableView]) {
        recentResponse=[recentImageModel.popularImageList objectAtIndex:indexPath.row];
    }else
    {
        recentResponse=[recentImageModel.recentImageList objectAtIndex:indexPath.row];
    }
    RecentImageTableViewCell *recentCell=(RecentImageTableViewCell*)cell;
    NSLog(@"%ld",recentResponse.numberOfComments);
    //recentCell.lblLikeCount=nil;
    recentCell.btnComment.imageView.image=nil;
    if (recentResponse.numberOfComments==0) {
       [recentCell.btnComment  setConstraintConstant:0 forAttribute:NSLayoutAttributeWidth];
    }else
    {
        [recentCell.btnComment  setConstraintConstant:37 forAttribute:NSLayoutAttributeWidth];
    }
    [recentCell updateConstraints];
    [recentCell layoutIfNeeded];
    [recentCell setNeedsDisplay];
    //[recentCell updateConstraints];
   // [tableViewRecentImageList layoutIfNeeded];
    
}
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([reportTableView isEqual:tableView]) {
        NSUInteger imageId=[tableView tag];
        [reportPopover dismiss];
        [recentImageModel reportImageWithImageId:imageId forReason:[reportReasonArray objectAtIndex:indexPath.row]];
        //        reportTableView=nil;
        [reportTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:reportTableView]) {
        return 30;
    }else{
        if (IS_IPHONE_6_PLUS) {
            return 410;
        }else{
            return 319;
        }
    }
}

#pragma mark Scrollview Delegate methods
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self showTabbar];
    
    float endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height)
    {
        switch (segmentControlRecentPopular.selectedSegmentIndex) {
            case 0:
            {
                if (!isRecentPaginationAPICallStarted) {
                    isRecentPaginationAPICallStarted=YES;
                    if (currentLatitude==nil || currentLongitude==nil) {
                        [self startUpdatingLocation];
                    }
                    else
                    {
                        [recentImageModel getRecentImageWithLat:currentLatitude andLongitude:currentLongitude forPullDownToRefresh:NO];
                    }
                }
            }
                break;
            case 1:
            {
                if (!isPopularPaginationAPICallStarted) {
                    isPopularPaginationAPICallStarted=YES;
                    [recentImageModel getPopularImageWithLat:currentLatitude andLongitude:currentLongitude forPullDownToRefresh:NO];
                }
            }
                break;
        }
    }
}
#pragma mark AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 404) {
        if (buttonIndex ==1)
        {
            [recentImageModel deleteImageWithImageId:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%li",(long)deleteImageId], nil]];
        }else
        {
            deleteImageId = 0;
        }
    }
}
#pragma mark locationManager
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    [self.locationManger stopUpdatingLocation];
    
    self.locationManger=nil;
    
    CLLocation *currentLocation = [locations objectAtIndex:0];
    
    if (currentLocation!=nil) {
        NSString *lat=[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
        NSString *longi=[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        currentLatitude=lat;
        currentLongitude=longi;
        if (segmentControlRecentPopular.selectedSegmentIndex==0) {
            if ([[BytezSessionHandler Instance] reloadRecentAndPopular]) {
                //[viewNoFeeds setHidden:YES];
                [recentImageModel refreshRecentImages:lat andLongitude:longi];
            }
            else
            {
                [recentImageModel getRecentImageWithLat:lat andLongitude:longi forPullDownToRefresh:NO];
            }
        }
        else
        {
            if ([[BytezSessionHandler Instance] reloadPopular]) {
                [recentImageModel refreshPopularImages:lat andLongitude:longi];
            }
            else
            {
                [recentImageModel getPopularImageWithLat:lat andLongitude:longi forPullDownToRefresh:NO];
            }
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self hideProgress];
    switch([error code])
    {
        case kCLErrorNetwork:
        {
            [self showToastMessage:ALERT_NO_NETWORK];
        }
            break;
        case kCLErrorDenied:
        {
            [self showToastMessage:@"Please give access to your current location"];
        }
            break;
        default:
        {
            [self showToastMessage:@"Network error"];
        }
            break;
    }
    
}
#pragma mark Gesture Selectors
-(void)navigateToCommentViewController:(id) sender
{
    NSInteger selectedId =[sender view].tag;
    
    selectedRecentImageId=selectedId;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PostCommentViewController *postCommentsViewController = [sb instantiateViewControllerWithIdentifier:@"PostCommentViewControllerID"];
    postCommentsViewController.isFromHomeFeed=YES;
    postCommentsViewController.imageDetails=[recentImageModel getRecentResponseImageDto:selectedRecentImageId];
    [postCommentsViewController commentPostedHandler:^(NSUInteger imageid,NSUInteger count,bool isImageReported) {
        if (isImageReported) {
            
            [recentImageModel updateReportCountFor:imageid WithCount:6];
            
        }
        [recentImageModel updateCommentCountForImage:imageid WithCount:count];
    }];
    
    
    [self.navigationController pushViewController:postCommentsViewController animated:YES];
}

-(void) deleteImage:(id) sender
{
    NSInteger imageId =[sender view].tag;
    deleteImageId = imageId;
    
    UIAlertView *alertView=[[UIAlertView alloc ]initWithTitle:@"Are you sure want to delete this image?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    
    alertView.tag = 404;
    
    [alertView show];
}

-(void)likeImage:(id)sender
{
    NSInteger imageId =[sender view].tag;
    likedImageId=imageId;
    [recentImageModel likeImageWithImageID:imageId];
}

#pragma mark Custom methods
-(void)pullToRefreshRecentImages
{
    segmentControlRecentPopular.selectedSegmentIndex=0;
    [self action:nil forEvent:nil];
    [tableViewRecentImageList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [recentImageModel getRecentImageWithLat:currentLatitude andLongitude:currentLongitude forPullDownToRefresh:YES];
}
-(void)pullToRefreshPopularImages
{
    [tableViewPopularImageList scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [recentImageModel getPopularImageWithLat:currentLatitude andLongitude:currentLongitude forPullDownToRefresh:YES];
}

-(void)updateLocationService
{
    [self.locationManger startUpdatingLocation];
}

#pragma mark Toast messages

-(void)showToastMessage :(NSString*)message
{
    [lblToastMessage setText:message];
    [UIView animateWithDuration:0.5f animations:^{
        constraintToastHeight.constant=40;
        [self.view layoutIfNeeded];
    }];
    [self performSelector:@selector(hideToastMessage) withObject:self afterDelay:1.5f];
}

-(void)hideToastMessage
{
    [viewToast setHidden:YES];
    constraintToastHeight.constant=0;
    [UIView animateWithDuration:1 animations:^{
    [viewToast layoutIfNeeded];
    }];
}
#pragma mark Navigation animation
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController*)fromVC toViewController:(UIViewController*)toVC {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (operation == UINavigationControllerOperationPush) {
        appdelegate.push = @"YES";
        appdelegate.popView = @"YES";
        return [[TransitionAnimationHandler alloc] init];
    } else if (operation == UINavigationControllerOperationPop) {
        
        appdelegate.push = @"NO";
        return [[TransitionAnimationHandler alloc] init];
    }
    return nil;
}
#pragma mark AutoRotate and Memory warning
-(BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
