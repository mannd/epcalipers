//
//  CaliperView.m
//  EP Calipers
//
//  Created by David Mann on 3/23/15.
//  Copyright (c) 2015 EP Studios. All rights reserved.
//

#import "CalipersView.h"

@implementation CalipersView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(con, [[UIColor redColor] CGColor]);
    float startX = rect.size.width/3;
    float endX = (2 * rect.size.width)/3;
    CGContextMoveToPoint(con, startX, 0);
    CGContextAddLineToPoint(con, startX, rect.size.height);
    CGContextSetLineWidth(con, 1);
    CGContextMoveToPoint(con, endX, 0);
    CGContextAddLineToPoint(con, endX, rect.size.height);
    CGContextMoveToPoint(con, endX, rect.size.height/2);
    CGContextAddLineToPoint(con, startX, rect.size.height/2);
    CGContextStrokePath(con);
}


@end
