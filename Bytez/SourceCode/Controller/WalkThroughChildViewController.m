//
//  WalkThroughChildViewController.m
//  Bytez
//
//  Created by HMSPL on 13/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "WalkThroughChildViewController.h"

@interface WalkThroughChildViewController ()

@end

@implementation WalkThroughChildViewController
{
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imgViewWalkthrough setImage:[UIImage imageNamed:self.imageName]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
