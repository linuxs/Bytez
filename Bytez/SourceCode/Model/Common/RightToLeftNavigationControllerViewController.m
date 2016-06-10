//
//  RightToLeftNavigationControllerViewController.m
//  Bytez
//
//  Created by HMSPL on 02/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "RightToLeftNavigationControllerViewController.h"

@interface RightToLeftNavigationControllerViewController ()

@end

@implementation RightToLeftNavigationControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{

    [super pushViewController:viewController animated:animated];
}
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *firstViewController = [super popViewControllerAnimated:animated];
    return firstViewController;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
