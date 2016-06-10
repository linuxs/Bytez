//
//  NearByPlaceTableViewCell.h
//  Bytez
//
//  Created by HMSPL on 06/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NearByPlacesResponseDTO.h"

@interface NearByPlaceTableViewCell : UITableViewCell

@property(strong,nonatomic) NearByPlacesResponseDTO *placeDetail;
@end
