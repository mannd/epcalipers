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
#define ANGLE_DELTA 0.15

@implementation AngleCaliper

@synthesize textPosition = _textPosition;

// override textPosition to just affect triangle base
- (void)setTextPosition:(TextPosition)value {
    self.triangleBaseTextPosition = value;
    _textPosition = value;
}

- (TextPosition)textPosition {
    return _textPosition;
}


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
        self.verticalCalibration = nil;
        self.isAngleCaliper = YES;
        self.triangleBaseTextPosition = [super textPosition];
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
    CGFloat length = MAX(rect.size.height, rect.size.width) * 2;
    
    // Make sure focal point never too close to screen edges
    // self.crossBarPosition = fminf(self.crossBarPosition, rect.size.height - DELTA);
    // self.crossBarPosition = fmaxf(self.crossBarPosition, DELTA);
    // self.bar1Position = fminf(self.bar1Position, rect.size.width - DELTA);
    // self.bar1Position = fmaxf (self.bar1Position, DELTA);
    // self.bar2Position = self.bar1Position;

    CGPoint endPointBar1 = [self endPointForPosition:CGPointMake(self.bar1Position, self.crossBarPosition) forAngle:self.angleBar1 andLength:length];
    CGContextMoveToPoint(context, self.bar1Position, self.crossBarPosition);
    CGContextAddLineToPoint(context, endPointBar1.x, endPointBar1.y);
    
    CGPoint endPointBar2 = [self endPointForPosition:CGPointMake(self.bar2Position, self.crossBarPosition) forAngle:self.angleBar2 andLength:length];
    CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
    CGContextAddLineToPoint(context, endPointBar2.x, endPointBar2.y);
    CGContextStrokePath(context);
    [self caliperTextInCanvas:rect textPosition:CenterAbove optimizeTextPosition:false];

    if (self.verticalCalibration.calibrated && self.verticalCalibration.unitsAreMM) {
        if ([self angleInSouthernHemisphere:self.angleBar1] && [self angleInSouthernHemisphere:self.angleBar2]) {
            double pointsPerMM = 1.0 / self.verticalCalibration.multiplier;
            [self drawTriangleBase:context rect:rect forHeight:5 * pointsPerMM];
        }
    }

    [self drawChosenComponent:context forRect:rect endPointBar1:endPointBar1 endPointBar2:endPointBar2];
}

- (void)drawChosenComponent:(CGContextRef)context forRect:(CGRect)rect endPointBar1:(CGPoint)endPointBar1 endPointBar2:(CGPoint)endPointBar2 {
    if (self.chosenComponent == None) {
        return;
    }
    UIColor *chosenComponentColor;
    if (self.selected) {
        chosenComponentColor = self.unselectedColor;
    }
    else {
        chosenComponentColor = self.selectedColor;
    }
    CGContextSetStrokeColorWithColor(context, [chosenComponentColor CGColor]);
    switch (self.chosenComponent) {
        case Bar1:
            CGContextMoveToPoint(context, self.bar1Position, self.crossBarPosition);
            CGContextAddLineToPoint(context, endPointBar1.x, endPointBar1.y);
            break;
        case Bar2:
            CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
            CGContextAddLineToPoint(context, endPointBar2.x, endPointBar2.y);
            break;
        case Crossbar:
            CGContextMoveToPoint(context, self.bar1Position, self.crossBarPosition);
            CGContextAddLineToPoint(context, endPointBar1.x, endPointBar1.y);
            CGContextMoveToPoint(context, self.bar2Position, self.crossBarPosition);
            CGContextAddLineToPoint(context, endPointBar2.x, endPointBar2.y);
            break;
        case None:
            break;
        default:
            break;
    }
    CGContextStrokePath(context);
}


- (void)drawTriangleBase:(CGContextRef)context rect:(CGRect)rect forHeight:(double)height {
    CGPoint point1 = [self getBasePoint1ForHeight:height];
    CGPoint point2 = [self getBasePoint2ForHeight:height];
    double lengthInPoints = point2.x - point1.x;
    CGContextMoveToPoint(context, point1.x, point1.y);
    CGContextAddLineToPoint(context, point2.x, point2.y);
    CGContextStrokePath(context);
    
    NSString *text = [self baseMeasurement:lengthInPoints];
    self.paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    self.paragraphStyle.alignment = NSTextAlignmentCenter;  
    
    [self.attributes setObject:self.textFont forKey:NSFontAttributeName];
    [self.attributes setObject:self.paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self.attributes setObject:self.color forKey:NSForegroundColorAttributeName];

    CGSize size = [text sizeWithAttributes:self.attributes];
    CGRect textRect = [self caliperTextPosition:self.triangleBaseTextPosition left:fminf(point1.x, point2.x) right:fmaxf(point1.x, point2.x) center:point1.y size:size canvas:rect optimizeTextPosition:YES];
    // same positioning as
    [text drawInRect:textRect  withAttributes:self.attributes];
}

// test if angle is in inferior half of unit circle
// these are the only angles relevant for Brugada triangle base measurement
- (BOOL)angleInSouthernHemisphere:(double)angle {
    return 0 < angle && angle < M_PI;
}

- (double)calibratedBaseResult:(double)lengthInPoints {
    lengthInPoints = lengthInPoints * self.calibration.multiplier;
    if (self.roundMsecRate && self.calibration.unitsAreMsec) {
        lengthInPoints = round(lengthInPoints);
    }
    return lengthInPoints;
}

- (NSString *)baseMeasurement:(double)lengthInPoints {
    NSString *s = [NSString localizedStringWithFormat:@"%.4g %@", [self calibratedBaseResult:lengthInPoints], self.calibration.rawUnits];
    return s;

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
    NSString *text = [NSString localizedStringWithFormat:@"%.1f°", degrees];
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
    NSString *text = [NSString localizedStringWithFormat:@"%.1f°", degrees];
    return text;
}

// provide this a utility to calling classes
+ (double)radiansToDegrees:(double)radians {
    return radians * 180.0 / M_PI;
}

+ (double)degreesToRadians:(double)degrees {
    return (degrees * M_PI) / 180.0;
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

- (void)moveBarInDirection:(MovementDirection)direction distance:(CGFloat)delta forComponent:(CaliperComponent)component {
    if (component == Crossbar) {
        [super moveCrossbarInDirection:direction distance:delta];
        return;
    }
    if (direction == Left) {
        delta = -delta;
    }
    switch (component) {
        case Bar1:
            self.angleBar1 -= [AngleCaliper degreesToRadians:delta];
            break;
        case Bar2:
            self.angleBar2 -= [AngleCaliper degreesToRadians:delta];
            break;
        default:
            break;
    }
}

- (BOOL)requiresCalibration {
    return NO;
}

// height of triangle in points, angle1 is angle of bar1, angle2 of bar2, in radians
// returns length of base of triangle in points
+ (double)calculateBaseFromHeight:(double)height andAngle1:(double)angle1 andAngle2:(double)angle2 {
    // alpha, beta, gamma are 3 angles of the triangle, starting at apex, going clockwise
    // a, b, c are vertices of triangle
    // m is intersection of height segment with base
    // alpha = angle1 - angle2;
    // alpha1 is angle between bar1 and height, alpha2 between height and bar2
    double alpha1 = angle1 - M_PI_2;
    double alpha2 = M_PI_2 - angle2;
    double beta = M_PI_2 - alpha2;
    double gamma = M_PI_2 - alpha1;
    double mb = height * sin(alpha2) / sin(beta);
    double cm = height * sin(alpha1) / sin(gamma);
    double base = cm + mb;
    return base;
}

// Note all angles in radians
+ (double)brugadaRiskV1ForBetaAngle:(double)betaAngle andBase:(double)base {
    betaAngle = [AngleCaliper radiansToDegrees:betaAngle];
    double numerator = pow(M_E, 6.297 + (-0.1714 * betaAngle) + (-0.0399 * base));
    double denominator = 1 + numerator;
    return numerator / denominator;
}

+ (double)brugadaRiskV2ForBetaAngle:(double)betaAngle andBase:(double)base {
    betaAngle = [AngleCaliper radiansToDegrees:betaAngle];
    double numerator = pow(M_E, 5.9756 + (-0.3568 * betaAngle) + (-0.9332 * base));
    double denominator = 1 + numerator;
    return numerator / denominator;
}

// figure out base coordinates
- (CGPoint)getBasePoint2ForHeight:(double)height {
    double pointY = self.crossBarPosition + height;
    double pointX = 0.0;
    pointX = height * (sin(M_PI_2 - self.angleBar2) / sin(self.angleBar2));
    pointX += self.bar1Position;
    CGPoint point = CGPointMake(pointX, pointY);
    return point;
}

- (CGPoint)getBasePoint1ForHeight:(double)height {
    double pointY = self.crossBarPosition + height;
    double pointX = 0.0;
    pointX = height * (sin(self.angleBar1 - M_PI_2) / sin(M_PI - self.angleBar1));
    pointX = self.bar1Position - pointX;
    CGPoint point = CGPointMake(pointX, pointY);
    return point;
}

- (void)encodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    [coder encodeDouble:self.angleBar1 forKey:[self getPrefixedKey:prefix key:@"AngleBar1"]];
    [coder encodeDouble:self.angleBar2 forKey:[self getPrefixedKey:prefix key:@"AngleBar2"]];
    
    [super encodeCaliperState:coder withPrefix:prefix];
}

- (void)decodeCaliperState:(NSCoder *)coder withPrefix:(NSString *)prefix {
    self.angleBar1 = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"AngleBar1"]];
    self.angleBar2 = [coder decodeDoubleForKey:[self getPrefixedKey:prefix key:@"AngleBar2"]];
    
    [super decodeCaliperState:coder withPrefix:prefix];
}



@end
