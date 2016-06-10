//
//  ReportImagePopover.h
//  Bytez
//
//  Created by HMSPL on 22/02/15.
//  Copyright (c) 2015 hm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ReportImagePopoverPosition) {
    ReportImagePopoverPositionUp = 1,
    ReportImagePopoverPositionDown,
};

typedef NS_ENUM(NSUInteger, ReportImagePopoverMaskType) {
    ReportImagePopoverMaskTypeBlack,
    ReportImagePopoverMaskTypeNone,
};


@interface ReportImagePopover : UIView

+ (instancetype)popover;

@property (nonatomic, assign, readonly) ReportImagePopoverPosition popoverPosition;

@property (nonatomic, assign) CGSize arrowSize;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) CGFloat animationIn;

@property (nonatomic, assign) CGFloat animationOut;

@property (nonatomic, assign) BOOL animationSpring;

@property (nonatomic, assign) ReportImagePopoverMaskType maskType;

@property (nonatomic, assign) CGFloat betweenAtViewAndArrowHeight;

@property (nonatomic, assign) CGFloat sideEdge;

@property (nonatomic, copy) dispatch_block_t didShowHandler;

@property (nonatomic, copy) dispatch_block_t didDismissHandler;

- (void)showAtPoint:(CGPoint)point popoverPostion:(ReportImagePopoverPosition)position withContentView:(UIView *)contentView inView:(UIView *)containerView;

- (void)showAtView:(UIView *)atView popoverPostion:(ReportImagePopoverPosition)position withContentView:(UIView *)contentView inView:(UIView *)containerView;

- (void)showAtView:(UIView *)atView withContentView:(UIView *)contentView inView:(UIView *)containerView;

- (void)showAtView:(UIView *)atView withContentView:(UIView *)contentView;

- (void)dismiss;


@end

