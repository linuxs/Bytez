//
//  MyCaveCollectionViewCell.h
//  Bytez
//
//  Created by HMSPL on 26/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCaveCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgViewCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnDeleteAction;
@property (weak, nonatomic) IBOutlet UILabel *unreadMsgCount;
@property (assign, nonatomic) BOOL isDeleteModeOn;

@property (weak, nonatomic) IBOutlet UIView *viewTick;
@property (weak, nonatomic) IBOutlet UIImageView *imgViewTick;
@property (weak, nonatomic) IBOutlet UIImageView *imgCommend;


@end
