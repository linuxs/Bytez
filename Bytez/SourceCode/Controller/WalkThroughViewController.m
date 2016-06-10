//
//  WalkThroughViewController.m
//  Bytez
//
//  Created by HMSPL on 13/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "WalkThroughViewController.h"
#import "BytezSessionHandler.h"
#import "AppDelegate.h"
#import "WalkThroughChildViewController.h"

@interface WalkThroughViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>

@end

@implementation WalkThroughViewController
{
    
    __weak IBOutlet UIPageControl *pageControl;
    
    __weak IBOutlet UIButton *btnSkip;
    NSArray *imageList;
    UIButton *skipButton;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    imageList=[[NSArray alloc]initWithObjects:@"walk_recent_popular.png",@"walk_homescreen.png",@"walk_swipe_right_comment.png",@"walk_comment_location.png",@"walk_swipe_delete.png",@"walk_mycave_current_location.png",@"walk_myCave_like.png",@"walk_drag_up.png",@"walk_drag_down.png",@"walk_camera_overlay.png",@"walk_camera_swipe.png",@"walk_take_camera_location.png",@"walk_add_caption.png", nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    
    skipButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:@"Skip" forState:UIControlStateNormal];
    [skipButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [skipButton.titleLabel setTextColor:[UIColor whiteColor]];
    [skipButton.layer setBackgroundColor:[UIColor colorWithRed:236.0/255.0 green:84.0/255.0 blue:92.0/255.0 alpha:1.0].CGColor];
    [skipButton.layer setCornerRadius:5.0f];
    skipButton.frame=CGRectMake(self.view.frame.size.width-50, self.view.frame.size.height-32, 45, 30);
    [skipButton addTarget:self action:@selector(btnSkipAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [[self.pageController view] addSubview:skipButton];
    
    WalkThroughChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
//    btnSkip.layer.zPosition=0x1.fffffep+127f;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (WalkThroughChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WalkThroughChildViewController *childViewController=[sb instantiateViewControllerWithIdentifier:@"WalkThroughChildViewControllerID"];
    childViewController.index = index;
    childViewController.imageName=[imageList objectAtIndex:index];
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(WalkThroughChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(WalkThroughChildViewController *)viewController index];
    
    index++;
    
    if (index == 13) {
        
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 13;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

- (IBAction)btnSkipAction:(id)sender {
    [[BytezSessionHandler Instance] setAppTourStatus:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate  setInitializeViewController];
}



@end
