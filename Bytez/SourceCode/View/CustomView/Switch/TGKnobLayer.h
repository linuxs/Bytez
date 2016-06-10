//
//  TGKnobLayer.h
//  TGSwitch
//
//  Created by hakuna on 22/08/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class TGSwitch;

@interface TGKnobLayer : CALayer

@property (nonatomic) BOOL highlighted;
@property (weak) TGSwitch *tgSwitch;

@end
