//
//  Caliper.m
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Caliper.h"

@implementation Caliper

- (instancetype)initWithDirection:(CaliperDirection)direction bar1Position:(float)bar1Position bar2Position:(float)bar2Position
                 crossBarPosition:(float)crossBarPosition {
    self = [super init];
    if (self) {
        self.direction = direction;
        self.bar1Position = bar1Position;
        self.bar2Position = bar2Position;
    }
    self.color = [UIColor blackColor];
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
    differential += 10;
    if (differential > 50) {
        differential = 0;
    }
}

- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect {
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, 1);

    if (self.direction == Horizontal) {
        CGContextMoveToPoint(context, self.bar1Position, 0);
        CGContextAddLineToPoint(context, self.bar1Position, rect.size.height);
        
        CGContextMoveToPoint(context, self.bar2Position, 0);
        CGContextAddLineToPoint(context, self.bar2Position, rect.size.height);
        CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
        CGContextAddLineToPoint(context, self.bar1Position, self.crossBarPosition);
        
    } else {    // vertical caliper, bar2 on the bottom
        CGContextMoveToPoint(context, 0, self.bar1Position);
        CGContextAddLineToPoint(context, rect.size.width, self.bar1Position);
        CGContextMoveToPoint(context, 0, self.bar2Position);
        CGContextAddLineToPoint(context, rect.size.width, self.bar2Position);
        CGContextMoveToPoint(context, self.crossBarPosition, self.bar2Position);
        CGContextAddLineToPoint(context, self.crossBarPosition, self.bar1Position);
    }
    CGContextStrokePath(context);
    NSString *text = [self measurement];
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size:15.0];
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:textFont forKey:NSFontAttributeName];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:self.color forKey:NSForegroundColorAttributeName];


    [text drawInRect:CGRectMake(self.bar1Position, self.crossBarPosition - 20, self.bar2Position - self.bar1Position, 20)  withAttributes:attributes];
}

// returns CGRect containing caliper
- (CGRect)rect:(CGRect)containerRect {
    return CGRectMake(self.bar1Position, containerRect.origin.y, self.bar2Position - self.bar1Position, containerRect.size.height);
}

- (NSString *)measurement {
    NSString *s = @"Uncalibrated";
    s = [NSString stringWithFormat:@"%@ (%.1f points)", s, [self points]];
    return s;
}

- (float) points {
    return self.bar2Position - self.bar1Position;
}

- (float)valueInPoints {
    return self.bar2Position - self.bar1Position;
}

@end
