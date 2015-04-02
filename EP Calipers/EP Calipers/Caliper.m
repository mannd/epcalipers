//
//  Caliper.m
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Caliper.h"
#include <math.h>

#define DELTA 25.0

@implementation Caliper

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
    NSString *text = [self measurement];
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:18.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = (self.direction == Horizontal ? NSTextAlignmentCenter : NSTextAlignmentLeft);

    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:textFont forKey:NSFontAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:self.color forKey:NSForegroundColorAttributeName];

    if (self.direction == Horizontal) {
        // the math here insures that the label doesn't get so small that it can't be read
        [text drawInRect:CGRectMake((self.bar2Position > self.bar1Position ? self.bar1Position - 25: self.bar2Position - 25), self.crossBarPosition - 20,  fmaxf(50.0, fabsf(self.bar2Position - self.bar1Position) + 50), 20)  withAttributes:attributes];
    }
    else {
        [text drawInRect:CGRectMake(self.crossBarPosition + 5, self.bar1Position + (self.bar2Position - self.bar1Position)/2, 140, 20) withAttributes:attributes];
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

- (BOOL)pointNearCrossBar:(CGPoint)p {
    BOOL nearBar = NO;
    if (self.direction == Horizontal) {
        nearBar = (p.x > fmin(self.bar1Position, self.bar2Position) + DELTA && p.x < fmaxf(self.bar2Position, self.bar1Position) - DELTA && p.y > self.crossBarPosition - DELTA && p.y < self.crossBarPosition + DELTA);
    } else {
        nearBar = (p.y > fminf(self.bar1Position, self.bar2Position) + DELTA && p.y < fmaxf(self.bar2Position, self.bar1Position) - DELTA && p.x > self.crossBarPosition - DELTA && p.x < self.crossBarPosition + DELTA);
    }
    return nearBar;
}

- (BOOL)pointNearCaliper:(CGPoint)p {
    return ([self pointNearCrossBar:p] || [self pointNearBar:p forBarPosition:self.bar1Position] || [self pointNearBar:p forBarPosition:self.bar2Position]);
}

@end
