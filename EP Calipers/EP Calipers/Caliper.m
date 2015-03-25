//
//  Caliper.m
//  EP Calipers
//
//  Created by David Mann on 3/25/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "Caliper.h"

@implementation Caliper

- (instancetype)initWithDirection:(CaliperDirection)direction bar1Position:(float)bar1Position bar2Position:(float)bar2Position {
    self = [super init];
    if (self) {
        self.direction = direction;
        self.bar1Position = bar1Position;
        self.bar2Position = bar2Position;
    }
    self.color = [UIColor blueColor];
    return self;
}

- (void)drawWithContext:(CGContextRef)context withRect:(CGRect)rect {
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    float startX = rect.size.width/3;
    float endX = (2 * rect.size.width)/3;
    CGContextMoveToPoint(context, startX, 0);
    CGContextAddLineToPoint(context, startX, rect.size.height);
    CGContextSetLineWidth(context, 1);
    CGContextMoveToPoint(context, endX, 0);
    CGContextAddLineToPoint(context, endX, rect.size.height);
    CGContextMoveToPoint(context, endX, rect.size.height/2);
    CGContextAddLineToPoint(context, startX, rect.size.height/2);
    CGContextStrokePath(context);
    
}

- (void)drawWithContext:(CGContextRef)context {
    CGContextSetStrokeColorWithColor(context, [self.color CGColor]);
    
    
}

@end
