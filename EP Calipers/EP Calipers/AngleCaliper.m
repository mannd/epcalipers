//
//  AngleCaliper.m
//  EP Calipers
//
//  Created by David Mann on 11/23/16.
//  Copyright © 2016 EP Studios. All rights reserved.
//

#import "AngleCaliper.h"

@implementation AngleCaliper

- (instancetype)init {
    self = [super init];
    if (self) {
        // angles of each bar in radians, with 0 being horizontal towards the right
        self.angleBar1 = 1.0;
        self.angleBar2 = 0.0;
        // bar1Position and bar2Position are equal and are the x coordinates of the vertex of the angle.
        // crossBarPosition is the y coordinate.
        self.bar1Position = 100.0f;
        self.bar2Position = 100.0f;
        self.crossBarPosition = 100.0f;
    }
    return self;
}

- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect {
    
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, self.lineWidth);

    CGContextMoveToPoint(context, self.bar1Position, self.crossBarPosition);
    CGContextAddLineToPoint(context, self.bar1Position, rect.size.height);
    
    CGContextMoveToPoint(context, self.bar1Position, self.crossBarPosition);
    CGContextAddLineToPoint(context, rect.size.width, self.crossBarPosition);

    // actually does the drawing
    CGContextStrokePath(context);
}

- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition {
    return NO;
}

- (BOOL)pointNearCrossBar:(CGPoint)p {
    float delta = 20.0f;
    return (p.x > self.bar1Position - delta && p.x < self.bar1Position + delta && p.y > self.crossBarPosition - delta && p.y < self.crossBarPosition + delta);
}

- (BOOL)pointNearCaliper:(CGPoint)p {
    return [self pointNearCrossBar:p];
}

@end
