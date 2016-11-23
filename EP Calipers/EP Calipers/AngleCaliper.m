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
    // angles in radians for calcuations
    if (self) {
        self.angleBar1 = 1.0;
        self.angleBar2 = 0.0;
        self.position = CGPointMake(100.0f, 100.0f);
    }
    return self;
}

- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect {
    
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    CGContextSetLineWidth(context, self.lineWidth);

    CGContextMoveToPoint(context, self.position.x, self.position.y);
    CGContextAddLineToPoint(context, self.position.x, rect.size.height);
    
    CGContextMoveToPoint(context, self.position.x, self.position.y);
    CGContextAddLineToPoint(context, rect.size.width, self.position.y);
    
}

- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition {
    return NO;
}

- (BOOL)pointNearCrossBar:(CGPoint)p {
    float delta = 20.0f;
    if (p.x > self.position.x - delta && p.x < self.position.x + delta && p.y > self.position.y - delta && p.y < self.position.y + delta) {
        NSLog(@"near bar");
        return YES;
    }
    return NO;
}

- (BOOL)pointNearCaliper:(CGPoint)p {
    return [self pointNearCrossBar:p];
}

@end
