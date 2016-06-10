//
//  WalkThroughChildViewController.h
//  Bytez
//
//  Created by HMSPL on 13/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WalkThroughChildViewController : UIViewController

@property(assign,nonatomic) NSInteger index;
@property (strong,nonatomic) NSString *imageName;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewWalkthrough;

@end
