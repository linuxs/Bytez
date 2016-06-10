//
//  ViewController.m
//  Bytez
//
//  Created by Jeyaraj on 12/15/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "ViewController.h"
#import "APIHandler.h"
#import "BytezSessionHandler.h"
#import "AppDelegate.h"
#import "WalkThroughViewController.h"

@interface ViewController ()

@end

@implementation ViewController

{
    BOOL ischeckBoxClicked;
    __weak IBOutlet UILabel *lblTermsOne;
    __weak IBOutlet UIScrollView *scrollViewContainer;
    __weak IBOutlet UILabel *lblTermsTwo;
    __weak IBOutlet UILabel *lblTermsThree;
    __weak IBOutlet UILabel *lblTermsFour;
    __weak IBOutlet UILabel *lblTermsFive;
    __weak IBOutlet UIImageView *imgViewTickMark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    scrollViewContainer.contentSize=CGSizeMake(scrollViewContainer.frame.size.width,640);
    
//    NSString *fontname =@"Raleway-Light";
//    lblTermsOne.font = [UIFont fontWithName:fontname size:14];
//    lblTermsTwo.font = [UIFont fontWithName:fontname size:14];
//    lblTermsThree.font = [UIFont fontWithName:fontname size:14];
//    lblTermsFour.font = [UIFont fontWithName:fontname size:14];
//    lblTermsFive.font = [UIFont fontWithName:fontname size:14];
    
}

- (IBAction)btnCheckboxClick:(id)sender {
    
    if (ischeckBoxClicked) {
        ischeckBoxClicked=false;
        [imgViewTickMark setImage:[UIImage imageNamed:@"terms_uncheck.png"]];
    }
    else {
        ischeckBoxClicked=YES;
        [imgViewTickMark setImage:[UIImage imageNamed:@"terms_check.png"]];
    }
}

- (IBAction)btnAgreeAction:(id)sender {
    if (!ischeckBoxClicked) {
        return;
    }
    
    [[BytezSessionHandler Instance] setTermsAndConditionsStatus:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WalkThroughViewController *initalViewController=[sb instantiateViewControllerWithIdentifier:@"WalkThroughViewControllerID"];
    [self.navigationController pushViewController:initalViewController animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
