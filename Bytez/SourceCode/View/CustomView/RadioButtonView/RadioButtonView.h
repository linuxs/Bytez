//
//  RadioButtonView.h
//  TG_POC
//
//  Created by hakuna on 26/09/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RadioButtonView : UIView

- (void) configureWithOptions:(NSArray *)options selectionHandler:(void(^)(NSUInteger index))handler;

@end
