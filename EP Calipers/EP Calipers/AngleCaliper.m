//
//  AngleCaliper.m
//  EP Calipers
//
//  Created by David Mann on 11/23/16.
//  Copyright © 2016 EP Studios. All rights reserved.
//

#import "AngleCaliper.h"

#define DELTA 20.0

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
    
    NSString *text = [self measurement];
    self.paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.paragraphStyle.alignment = (self.direction == Horizontal ? NSTextAlignmentCenter : NSTextAlignmentLeft);
    
    [self.attributes setObject:self.textFont forKey:NSFontAttributeName];
    [self.attributes setObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self.attributes setObject:self.color forKey:NSForegroundColorAttributeName];
    
    if (self.direction == Horizontal) {
        // the math here insures that the label doesn't get so small that it can't be read
        [text drawInRect:CGRectMake((self.bar2Position > self.bar1Position ? self.bar1Position - 25: self.bar2Position - 25), self.crossBarPosition - 20,  fmaxf(50.0, fabsf(self.bar2Position - self.bar1Position) + 50), 20)  withAttributes:self.attributes];
    }
    else {
        [text drawInRect:CGRectMake(self.crossBarPosition + 5, self.bar1Position + (self.bar2Position - self.bar1Position)/2, 140, 20) withAttributes:self.attributes];
    }

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

- (CGPoint)endPointForPosition:(CGPoint)p forAngle:(double)angle andLength:(CGFloat)length {
    double endX = cos(angle) * length + p.x;
    double endY = sin(angle) * length + p.y;
    CGPoint endPoint = CGPointMake(endX, endY);
    return endPoint;
}

- (NSString *)measurement {
    double angle = self.angleBar1 - self.angleBar2;
    double degrees = angle * 180.0 / M_PI;
    NSString *text = [NSString stringWithFormat:@"%.4g°", degrees];
    return text;
}

@end
