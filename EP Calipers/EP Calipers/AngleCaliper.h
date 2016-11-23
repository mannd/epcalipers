//
//  AngleCaliper.h
//  EP Calipers
//
//  Created by David Mann on 11/23/16.
//  Copyright © 2016 EP Studios. All rights reserved.
//

#import "Caliper.h"

@interface AngleCaliper : Caliper

@property (nonatomic) double angleBar1;
@property (nonatomic) double angleBar2;
@property (nonatomic) CGPoint position;

- (instancetype)init;
- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect;
- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition;
- (BOOL)pointNearCrossBar:(CGPoint)p;
- (BOOL)pointNearCaliper:(CGPoint)p;


@end
