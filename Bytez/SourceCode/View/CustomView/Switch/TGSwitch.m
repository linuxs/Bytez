//
//  TGSwitch.m
//  TGSwitch
//
//  Created by hakuna on 22/08/13.
//  Copyright (c) 2013 hakuna matata. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TGSwitch.h"
#import "TGTrackLayer.h"
#import "TGKnobLayer.h"

@implementation TGSwitch
{
    TGTrackLayer *_trackLayer;
    TGKnobLayer *_knobLayer;
    
    UILabel *_rightText;
    UILabel *_leftText;
    
    float _knobWidth;
    float _trackLength;
    CGPoint _previousTouchPoint;
    
    float dx;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        dx = 1.0;
        _on = NO;
        _bgColor = [UIColor whiteColor];
        _knobColor = [UIColor lightGrayColor];
        _onText = @"ON";
        _offText = @"OFF";
        
        _trackLayer = [TGTrackLayer layer];
        _trackLayer.backgroundColor = _bgColor.CGColor;
        _trackLayer.cornerRadius = 5.0;
        [self.layer addSublayer:_trackLayer];
        
        _leftText = [[UILabel alloc] init];
        _leftText.textColor = [UIColor blackColor];
        _leftText.text = self.onText;
//        _leftText.font = [UIFont fontWithName:FONT_HELVETICA_LT_COM_BOLD size:14.0];
        _leftText.textAlignment = NSTextAlignmentCenter;//UITextAlignmentCenter;
        _leftText.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftText];

        _rightText = [[UILabel alloc] init];
        _rightText.textColor = [UIColor blackColor];
        _rightText.text = self.offText;
//        _rightText.font = [UIFont fontWithName:FONT_HELVETICA_LT_COM_BOLD size:14.0];
        _rightText.textAlignment = NSTextAlignmentCenter;//UITextAlignmentCenter;
        _rightText.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightText];
        
        _knobLayer = [TGKnobLayer layer];
        _knobLayer.borderWidth=0.5;
        _knobLayer.borderColor=[UIColor darkGrayColor].CGColor;
        _knobLayer.backgroundColor = _knobColor.CGColor;
        _knobLayer.cornerRadius = 5.0;
        [self.layer addSublayer:_knobLayer];
        
        [self setLayerFrames];
    }
    return self;
}



- (void) setLayerFrames
{
    _trackLayer.frame = CGRectInset(self.bounds, dx, dx);
    _trackLength = _trackLayer.bounds.size.width;
    
    _leftText.frame = CGRectMake(_trackLayer.frame.origin.x, dx, _trackLayer.frame.size.width / 2.0, _trackLayer.frame.size.height);
    _rightText.frame = CGRectMake(_trackLayer.frame.origin.x + _trackLayer.frame.size.width / 2.0, dx, _trackLayer.frame.size.width / 2.0, _trackLayer.frame.size.height);
    
    float knobHeight = _trackLayer.bounds.size.height - (2 * dx);
    _knobWidth = (_trackLayer.bounds.size.width / 2) - (2 * dx);
    _knobLayer.frame = CGRectMake(2 * dx, 2 * dx, _knobWidth, knobHeight);
    
    [_trackLayer setNeedsDisplay];
    [_leftText setNeedsDisplay];
    [_rightText setNeedsDisplay];
    [_knobLayer setNeedsDisplay];
}

#pragma mark -Accessor Methods

- (void) setOnText:(NSString *)onText
{
    _onText = onText;
    _leftText.text = onText;
}

- (void) setOffText:(NSString *)offText
{
    _offText = offText;
    _rightText.text = offText;
}

- (void) setOn:(BOOL)on
{
    _on = on;
    
    CGRect rect = _knobLayer.frame;
    
    if (on) {
        rect.origin.x = _trackLayer.bounds.size.width / 2.0 + 2 * dx;
    }
    else {
        rect.origin.x = 2 * dx;
    }
    
    _knobLayer.frame = rect;
    [_knobLayer setNeedsDisplay];
}

#pragma mark - 

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _previousTouchPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_knobLayer.frame, _previousTouchPoint)) {
        _knobLayer.highlighted = YES;
        [_knobLayer setNeedsDisplay];
    }
    
    return YES;
}

- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    float delta = touchPoint.x - _previousTouchPoint.x;
    _previousTouchPoint = touchPoint;
    CGRect rect = _knobLayer.frame;
    
    if (_knobLayer.highlighted) {
        rect.origin.x += delta;
        if (rect.origin.x < 2 * dx) {
            rect.origin.x = 2 * dx;
        }
        if (rect.origin.x > (_trackLayer.bounds.size.width/ 2.0 + 2 * dx)) {
            rect.origin.x = _trackLayer.bounds.size.width/ 2.0 + 2 * dx;
        }
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    _knobLayer.frame = rect;
    [_knobLayer setNeedsDisplay];
    
    [CATransaction commit];
    
    return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _knobLayer.highlighted = NO;
    CGRect rect = _knobLayer.frame;

    BOOL state = NO;

    CGPoint touchPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_knobLayer.frame, touchPoint)) {
        if((_knobLayer.frame.origin.x + (_knobLayer.frame.size.width / 2.0)) > (_trackLayer.frame.origin.x + (_trackLayer.frame.size.width / 2.0))) {
            rect.origin.x = _trackLayer.bounds.size.width / 2.0 + 2 * dx;
            state = YES;
        }
        else {
            rect.origin.x = 2 * dx;
            state = NO;
        }
    }
    else {
        if (self.on) {
            rect.origin.x = 2 * dx;
            state = NO;
        }
        else {
            rect.origin.x = _trackLayer.bounds.size.width / 2.0 + 2 * dx;
            state = YES;
        }
    }
    
    if (state != self.on) {
        self.on = state;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [CATransaction setAnimationDuration:0.2];
    
    _knobLayer.frame = rect;
    [_knobLayer setNeedsDisplay];
    
    [CATransaction commit];
}

@end
