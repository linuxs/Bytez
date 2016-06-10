//
//  MyCaveViewController.m
//  Bytez
//
//  Created by Jeyaraj on 12/22/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MyCaveViewController.h"
#import "MyCaveModel.h"
#import "UIImageView+AFNetworking.h"
#import "PostCommentViewController.h"
#import "URLConstants.h"
#import "ResponseImageDTO.h"
#import "BytezSessionHandler.h"
#import "MyCaveCollectionViewCell.h"
#import "AppDelegate.h"
#import "TransitionAnimationHandler.h"

@interface MyCaveViewController ()<MKMapViewDelegate,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIAlertViewDelegate,MyCaveModelDelegate, UINavigationControllerDelegate>

@end

@implementation MyCaveViewController
{
    __weak IBOutlet MKMapView *mapViewMyCave;
    
    __weak IBOutlet UIView *dragableView;
    __weak IBOutlet UIView *viewmyCaveImageCollection;
    
    __weak IBOutlet UILabel *lblLikesCount;
    __weak IBOutlet UILabel *lblCommentsCount;
    
    __weak IBOutlet NSLayoutConstraint *layoutConstraintBottomFlipButton;
    __weak IBOutlet NSLayoutConstraint *layoutConstraintBottom;
    __weak IBOutlet NSLayoutConstraint *layoutConstraintDragViewBottom;
    __weak IBOutlet NSLayoutConstraint *constriantCollectionViewHeight;
    
    __weak IBOutlet UIButton *btnDrag;
    
    __weak IBOutlet UICollectionView *collectionViewMyCavePhotoGallery;
    __weak IBOutlet UIButton *deleteBtn;
    
    MyCaveModel *mycaveModel;
    
    CGPoint collectionViewContentOffset;
    
    BOOL isMapViewSetRegin;
    BOOL isCollectionViewVisible;
    BOOL isDeleteButtonVisible;
    BOOL isLongPressBegin;
    
    float touchBeginHeight;
    
    int collectionViewState;
    
    NSIndexPath *indexpathToDelete;
    NSMutableArray *arrayMultipleList;
    NSMutableArray *selectedImages;
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    isCollectionViewVisible=NO;
    collectionViewState=1;
    
    [self btnFlipUpAndDownAction:btnDrag];
    
    [dragableView setAlpha:0.1f];
    
    mapViewMyCave.delegate=self;
    mapViewMyCave.showsUserLocation=YES;
    
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.delegate = self;
    
    mycaveModel =[[MyCaveModel alloc]init];
    mycaveModel.delegate=self;
    mycaveModel.arrayMyCaveImages =[NSMutableArray array];
    
    arrayMultipleList=[[NSMutableArray alloc]init];
    
    collectionViewMyCavePhotoGallery.delegate=self;
    collectionViewMyCavePhotoGallery.dataSource=self;
    
    [mycaveModel getMyCaveImages];
    [viewmyCaveImageCollection setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDeletionMode:)];
    longPress.delaysTouchesBegan = YES;
    longPress.minimumPressDuration=0.5;
    longPress.delegate = self;
    [collectionViewMyCavePhotoGallery addGestureRecognizer:longPress];
    
    selectedImages = [[NSMutableArray alloc] init];

    
}


-(void)viewDidAppear:(BOOL)animated
{
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [mycaveModel getMyCaveImages];
    [BytezSessionHandler Instance].reloadMyCave=NO;
    
    if(selectedImages.count > 0)
    [selectedImages removeAllObjects];
    
    deleteBtn.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.alpha=0.95f;
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha=1;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark MapView Delegate methods

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation:(id<MKAnnotation>) annotation
{
    
    MKAnnotationView *pin = (MKAnnotationView *) [mapViewMyCave dequeueReusableAnnotationViewWithIdentifier: @"VoteSpotPin"];
    if (pin == nil){
        pin = [[MKAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"TestPin"];
    }
    else{
        pin.annotation = annotation;
        if (pin.tag==300) {
            return pin;
        }
    }
    
    CLLocationCoordinate2D location= [annotation coordinate];
    
    if (!isMapViewSetRegin) {
        isMapViewSetRegin=YES;
        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = MKCoordinateSpanMake(0.025, 0.025);
        
        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:location radius:1000];
        [mapView addOverlay:circle];
    }
    
    [pin setImage:[UIImage imageNamed:@"mycaveUserAnotation.png"]];
    pin.tag=300;
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    
    MKCoordinateSpan span;
    span.latitudeDelta=mapView.region.span.latitudeDelta;
    span.longitudeDelta=mapView.region.span.longitudeDelta;
    
    return pin;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    [mapView removeOverlays: [mapView overlays]];
    MKCircle * circle = (MKCircle *)overlay;
    
    MKCircleRenderer * renderer = [[MKCircleRenderer alloc] initWithCircle:circle];
    renderer.fillColor=[UIColor colorWithRed:0.0/255.0 green:187.0/255.0 blue:255.0/255.0 alpha:0.3];
    [renderer setStrokeColor:[UIColor colorWithRed:0.0/255.0 green:187.0/255.0 blue:255.0/255.0 alpha:1]];
    renderer.lineWidth=1.0f;
    return renderer;
}

#pragma mark Flip action

- (IBAction)btnFlipUpAndDownAction:(id)sender {
    
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.7 options:UIViewAnimationOptionTransitionNone animations:^{
        
        
        switch (collectionViewState) {
                
            case 0:
            {
                isCollectionViewVisible=false;
                layoutConstraintDragViewBottom.constant=0;
                layoutConstraintBottomFlipButton.constant = 0;
                constriantCollectionViewHeight.constant=0;
                [sender setNeedsUpdateConstraints];
                [viewmyCaveImageCollection setNeedsUpdateConstraints];
                [UIView animateWithDuration:0.5 animations:^{
                    [sender layoutIfNeeded];
                    [viewmyCaveImageCollection layoutIfNeeded];
                    [viewmyCaveImageCollection setNeedsUpdateConstraints];
                    [btnDrag setImage:[UIImage imageNamed:@"mycave-screen-toggle-up.png"] forState:UIControlStateNormal];
                }];
            }
                break;
                
                
            case 1:
            {
                isCollectionViewVisible=true;
                layoutConstraintDragViewBottom.constant=self.view.frame.size.height/2;
                layoutConstraintBottomFlipButton.constant = self.view.frame.size.height/2;
                constriantCollectionViewHeight.constant=self.view.frame.size.height/2-60;
                [sender setNeedsUpdateConstraints];
                [viewmyCaveImageCollection setNeedsUpdateConstraints];
                [UIView animateWithDuration:0.5 animations:^{
                    [sender layoutIfNeeded];
                    [viewmyCaveImageCollection layoutIfNeeded];
                    [btnDrag setImage:[UIImage imageNamed:@"mycave-screen-toggle-down.png"] forState:UIControlStateNormal];
                }];
            }
                break;
                
                
            case 2:
            {
                layoutConstraintDragViewBottom.constant=self.view.frame.size.height-50;
                layoutConstraintBottomFlipButton.constant = self.view.frame.size.height-50;
                constriantCollectionViewHeight.constant=self.view.frame.size.height-100;
                
                [sender setNeedsUpdateConstraints];
                [viewmyCaveImageCollection setNeedsUpdateConstraints];
                
                [UIView animateWithDuration:0.5 animations:^{
                    [sender layoutIfNeeded];
                    [viewmyCaveImageCollection layoutIfNeeded];
                    [btnDrag setImage:[UIImage imageNamed:@"mycave-screen-toggle-down.png"] forState:UIControlStateNormal];
                }];
                
            }
                break;
                
            default:
                break;
        }
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark Delete Action methods

- (void)activateDeletionMode:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state==UIGestureRecognizerStateBegan) {
        collectionViewContentOffset=collectionViewMyCavePhotoGallery.contentOffset;
        isLongPressBegin=YES;
        return;
    }
    
    if (gesture.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    isLongPressBegin=NO;
    CGPoint p = [gesture locationInView:collectionViewMyCavePhotoGallery];
    
    NSIndexPath *indexPath = [collectionViewMyCavePhotoGallery indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        
        deleteBtn.hidden = NO;
        
        if (isDeleteButtonVisible && indexpathToDelete!=nil) {
            //if (indexpathToDelete.row==indexPath.row) {
                
                NSArray *array;
                if(selectedImages.count > 0) {
                    
                    NSString *search = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", search];
                    array = [selectedImages filteredArrayUsingPredicate: predicate];
                    NSLog(@"result: %@", array);
                }
                
                if(array.count == 0)
                    [selectedImages addObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
                else
                    [selectedImages removeObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];

            if(selectedImages.count == 0) {
                    isDeleteButtonVisible = NO;
                    deleteBtn.hidden = YES;
            }
            //}
        } else {
            
            [selectedImages addObject:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
            isDeleteButtonVisible=YES;
           
        }
        
        indexpathToDelete=indexPath;
        [collectionViewMyCavePhotoGallery reloadData];
    }
    
}


-(void)deleteImage:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Are you sure want to delete this images?" message:@"" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
}

#pragma mark UICollectionView Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [mycaveModel.arrayMyCaveImages count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCaveCollectionViewCell *cell ;
    if (cell == nil)
    {
        UINib *nib = [UINib nibWithNibName:@"MyCaveCollectionViewCell" bundle: nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:@"MyCaveCell"];
    }
    cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"MyCaveCell" forIndexPath:indexPath];
    
    ResponseImageDTO *dict=[mycaveModel.arrayMyCaveImages objectAtIndex:indexPath.row];
    
  //  NSString *imageUrl=[NSString stringWithFormat:@"%@/%@",URL_BASE,dict.imageName];
     NSString *imageUrl=[NSString stringWithFormat:@"%@/%@",URL_IMAGEPATH,dict.imageName];
    [cell.imgViewCollectionView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"mycavePlaceHolder.png"]];
    
    [cell.imgViewCollectionView.layer setBorderColor:[[UIColor darkGrayColor]CGColor]];
    [cell.imgViewCollectionView.layer setBorderWidth:1.0f];
    
    if (dict.unReadLikeCount>0) {
        
        [cell.unreadMsgCount setText:[NSString stringWithFormat:@"%ld",dict.unReadLikeCount]];
        [cell.unreadMsgCount.layer setCornerRadius:cell.unreadMsgCount.frame.size.width/2];
        [cell.unreadMsgCount setClipsToBounds:YES];
        [cell.unreadMsgCount setHidden:NO];
    } else{
        
        [cell.unreadMsgCount setHidden:YES];
        
    }
    
    if(dict.unReadCommentCount == 0)
        [cell.imgCommend setHidden:YES];
    else
        [cell.imgCommend setHidden:NO];
    
    cell.viewTick.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    cell.imgViewTick.center = cell.imgViewCollectionView.center;
    cell.imgViewTick.image = [UIImage imageNamed:@"tick.png"];
    [cell.imgViewTick setAlpha: 1.0f];
    
    NSArray *array;
    if(selectedImages.count > 0) {
        
        NSString *search = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", search];
        array = [selectedImages filteredArrayUsingPredicate: predicate];
        NSLog(@"result: %@", array);
    }
    
    if(array.count == 0)
    cell.viewTick.hidden = YES;
    else
    cell.viewTick.hidden = NO;
    
    if (isDeleteButtonVisible) {
        
        cell.isDeleteModeOn=YES;
        [cell.layer addAnimation:[self getShakeAnimation] forKey:@"shakeAnimation"];
    }else
    {
        [cell setIsDeleteModeOn:NO];
        [cell.layer removeAllAnimations];
    }
    
    UIButton *btn =(UIButton *)[cell viewWithTag:1000];
    
    if (indexpathToDelete!=nil) {
        if (indexpathToDelete.row==indexPath.row) {
            if (isDeleteButtonVisible) {
                
                btn.hidden = YES;
                [btn addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            }
            else{
//                [cell.layer removeAllAnimations];
                  [btn setHidden:YES];
            }
        }else{
            
//            [cell.layer removeAllAnimations];
            btn.hidden=YES;
        }
    }else{
        
//        [cell.layer removeAllAnimations];
        btn.hidden = YES;
    }

    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (isDeleteButtonVisible) {

        MyCaveCollectionViewCell *cell = (MyCaveCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        int value = (int)indexPath.row;
        NSArray *array;
        if(selectedImages.count > 0) {
            
            NSString *search = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self == %@", search];
            array = [selectedImages filteredArrayUsingPredicate: predicate];
        }
       
        if(array.count == 0) {
            
               cell.viewTick.hidden = NO;
               [selectedImages addObject:[NSString stringWithFormat:@"%d",value]];
        
        } else {
            
            cell.viewTick.hidden = YES;
            NSString *search = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
            [selectedImages removeObjectsInArray:[array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self == %@", search]]];

        }
        if(selectedImages.count > 0) {
            
            deleteBtn.hidden = NO;
        } else {
            
            deleteBtn.hidden = YES;
            
            for(int i = 0; i <[mycaveModel.arrayMyCaveImages count]; i++) {
            
                NSIndexPath *lIndexPath = [NSIndexPath indexPathForRow:i inSection:0];

            MyCaveCollectionViewCell *cell = (MyCaveCollectionViewCell *)[collectionView cellForItemAtIndexPath:lIndexPath];
            [cell setIsDeleteModeOn:NO];
            [cell.layer removeAllAnimations];
                
            }
            isDeleteButtonVisible = NO;
        }
        // return;
    } else
    {
    ResponseImageDTO *dict=[mycaveModel.arrayMyCaveImages objectAtIndex:indexPath.row];
    dict.unReadLikeCount=0;
    dict.unReadCommentCount = 0;
        
    [collectionView reloadData];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    PostCommentViewController *postCommentsViewController = [sb instantiateViewControllerWithIdentifier:@"PostCommentViewControllerID"];
    postCommentsViewController.imageDetails=dict;
    postCommentsViewController.isFromHomeFeed=NO;
    [postCommentsViewController commentPostedHandler:^(NSUInteger imageid,NSUInteger count,bool isImageReported) {
        [mycaveModel getMyCaveImages];
    }];
    
    [self.navigationController pushViewController:postCommentsViewController animated:YES ];
    }
}

#pragma mark Shake animation

- (CAAnimation*)getShakeAnimation {
    
    CABasicAnimation *animation;
    CATransform3D transform;
    
    transform = CATransform3DMakeRotation(0.08, 0, 0, 1.0);
    
    animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    animation.toValue = [NSValue valueWithCATransform3D:transform];
    
    animation.autoreverses = YES;
    animation.duration = 0.1;
    animation.repeatCount = HUGE_VALF;
    
    return animation;
    
}


#pragma mark My cave Delegate methods

-(void)updateMyCaveDetails
{
    indexpathToDelete=nil;
    isDeleteButtonVisible = NO;
    [selectedImages removeAllObjects];
    deleteBtn.hidden = YES;
    
    if ([mycaveModel.arrayMyCaveImages count]==0) {
        
        [collectionViewMyCavePhotoGallery setHidden:YES];
    }else{
        [collectionViewMyCavePhotoGallery setHidden:NO];
    }
    
    [collectionViewMyCavePhotoGallery reloadData];
}

-(void)updateLikesCountWith:(NSString *)likesCount AndCommentsCountWith:(NSString *)commentsCount
{
    [lblCommentsCount setText:commentsCount];
    [lblLikesCount setText:likesCount];
}

#pragma mark Touch Events

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint location = [touch locationInView:self.view];
    touchBeginHeight=location.y;
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    if ([touch view] == dragableView) {
        CGPoint location = [touch locationInView:self.view];
        
        if (location.y>40) {
            layoutConstraintDragViewBottom.constant=self.view.frame.size.height-30-location.y;
            layoutConstraintBottomFlipButton.constant=self.view.frame.size.height-30-location.y;
            constriantCollectionViewHeight.constant=self.view.frame.size.height-60-location.y;
            [self.view updateConstraints];
        }
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    if ([touch view] == dragableView) {
        CGPoint location = [touch locationInView:self.view];
        
        if ((touchBeginHeight>location.y && location.y>self.view.frame.size.height/2)|| (touchBeginHeight<location.y && location.y<self.view.frame.size.height/2)) {
            collectionViewState=1;
        }
        else if((touchBeginHeight<location.y && location.y>self.view.frame.size.height/2) ) {
            collectionViewState=0;
        } else {
            collectionViewState=2;
        }
        
        [self btnFlipUpAndDownAction:btnDrag];
    }
}


#pragma mark Scroll view Delegate method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLongPressBegin)
    {
        collectionViewMyCavePhotoGallery.contentOffset=collectionViewContentOffset;
    }
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return NO;
}


#pragma mark Alert Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        
        if(selectedImages.count > 0) {
    
            NSMutableArray *arrayImgId = [[NSMutableArray alloc] init];
            for(int i = 0; i < selectedImages.count; i++) {
                
                NSLog(@"%d",[[selectedImages objectAtIndex:i] intValue]);
        ResponseImageDTO *imageDetails =
                [mycaveModel.arrayMyCaveImages objectAtIndex:[[selectedImages objectAtIndex:i] intValue]];
                [arrayImgId addObject:[NSString stringWithFormat:@"%ld",(long)imageDetails.imageId]];
            }
            if(arrayImgId.count > 0) {
                
                [mycaveModel deleteImageWithImageId:arrayImgId];
            }
        }
    } else
   
    {
        
        [self updateMyCaveDetails];
    }
}


- (IBAction)deleteBtnAction:(id)sender {

    [self deleteImage:nil];

}
#pragma mark Navigation animation

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController*)fromVC toViewController:(UIViewController*)toVC {
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (operation == UINavigationControllerOperationPush) {
        
        appdelegate.push = @"NO";
        appdelegate.popView = @"YES";
        return [[TransitionAnimationHandler alloc] init];
    } else if (operation == UINavigationControllerOperationPop) {
        
        appdelegate.push = @"YES";
        return [[TransitionAnimationHandler alloc] init];
    }
    return nil;
}


#pragma mark Memory warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillDisappear:(BOOL)animated {

    isDeleteButtonVisible = NO;
}


@end
