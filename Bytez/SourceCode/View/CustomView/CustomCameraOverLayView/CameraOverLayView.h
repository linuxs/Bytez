//
//  CameraOverLayView.h
//  Bytez
//
//  Created by HMSPL on 07/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraOverLayView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnSwapCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnMyCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnCapture;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;

-(void) startAnimating:(BOOL) isShown;

@end
