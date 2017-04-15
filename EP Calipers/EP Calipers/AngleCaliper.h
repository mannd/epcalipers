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
@property (weak, nonatomic) Calibration *verticalCalibration;

- (instancetype)init;
- (void)drawWithContext:(CGContextRef)context inRect:(CGRect)rect;
//- (BOOL)pointNearBar:(CGPoint)p forBarPosition:(float)barPosition;
- (BOOL)pointNearCrossBar:(CGPoint)p;
- (BOOL)pointNearCaliper:(CGPoint)p;
- (BOOL)pointNearBar:(CGPoint)p forBarAngle:(double)barAngle;
- (void)moveBar1:(CGPoint)delta forLocation:(CGPoint)location;
- (void)moveBar2:(CGPoint)delta forLocation:(CGPoint)location;
- (void)moveBarInDirection:(MovementDirection)direction distance:(CGFloat)delta forComponent:(CaliperComponent)component;

+ (double)radiansToDegrees:(double)radians;
+ (double)degreesToRadians:(double)degrees;
+ (double)calculateBaseFromHeight:(double)height andAngle1:(double)angle1 andAngle2:(double)angle2;
+ (double)brugadaRiskV1ForBetaAngle:(double)betaAngle andBase:(double)base;
+ (double)brugadaRiskV2ForBetaAngle:(double)betaAngle andBase:(double)base;

- (void)encodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix;
- (void)decodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix;


@end
