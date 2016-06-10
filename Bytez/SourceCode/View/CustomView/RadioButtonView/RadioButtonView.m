//
//  RadioButtonView.m
//  TG_POC
//
//  Created by hakuna on 26/09/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RadioButtonView.h"
#import "BytezSessionHandler.h"

typedef void (^SelectionHandler)(NSUInteger index);

@interface OptionView : UIView

@property (nonatomic, assign) BOOL selected;
@property (nonatomic, copy) NSString *optionText;

@end

@implementation OptionView
{
    UIButton *_button;
    UIView *_viewRound;
    UILabel *_lblOption;
    BOOL isSelect;
    SelectionHandler _selectionHandler;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self configureView];
    }
    return self;
}

- (void) configureView
{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.frame = self.bounds;
    _button.backgroundColor = [UIColor clearColor];
    [_button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_button];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    if (screenWidth==320) {
         _viewRound = [[UIView alloc] initWithFrame:CGRectMake(0,0,16.5,16.5)];
    }else{
    _viewRound = [[UIView alloc] initWithFrame:CGRectMake(0,0,18,18)];
    }
    _viewRound.layer.cornerRadius = _viewRound.bounds.size.height / 2.0;
    _viewRound.layer.borderColor = [UIColor grayColor].CGColor;
//    _viewRound.center=CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//    _viewRound.layer.borderWidth = 1.0;
    _viewRound.backgroundColor = [UIColor redColor];
    _viewRound.center = CGPointMake(CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds));
    [_viewRound setUserInteractionEnabled:NO];
    [self addSubview:_viewRound];
    
    _lblOption = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 50, self.bounds.size.height)];
    _lblOption.textColor = [UIColor lightGrayColor];
    _lblOption.backgroundColor = [UIColor clearColor];
    _lblOption.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    [self addSubview:_lblOption];

}

- (void) setOptionText:(NSString *)optionText
{
    _lblOption.text = optionText;
}

- (void) setSelected:(BOOL)selected
{
    _viewRound.backgroundColor = selected ? [UIColor colorWithPatternImage:[UIImage imageNamed:@"on_icon.png"]] : [UIColor colorWithPatternImage:[UIImage imageNamed:@"off_icon.png"]];
}

- (void) btnClicked:(UIButton *)button
{
    if (nil != _selectionHandler) {
        _selectionHandler(self.tag);
    }
}

- (void) selectionHandler:(void(^)(NSUInteger index))handler
{
    _selectionHandler = handler;

}

@end

@implementation RadioButtonView
{
    SelectionHandler _selectionHandler;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) configureWithOptions:(NSArray *)options selectionHandler:(void(^)(NSUInteger index))handler
{
    _selectionHandler = handler;
    
    CGRect rectOption = CGRectMake(40, 0, self.bounds.size.width / (float) [options count], self.bounds.size.height);
    
    for (int  i = 0; i < [options count]; i++) {
        OptionView *option = [[OptionView alloc] initWithFrame:rectOption];
        //option.backgroundColor = [UIColor colorWithRed:(arc4random() % 100) / 100.0 green:(arc4random() % 100) / 100.0 blue:(arc4random() % 100) / 100.0 alpha:1.0];
        option.optionText = [options objectAtIndex:i];
        int value = [[[BytezSessionHandler Instance] bytezRadius] intValue];
        if(value == 1)
            value = 0;
            else if(value == 3)
                value = 1;
            else value = 2;
        option.selected = (value == i) ? YES : NO;
        option.tag = i + 1;
        [option selectionHandler:^(NSUInteger index) {
            if (!option.selected) {
                option.selected = YES;
            }
            for (OptionView *tempOption in [self subviews]) {
                if (tempOption.tag != index) {
                    tempOption.selected = NO;
                }
            }
            if (nil != _selectionHandler) {
                _selectionHandler(index - 1);
            }
        }];
        [self addSubview:option];
        
        rectOption.origin.x += rectOption.size.width - 20;
    }
    
}

@end
