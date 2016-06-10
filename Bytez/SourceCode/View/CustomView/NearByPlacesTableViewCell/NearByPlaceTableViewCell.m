//
//  NearByPlaceTableViewCell.m
//  Bytez
//
//  Created by HMSPL on 06/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import "NearByPlaceTableViewCell.h"

@implementation NearByPlaceTableViewCell
{
    
    __weak IBOutlet UILabel *lblAddress;
    __weak IBOutlet UILabel *lblPlaceName;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPlaceDetail:(NearByPlacesResponseDTO *)placeDetail
{
    [lblPlaceName setText:placeDetail.placeName];
    [lblAddress setText:placeDetail.vicinity];
}

@end
