//
//  NearByPlacesViewController.h
//  Bytez
//
//  Created by HMSPL on 05/01/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationUpdateHandler.h"
#import "NearByPlacesResponseDTO.h"

@protocol NearByPlacesViewControllerDelegate <NSObject>

@required

-(void) selectedLocation:(NearByPlacesResponseDTO*)location;

@end

@interface NearByPlacesViewController : LocationUpdateHandler<UITableViewDataSource,UITableViewDelegate>

@property(assign, nonatomic) id<NearByPlacesViewControllerDelegate> delegate;

@end
