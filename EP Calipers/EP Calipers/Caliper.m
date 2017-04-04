//
//  Caliper.m
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Caliper.h"
#include <math.h>

#define DELTA 20.0
#define CROSSBAR @"Crossbar"
#define CROSSBAR_SMALL @"Xbar"
#define LEFT_BAR @"Left bar"
#define LEFT_BAR_SMALL @"Lbar"
#define RIGHT_BAR @"Right bar"
#define RIGHT_BAR_SMALL @"Rbar"
#define UP_BAR @"Upper bar"
#define UP_BAR_SMALL @"Ubar"
#define DOWN_BAR @"Bottom bar"
#define DOWN_BAR_SMALL @"Bbar"
#define APEX_BAR @"Apex"

@implementation Caliper
{
    NSInteger tmpLineWidth; // for "shaking" caliper
}

- (instancetype)initWithDirection:(CaliperDirection)direction bar1Position:(float)bar1Position bar2Position:(float)bar2Position
                 crossBarPosition:(float)crossBarPosition {
    self = [super init];
    if (self) {
        self.direction = direction;
        self.bar1Position = bar1Position;
        self.bar2Position = bar2Position;
        self.crossBarPosition = crossBarPosition;
        self.unselectedColor = [UIColor blueColor];
        self.selectedColor = [UIColor redColor];
        self.color = [UIColor blueColor];
        self.lineWidth = 2;
        self.selected = NO;
        self.textFont = [UIFont fontWithName:@"Helvetica" size:18.0];
        self.paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        self.attributes = [[NSMutableDictionary alloc] init];
        self.roundMsecRate = YES;
    }
    return self;
}

- (instancetype)init {
    return [self initWithDirection:Horizontal bar1Position:0 bar2Position:0 crossBarPosition:100];
}

// set slightly different positions for each new caliper
- (void)setInitialPositionInRect:(CGRect)rect {
    static float differential = 0;
    if (self.direction == Horizontal) {
        self.bar1Position = (rect.size.width/3) + differential;
        self.bar2Position = ((2 * rect.size.width)/3) + differential;
        self.crossBarPosition = (rect.size.height/2) + differential;
    } else {
        self.bar1Position = (rect.size.height/3) + differential;
        self.bar2Position = ((2 * rect.size.height)/3) + differential;
        self.crossBarPosition = (rect.size.width/2) + differential;
    }
    differential += 15;
    if (differential > 80) {
        differential = 0;
    }
}

- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, self.lineWidth);
    
    if (self.direction == Horizontal) {
        self.crossBarPosition = fminf(self.crossBarPosition, rect.size.height - DELTA);
        self.crossBarPosition = fmaxf(self.crossBarPosition, DELTA);
        self.bar1Position = fminf(self.bar1Position, rect.size.width - DELTA);
        self.bar2Position = fmaxf(self.bar2Position, DELTA);
        CGContextMoveToPoint(context, self.bar1Position, 0);
        CGContextAddLineToPoint(context, self.bar1Position, rect.size.height);
        CGContextMoveToPoint(context, self.bar2Position, 0);
        CGContextAddLineToPoint(context, self.bar2Position, rect.size.height);
        CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
        CGContextAddLineToPoint(context, self.bar1Position, self.crossBarPosition);
        
    } else {    // vertical caliper
        self.crossBarPosition = fminf(self.crossBarPosition, rect.size.width - DELTA);
        self.crossBarPosition = fmaxf(self.crossBarPosition, DELTA);
        self.bar1Position = fminf(self.bar1Position, rect.size.height - DELTA);
        self.bar2Position = fmaxf(self.bar2Position, DELTA);
        CGContextMoveToPoint(context, 0, self.bar1Position);
        CGContextAddLineToPoint(context, rect.size.width, self.bar1Position);
        CGContextMoveToPoint(context, 0, self.bar2Position);
        CGContextAddLineToPoint(context, rect.size.width, self.bar2Position);
        CGContextMoveToPoint(context, self.crossBarPosition, self.bar2Position);
        CGContextAddLineToPoint(context, self.crossBarPosition, self.bar1Position);
    }
    CGContextStrokePath(context);
    [self caliperText];
}

- (void)caliperText {
    NSString *text = [self measurement];
    self.paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.paragraphStyle.alignment = (self.direction == Horizontal ? NSTextAlignmentCenter : NSTextAlignmentLeft);
    
    [self.attributes setObject:self.textFont forKey:NSFontAttributeName];
    [self.attributes setObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self.attributes setObject:self.color forKey:NSForegroundColorAttributeName];
    
    if (self.direction == Horizontal) {
        // the math here insures that the label doesn't get so small that it can't be read
        [text drawInRect:CGRectMake((self.bar2Position > self.bar1Position ? self.bar1Position - 25: self.bar2Position - 25), self.crossBarPosition - 20,  fmaxf(100.0, fabsf(self.bar2Position - self.bar1Position) + 50), 20)  withAttributes:self.attributes];
    }
    else {
        [text drawInRect:CGRectMake(self.crossBarPosition + 5, self.bar1Position + (self.bar2Position - self.bar1Position)/2, 140, 20) withAttributes:self.attributes];
    }
}

// returns significant bar coordinate depending on direction of caliper
- (float)barCoord:(CGPoint)p {
    return (self.direction == Horizontal ? p.x : p.y);
}

// returns CGRect containing caliper
- (CGRect)rect:(CGRect)containerRect {
    if (self.direction == Horizontal) {
        return CGRectMake(self.bar1Position, containerRect.origin.y, self.bar2Position - self.bar1Position, containerRect.size.height);
    } else { // vertical caliper
        return CGRectMake(0, self.bar1Position, containerRect.size.width, self.bar2Position - self.bar1Position);
    }
}

- (NSString *)measurement {
    NSString *s = [NSString stringWithFormat:@"%.4g %@", [self calibratedResult], self.calibration.units];
    return s;
}

- (double)calibratedResult {
    double result = [self intervalResult];
    if (result != 0 && self.calibration.displayRate && self.calibration.canDisplayRate) {
        result = [self rateResult:result];
    }
    else if (self.roundMsecRate && self.calibration.unitsAreMsec) {
        result = round(result);
    }
    return result;
}

- (double)intervalResult {
    return [self points] * self.calibration.multiplier;
}

- (double)rateResult:(double)interval {
    if (interval != 0) {
        if (self.calibration.unitsAreMsec) {
            interval = 60000.0 / interval;
        }
        if (self.calibration.unitsAreSeconds) {
            interval = 60.0 / interval;
        }
    }
    if (self.roundMsecRate) {
        interval = round(interval);
    }
    return interval;
}

- (double)intervalInSecs:(double)interval {
    if (self.calibration.unitsAreSeconds) {
        return interval;
    }
    else {
        return interval / 1000;
    }
}

- (double)intervalInMsec:(double)interval {
    if (self.calibration.unitsAreMsec) {
        return interval;
    }
    else {
        return 1000 * interval;
    }
}

- (float) points {
    return self.bar2Position - self.bar1Position;
}

- (float)valueInPoints {
    return self.bar2Position - self.bar1Position;
}

- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition {
    return [self barCoord:p] > barPosition - DELTA && [self barCoord:p] < barPosition + DELTA;
}

- (BOOL)pointNearBar1:(CGPoint)p {
    return [self pointNearBar:p forBarPosition:self.bar1Position];
}

- (BOOL)pointNearBar2:(CGPoint)p {
    return [self pointNearBar:p forBarPosition:self.bar2Position];
}

- (BOOL)pointNearCrossBar:(CGPoint)p {
    BOOL nearBar = NO;
    float delta = DELTA + 5.0f; // make cross bar delta a little bigger
    // avoid overlapping deltas inside calipers that prevent crossbar touch when short interval
    if (self.direction == Horizontal) {
        nearBar = (p.x > fminf(self.bar1Position, self.bar2Position) && p.x < fmaxf(self.bar2Position, self.bar1Position) && p.y > self.crossBarPosition - delta && p.y < self.crossBarPosition + delta);
    } else {
        nearBar = (p.y > fminf(self.bar1Position, self.bar2Position) && p.y < fmaxf(self.bar2Position, self.bar1Position) && p.x > self.crossBarPosition - delta && p.x < self.crossBarPosition + delta);
    }
    return nearBar;
}

- (BOOL)pointNearCaliper:(CGPoint)p {
    return ([self pointNearCrossBar:p] || [self pointNearBar:p forBarPosition:self.bar1Position] || [self pointNearBar:p forBarPosition:self.bar2Position]);
}

- (CaliperComponent)getCaliperComponent:(CGPoint)p{
    if ([self pointNearCrossBar:p]) {
        return Crossbar;
    }
    else if ([self pointNearBar1:p]) {
        return Bar1;
    }
    else if ([self pointNearBar2:p]) {
        return Bar2;
    }
    else {
        return None;
    }
}

- (NSString *)getComponentName:(CaliperComponent)component smallSize:(BOOL)smallSize {
    NSString *crossBarName = smallSize ? CROSSBAR_SMALL : CROSSBAR;
    NSString *leftBarName = smallSize ? LEFT_BAR_SMALL : LEFT_BAR;
    NSString *rightBarName = smallSize ? RIGHT_BAR_SMALL : RIGHT_BAR;
    NSString *upBarName = smallSize ? UP_BAR_SMALL : UP_BAR;
    NSString *downBarName = smallSize ? DOWN_BAR_SMALL : DOWN_BAR;
    switch (component) {
        case Crossbar:
            return (self.isAngleCaliper ? APEX_BAR : crossBarName);
            break;
        case Bar1:
            return (self.direction == Horizontal ? leftBarName : upBarName);
            break;
        case Bar2:
            return (self.direction == Horizontal ? rightBarName : downBarName);
            break;
        default:
            return @"";
            break;
    }
}

- (void)moveCrossBar:(CGPoint)delta {
    self.bar1Position += delta.x;
    self.bar2Position += delta.x;
    self.crossBarPosition += delta.y;
}

- (void)moveBar1:(CGPoint)delta forLocation:(CGPoint)location {
    self.bar1Position += delta.x;
}

- (void)moveBar2:(CGPoint)delta forLocation:(CGPoint)location {
    self.bar2Position += delta.x;
}

- (void)moveBarInDirection:(MovementDirection)direction distance:(CGFloat)delta forComponent:(CaliperComponent)component {
    switch (component) {
        case Bar1:
            self.bar1Position += delta;
            break;
        case Bar2:
            self.bar2Position += delta;
            break;
        case Crossbar:
            [self moveCrossbarInDirection:direction distance:delta];
            break;
        default:
            break;
    }
}

- (void)moveCrossbarInDirection:(MovementDirection)direction distance:(CGFloat)delta {
    if (direction == Up || direction == Down) {
        self.crossBarPosition += delta;
    }
    else {
        self.bar1Position += delta;
        self.bar2Position += delta;
    }
}

- (BOOL)requiresCalibration {
    return YES;
}

- (BOOL)isAngleCaliper {
    return NO;
}

@end
