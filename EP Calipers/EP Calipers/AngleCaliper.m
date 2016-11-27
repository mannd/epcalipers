//
//  AngleCaliper.m
//  EP Calipers
//
//  Created by David Mann on 11/23/16.
//  Copyright © 2016 EP Studios. All rights reserved.
//

// Angle calipers are primarily useful for measuring beta angle in Brugada syndrome.
// see http://content.onlinejacc.org/article.aspx?articleid=1147780

#import "AngleCaliper.h"

#define DELTA 20.0
#define ANGLE_DELTA 0.2

@implementation AngleCaliper

- (instancetype)init {
    self = [super init];
    if (self) {
        // angles of each bar in radians, with 0 being horizontal towards the right
        // Pi/2 is 90 degree vertical down
        // Initial angle has bar1 to left of bar2, as with regular calipers
        self.angleBar1 = 0.5 * M_PI;
        self.angleBar2 = 0.25 * M_PI;
        // bar1Position and bar2Position are equal and are the x coordinates of the vertex of the angle.
        // crossBarPosition is the y coordinate.
        self.bar1Position = 100.0f;
        self.bar2Position = 100.0f;
        self.crossBarPosition = 100.0f;
    }
    return self;
}

- (void)setInitialPositionInRect:(CGRect)rect {
    static float differential = 0;
    self.bar1Position = (rect.size.width/3) + differential;
    self.bar2Position = self.bar1Position;
    self.crossBarPosition = (rect.size.height/3) + differential * 1.5;
    
    differential += 20;
    if (differential > 100) {
        differential = 0;
    }
}


- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect {
    
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, self.lineWidth);
    
    // This ensures caliper always extends past the screen edges
    CGFloat length = MAX(rect.size.height, rect.size.height) * 2;
    
    // Make sure focal point never too close to screen edges
    self.crossBarPosition = fminf(self.crossBarPosition, rect.size.height - DELTA);
    self.crossBarPosition = fmaxf(self.crossBarPosition, DELTA);
    self.bar1Position = fminf(self.bar1Position, rect.size.width - DELTA);
    self.bar1Position = fmaxf (self.bar1Position, DELTA);
    self.bar2Position = self.bar1Position;

    CGPoint endPointBar1 = [self endPointForPosition:CGPointMake(self.bar1Position, self.crossBarPosition) forAngle:self.angleBar1 andLength:length];
    CGContextMoveToPoint(context, self.bar1Position, self.crossBarPosition);
    CGContextAddLineToPoint(context, endPointBar1.x, endPointBar1.y);
    
    CGPoint endPointBar2 = [self endPointForPosition:CGPointMake(self.bar2Position, self.crossBarPosition) forAngle:self.angleBar2 andLength:length];
    CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
    CGContextAddLineToPoint(context, endPointBar2.x, endPointBar2.y);

    // actually does the drawing
    CGContextStrokePath(context);
    [self caliperText];
}

- (BOOL)pointNearBar:(CGPoint)p forBarAngle:(double)barAngle {
    double theta = [self relativeTheta:p];
    return theta < barAngle + ANGLE_DELTA && theta > barAngle - ANGLE_DELTA;
}

- (double)relativeTheta:(CGPoint)p {
    float x = p.x - self.bar1Position;
    float y = p.y - self.crossBarPosition;
    return atan2(y, x);
}

- (BOOL)pointNearBar1:(CGPoint)p {
    return [self pointNearBar:p forBarAngle:self.angleBar1];
}

- (BOOL)pointNearBar2:(CGPoint)p {
    return [self pointNearBar:p forBarAngle:self.angleBar2];
}

- (BOOL)pointNearCrossBar:(CGPoint)p {
    float delta = 40.0f;
    return (p.x > self.bar1Position - delta && p.x < self.bar1Position + delta && p.y > self.crossBarPosition - delta && p.y < self.crossBarPosition + delta);
}

- (BOOL)pointNearCaliper:(CGPoint)p {
    return [self pointNearCrossBar:p] || [self pointNearBar1:p]
    || [self pointNearBar2:p];
}

- (CGPoint)endPointForPosition:(CGPoint)p forAngle:(double)angle andLength:(CGFloat)length {
    double endX = cos(angle) * length + p.x;
    double endY = sin(angle) * length + p.y;
    CGPoint endPoint = CGPointMake(endX, endY);
    return endPoint;
}

- (NSString *)measurement {
    double angle = self.angleBar1 - self.angleBar2;
    double degrees = [AngleCaliper radiansToDegrees:angle];
    NSString *text = [NSString stringWithFormat:@"%.1f°", degrees];
    return text;
}

// override intervalResult to give angle in radians to calling functions
- (double)intervalResult {
    return self.angleBar1 - self.angleBar2;
}

- (NSString *)alphaAngle {
    // the angle between bar2 and a vertical
    double angle = 0.5 * M_PI - self.angleBar2;
    double degrees = [AngleCaliper radiansToDegrees:angle];
    NSString *text = [NSString stringWithFormat:@"%.1f°", degrees];
    return text;
}

// provide this a utility to calling classes
+ (double)radiansToDegrees:(double)radians {
    return radians * 180.0 / M_PI;
}

- (void)moveBar1:(CGPoint)delta forLocation:(CGPoint)location {
    self.angleBar1 = [self moveBarAngle:delta forLocation:location];
}

- (void)moveBar2:(CGPoint)delta forLocation:(CGPoint)location {
    self.angleBar2 = [self moveBarAngle:delta forLocation:location];
}

- (double)moveBarAngle:(CGPoint)delta forLocation:(CGPoint)location {
    CGPoint newPosition = CGPointMake(location.x + delta.x, location.y + delta.y);
    return [self relativeTheta:newPosition];
}

- (BOOL)requiresCalibration {
    return NO;
}

- (BOOL)isAngleCaliper {
    return YES;
}

@end
