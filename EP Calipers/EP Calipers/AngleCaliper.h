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

- (instancetype)init;
- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect;
//- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition;
- (BOOL)pointNearCrossBar:(CGPoint)p;
- (BOOL)pointNearCaliper:(CGPoint)p;
- (BOOL)pointNearBar:(CGPoint)p forBarAngle:(double)barAngle;
- (void)moveBar1:(CGPoint)delta forLocation:(CGPoint)location;
- (void)moveBar2:(CGPoint)delta forLocation:(CGPoint)location;
+ (double)radiansToDegrees:(double)radians;
+ (double)calculateBaseFromHeight:(double)height andAngle1:(double)angle1 andAngle2:(double)angle2;



@end
