//
//  SettingsViewController.m
//  Bytez
//
//  Created by Jeyaraj on 12/22/14.
//  Copyright (c) 2014 hm. All rights reserved.
//

#import "SettingsViewController.h"
#import "TGSwitch.h"
#import "RadioButtonView.h"
#import <MessageUI/MessageUI.h>
#import "SettingsModel.h"
#import "AlertConstants.h"
#import "StringConstants.h"
#import "BytezSessionHandler.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface SettingsViewController ()<SettingsModelDelegate,MFMailComposeViewControllerDelegate>

@end

@implementation SettingsViewController
{
    __weak IBOutlet UIView *viewLocationRadiusRadio;
    __weak IBOutlet UIView *viewPushNotificationSwitch;
    __weak IBOutlet UIView *constraintSettingsContainerHeight;
    __weak IBOutlet UIView *viewTermsAndConditionsContainer;
    
    __weak IBOutlet NSLayoutConstraint *constraintTermsLeft;
    __weak IBOutlet NSLayoutConstraint *constraintRadiusViewHeigh;
    __weak IBOutlet NSLayoutConstraint *constaintSettingsOptionContainer;
    __weak IBOutlet NSLayoutConstraint *constraintTermsViewTop;
    __weak IBOutlet NSLayoutConstraint *constrainBGViewColor;
    __weak IBOutlet NSLayoutConstraint *constrainTopSpaceForPushBtn;
    
    __weak IBOutlet UILabel *lblTermOne;
    __weak IBOutlet UILabel *lblTermTwo;
    __weak IBOutlet UILabel *lblTermThree;
    __weak IBOutlet UILabel *lblTermFour;
    __weak IBOutlet UILabel *lblTermFive;
    __weak IBOutlet UILabel *milesLbl;
    __weak IBOutlet UISwitch *uiSwitchView;
    
    SettingsModel *model;
    RadioButtonView *milesRadioButton;
    TGSwitch *tgSwitch;
    
    BOOL isRadiusViewHidden;
    BOOL isPushNotificationOff;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    model=[SettingsModel new];
    model.delegate=self;
    
    tgSwitch = [[TGSwitch alloc] initWithFrame:viewPushNotificationSwitch.bounds];
    tgSwitch.onText = @"On";
    tgSwitch.offText = @"Off";
    tgSwitch.on = YES;
    [viewPushNotificationSwitch addSubview:tgSwitch];
    
    
    UISwipeGestureRecognizer *gestureR = [[UISwipeGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(DismissTermsAndConditions:)];
    [gestureR setDirection:UISwipeGestureRecognizerDirectionRight];
    [viewTermsAndConditionsContainer addGestureRecognizer:gestureR];
    
    milesRadioButton=[[RadioButtonView alloc]init];
    milesRadioButton.frame=viewLocationRadiusRadio.bounds;
   
    [milesRadioButton configureWithOptions:[NSArray arrayWithObjects:@"1 mile",@"3 miles",@"5 miles", nil] selectionHandler:^(NSUInteger index)
     {
         int value;
         switch (index) {
             case 0:
                 [model saveImageRadius:@"1"];
                 value = 1;
                 break;
             case 1:
                 [model saveImageRadius:@"3"];
                 value = 3;
                 break;
             case 2:
                 [model saveImageRadius:@"5"];
                 value = 5;
                 break;
             default:
                 break;
         }
         if(value == 1){
         milesLbl.text = [NSString stringWithFormat:@"%d mile", value];
         self.milesString=milesLbl.text;
         }
         else{
          milesLbl.text = [NSString stringWithFormat:@"%d miles", value];
         self.milesString=milesLbl.text;
         }
     }];
    
    [viewLocationRadiusRadio addSubview:milesRadioButton];
    //isRadiusViewHidden=YES;
    //[self btnLocationRadiusChange:nil];
    isRadiusViewHidden=NO;
    constrainBGViewColor.constant-=55;
    constraintRadiusViewHeigh.constant=0;
    constaintSettingsOptionContainer.constant-=50;
    constrainTopSpaceForPushBtn.constant-=1;
    [self.view layoutIfNeeded];
    
    constraintTermsLeft.constant=self.view.frame.size.width;
    [self.view layoutIfNeeded];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[[BytezSessionHandler Instance] bytezRadius] isEqualToString:@"1"])
    milesLbl.text = [NSString stringWithFormat:@"%@ mile",  [[BytezSessionHandler Instance] bytezRadius]];
    else
    milesLbl.text = [NSString stringWithFormat:@"%@ miles",  [[BytezSessionHandler Instance] bytezRadius]];
        

}


-(void)viewDidDisappear:(BOOL)animated
{
    if (tgSwitch.on) {
        [model updatePushNotificationStatus:YES];
    }else
    {
        [model updatePushNotificationStatus:NO];
    }
}

- (IBAction)btnTermsAndConditionsAction:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        constraintTermsLeft.constant=0;
        [self.view layoutIfNeeded];
    }];
}

-(void)DismissTermsAndConditions:(id)sender
{
#if 1
    [UIView animateWithDuration:0.5 animations:^{
        constraintTermsLeft.constant=self.view.frame.size.width;
        [self.view layoutIfNeeded];
        
    }];
#endif
}

- (IBAction)btnLocationRadiusChange:(id)sender {
   
    if (isRadiusViewHidden) {
       
        [UIView animateWithDuration:0.5 animations:^{
            isRadiusViewHidden=NO;
            constrainBGViewColor.constant-=55;
            constraintRadiusViewHeigh.constant=0;
            constaintSettingsOptionContainer.constant-=50;
            constrainTopSpaceForPushBtn.constant-=1;
            [self.view layoutIfNeeded];
        }];
    } else
    {
        [UIView animateWithDuration:0.5 animations:^{
            isRadiusViewHidden=YES;
            constrainTopSpaceForPushBtn.constant+=1;
            constraintRadiusViewHeigh.constant=50;
            constrainBGViewColor.constant+=55;
           constaintSettingsOptionContainer.constant=320;
            [self.view layoutIfNeeded];
        }];
    }
}


- (IBAction)btnShareAppAction:(id)sender {
    
    NSArray *activityItems = [NSArray arrayWithObjects: CONSTANT_SHARE_APP_CONTENT, nil];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
        
        activityController.popoverPresentationController.sourceView = self.view;
    }
   
    [self presentViewController:activityController animated:YES completion:nil];
}


- (IBAction)btnReportAFuntionAction:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[CONSTANT_REPORT_EMAIL_ID]];
        [composeViewController setSubject:CONSTANT_REPORT_SUBJECT];
        
        [self presentViewController:composeViewController animated:YES completion:nil];
    }else{
        
        UIAlertView *alertViewChangeName=[[UIAlertView alloc]initWithTitle:ALERT_ADD_ACCOUNT_IN_SETTINGS message:@"" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertViewChangeName show];
    }
}

#pragma mark Settings model Delegate

-(void)updateSettingsScreenWith:(NSInteger)mile pushNotification:(BOOL)status {
 
}

#pragma mark Mail Composer delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)pushNotificationSwith:(id)sender {
    
    if(uiSwitchView.on == YES)
        tgSwitch.on = YES;
    else
        tgSwitch.on = NO;
    
}
@end
